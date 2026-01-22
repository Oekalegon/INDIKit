import Foundation
import Network

/// A description of an INDI server endpoint.
public struct INDIServerEndpoint: Sendable, Hashable {
    public let host: String
    public let port: UInt16

    public init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
}

/// Actor that manages a single connection to an INDI server.
///
/// You can create multiple instances of this actor to talk to multiple servers concurrently.
public actor INDIServer {
    public let endpoint: INDIServerEndpoint

    private var connection: NWConnection?
    private var connectionQueue: DispatchQueue?
    private var receiveContinuation: AsyncThrowingStream<Data, Error>.Continuation?
    private var receiveStream: AsyncThrowingStream<Data, Error>?
    private let parser = INDIXMLParser()

    public private(set) var isConnected: Bool = false

    public init(endpoint: INDIServerEndpoint) {
        self.endpoint = endpoint
    }

    /// Establish a TCP connection to the INDI server.
    ///
    /// - Throws: An error if the connection could not be established.
    @discardableResult
    public func connect() async throws -> AsyncThrowingStream<Data, Error> {
        if let stream = receiveStream, isConnected {
            return stream
        }

        let params = NWParameters.tcp
        let queue = DispatchQueue(label: "indi.connection.\(endpoint.host):\(endpoint.port)")
        guard let port = NWEndpoint.Port(rawValue: endpoint.port) else {
            throw NSError(domain: "INDIServerConnection", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Invalid port number: \(endpoint.port)"
            ])
        }
        let nwConnection = NWConnection(
            host: NWEndpoint.Host(endpoint.host),
            port: port,
            using: params
        )

        self.connection = nwConnection
        self.connectionQueue = queue

        let stream = AsyncThrowingStream<Data, Error> { continuation in
            self.receiveContinuation = continuation
        }
        self.receiveStream = stream

        // Start the connection and wait until it becomes ready or fails.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            nwConnection.stateUpdateHandler = { [weak self] state in
                Task { [weak self] in
                    guard let self else { return }
                    await self.handleStateUpdate(state, continuation: continuation)
                }
            }

            nwConnection.start(queue: queue)
        }

        return stream
    }

    /// Close the connection to the server.
    public func disconnect() {
        guard let connection else { return }
        connection.cancel()
        self.connection = nil
        self.isConnected = false
        Task {
            await self.finishReceiving(error: nil)
        }
    }

    /// Send raw data to the server.
    public func send(_ data: Data) async throws {
        guard let connection, isConnected else {
            throw NSError(domain: "INDIServerConnection", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Connection is not open"
            ])
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }

    /// Send the INDI handshake message to request property updates from the server.
    ///
    /// This sends `<getProperties version='1.7'/>` which tells the INDI server to start
    /// sending property updates to this client.
    public func sendHandshake() async throws {
        let handshake = "<getProperties version='1.7'/>\n"
        try await send(Data(handshake.utf8))
    }

    /// Returns a stream of raw message payloads received from the server.
    ///
    /// Call `connect()` first to establish the connection and start the receive loop.
    public func messages() -> AsyncThrowingStream<Data, Error>? {
        receiveStream
    }

    // MARK: - Temporary debugging methods

    /// Parse and print INDI Properties from the data stream.
    ///
    /// This is a convenience method for testing/debugging. It parses incoming
    /// data and prints the resulting INDIProperty objects.
    public func parseAndPrintMessages() async throws {
        guard let dataStream = receiveStream else {
            throw NSError(domain: "INDIServer", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Not connected. Call connect() first."
            ])
        }
        
        let propertyStream = await parser.parse(dataStream)
        
        for try await property in propertyStream {
            print("Parsed INDI Property:")
            printMessage(property)
        }
    }
    
    /// Print an INDIProperty in a readable format.
    private func printMessage(_ message: INDIProperty) {
        print("  Operation: \(message.operation)")
        print("  Property Type: \(message.propertyType)")
        
        if !message.device.isEmpty {
            print("  Device: \(message.device)")
        }
        if !message.group.isEmpty {
            print("  Group: \(message.group)")
        }
        if !message.label.isEmpty {
            print("  Label: \(message.label)")
        }
        print("  Property: \(message.property.displayName)")
        print("  Permissions: \(message.permissions.indiValue)")
        print("  State: \(message.state.indiValue)")
        
        if message.timeout > 0 {
            print("  Timeout: \(message.timeout)s")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        print("  Timestamp: \(dateFormatter.string(from: message.timeStamp))")
        
        // Print child elements if available
        if let rawProperty = message as? RawINDIProperty, !rawProperty.xmlNode.children.isEmpty {
            print("  Children: \(rawProperty.xmlNode.children.count) element(s)")
            for (index, child) in rawProperty.xmlNode.children.enumerated() {
                print("    [\(index)] \(child.name)")
            }
        }
        
        print("---")
    }

    // MARK: - Private

    private func handleStateUpdate(
        _ state: NWConnection.State,
        continuation: CheckedContinuation<Void, Error>
    ) async {
        switch state {
        case .ready:
            isConnected = true
            continuation.resume()
            // Start receive loop asynchronously to avoid blocking
            Task {
                await self.startReceiveLoop()
            }

        case .failed(let error):
            isConnected = false
            continuation.resume(throwing: error)
            await finishReceiving(error: error)

        case .cancelled:
            isConnected = false
            await finishReceiving(error: nil)

        default:
            break
        }
    }

    private func startReceiveLoop() async {
        guard let connection, let queue = connectionQueue else {
            return
        }

        // Use sync dispatch to ensure receive is set up immediately on the queue
        queue.sync { [weak connection] in
            guard let connection else { return }
            connection.receive(
                minimumIncompleteLength: 1,
                maximumLength: 64 * 1024
            ) { [weak self] content, _, isComplete, error in
                Task { [weak self] in
                    guard let self else { return }

                    if let error {
                        await self.finishReceiving(error: error)
                        return
                    }

                    if let data = content, !data.isEmpty {
                        await self.handleReceivedData(data)
                    }

                    if isComplete {
                        await self.finishReceiving(error: nil)
                    } else {
                        await self.startReceiveLoop()
                    }
                }
            }
        }
    }

    private func finishReceiving(error: Error?) async {
        if let error {
            receiveContinuation?.finish(throwing: error)
        } else {
            receiveContinuation?.finish()
        }
        receiveContinuation = nil
        receiveStream = nil
    }

    private func handleReceivedData(_ data: Data) async {
        receiveContinuation?.yield(data)
    }
}

import Foundation
import Network
import os

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

    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "INDIServer")
    
    public let endpoint: INDIServerEndpoint

    private var connection: NWConnection?
    private var connectionQueue: DispatchQueue?
    private var rawDataContinuation: AsyncThrowingStream<Data, Error>.Continuation?
    private var parsedDataContinuation: AsyncThrowingStream<Data, Error>.Continuation?
    private var rawDataStream: AsyncThrowingStream<Data, Error>?
    private var parsedDataStream: AsyncThrowingStream<Data, Error>?
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
        if let stream = rawDataStream, isConnected {
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

        // Create separate streams for raw data and parsed data
        let rawStream = AsyncThrowingStream<Data, Error> { continuation in
            self.rawDataContinuation = continuation
        }
        self.rawDataStream = rawStream
        
        let parsedStream = AsyncThrowingStream<Data, Error> { continuation in
            self.parsedDataContinuation = continuation
        }
        self.parsedDataStream = parsedStream

        // Start the connection and wait until it becomes ready or fails.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            nwConnection.stateUpdateHandler = { [weak self] state in
                Task { [weak self] in
                    guard let self else { return }
                    await self.handleStateUpdate(state, continuation: continuation)
                }
            }

            Self.logger.info("Starting connection to \(self.endpoint.host, privacy: .public):\(self.endpoint.port)")
            nwConnection.start(queue: queue)
        }

        return rawStream
    }

    /// Close the connection to the server.
    public func disconnect() {
        Self.logger.info("Disconnecting from \(self.endpoint.host, privacy: .public):\(self.endpoint.port)")
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
        Self.logger.info("Sending data to \(self.endpoint.host, privacy: .public):\(self.endpoint.port)")
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
    
    /// Send an INDI message to the server.
    ///
    /// Only messages with `.set`, `.get` (getProperties), `.ping`, or `.enableBlob` operations can be sent to the server.
    /// This method serializes the message to XML and sends it to the server.
    ///
    /// - Parameter message: The INDI message to send (must have `.set`, `.get`, or `.enableBlob` operation)
    /// - Throws: An error if not connected, if the message operation is not supported, or if serialization fails
    public func send(_ message: INDIMessage) async throws {
        let allowedOperations: [INDIOperation] = [.set, .get, .enableBlob, .ping]
        guard allowedOperations.contains(message.operation) else {
            let errorMessage = "Only messages with .set, .get, .ping, or .enableBlob operations can be sent to the server. " +
                "Received message with operation: \(message.operation.rawValue)"
            throw NSError(domain: "INDIServer", code: 2, userInfo: [
                NSLocalizedDescriptionKey: errorMessage
            ])
        }
        
        let xml = try message.toXML()
        let xmlWithNewline = xml + "\n"
        try await send(Data(xmlWithNewline.utf8))
    }

    /// Send the INDI handshake message to request message updates from the server.
    ///
    /// This sends `<getProperties version='1.7'/>` which tells the INDI server to start
    /// sending message updates to this client.
    public func sendHandshake() async throws {
        let handshake = "<getProperties version='1.7'/>\n"
        try await send(Data(handshake.utf8))
    }

    /// Returns a stream of raw message payloads received from the server.
    ///
    /// Call `connect()` first to establish the connection and start the receive loop.
    public func rawDataMessages() -> AsyncThrowingStream<Data, Error>? {
        rawDataStream
    }

    /// Returns a stream of parsed INDI messages from the data stream.
    ///
    /// Returns an asynchronous stream of parsed INDI messages from the connected server.
    /// Messages are parsed from incoming XML data and yielded as they become available.
    ///
    /// - Returns: An `AsyncThrowingStream` that yields `INDIMessage` objects as they are parsed
    /// - Throws: An error if not connected (call `connect()` first)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let messageStream = try await server.messages()
    ///
    /// for try await message in messageStream {
    ///     // Process each message as it arrives
    ///     print("Received message: \(message.name?.displayName ?? "unknown")")
    /// }
    /// ```
    public func messages() async throws -> AsyncThrowingStream<INDIMessage, Error> {
        guard let dataStream = parsedDataStream else {
            throw NSError(domain: "INDIServer", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Not connected. Call connect() first."
            ])
        }
        
        return await parser.parse(dataStream)
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

                    // Always continue receiving unless the connection is complete
                    // This ensures we keep listening for responses even after sending messages
                    if isComplete {
                        await self.finishReceiving(error: nil)
                    } else {
                        // Continue receiving - this is critical to keep the loop alive
                        await self.startReceiveLoop()
                    }
                }
            }
        }
    }

    private func finishReceiving(error: Error?) async {
        if let error {
            rawDataContinuation?.finish(throwing: error)
            parsedDataContinuation?.finish(throwing: error)
        } else {
            rawDataContinuation?.finish()
            parsedDataContinuation?.finish()
        }
        rawDataContinuation = nil
        parsedDataContinuation = nil
        rawDataStream = nil
        parsedDataStream = nil
    }

    private func handleReceivedData(_ data: Data) async {
        // Broadcast data to both streams
        rawDataContinuation?.yield(data)
        parsedDataContinuation?.yield(data)
    }
}

import Foundation
import Network
import os

/// A description of an INDI server endpoint.
public struct INDIServerEndpoint: Sendable, Hashable {

    /// The host name or IP address of the INDI server.
    public let host: String

    /// The port number of the INDI server.
    public let port: UInt16

    /// Initialize a new INDI server endpoint.
    ///
    /// - Parameters:
    ///   - host: The host name or IP address of the INDI server.
    ///   - port: The port number of the INDI server.
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
    
    /// The endpoint of the INDI server.
    public let endpoint: INDIServerEndpoint

    /// The connection to the INDI server.
    private var connection: NWConnection?

    /// The queue for the connection.
    private var connectionQueue: DispatchQueue?

    /// The continuation for the raw data stream.
    private var rawDataContinuation: AsyncThrowingStream<Data, Error>.Continuation?

    /// The continuation for the parsed data stream.
    private var parsedDataContinuation: AsyncThrowingStream<Data, Error>.Continuation?

    /// The raw data stream.
    private var rawDataStream: AsyncThrowingStream<Data, Error>?

    /// The parsed data stream.
    private var parsedDataStream: AsyncThrowingStream<Data, Error>?

    /// The parser for the INDI messages.
    private let parser = INDIXMLParser()

    /// The connection state of the INDI server.
    public private(set) var isConnected: Bool = false
    
    /// The current connection continuation (for cancellation handling)
    private var connectionContinuation: CheckedContinuation<Void, Error>?
    
    /// Flag to track if the connection continuation has been resumed
    private var connectionContinuationResumed: Bool = false

    /// Initialize a new INDI server.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint of the INDI server.
    public init(endpoint: INDIServerEndpoint) {
        self.endpoint = endpoint
    }

    /// Establish a TCP connection to the INDI server.
    ///
    /// - Returns: A stream of raw data from the INDI server.
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
        // Use withTaskCancellationHandler to ensure connection is cancelled if task is cancelled
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                // Store continuation for cancellation handling and reset resumed flag
                self.connectionContinuation = continuation
                self.connectionContinuationResumed = false
                
                nwConnection.stateUpdateHandler = { [weak self] state in
                    Task { [weak self] in
                        guard let self else { return }
                        await self.handleStateUpdate(state, continuation: continuation)
                    }
                }

                Self.logger.info("Starting connection to \(self.endpoint.host, privacy: .public):\(self.endpoint.port)")
                nwConnection.start(queue: queue)
            }
        } onCancel: {
            // If the task is cancelled, cancel the connection and resume continuation
            // Use Task.detached to ensure this runs even if the parent task is cancelled
            Task.detached { [weak self] in
                guard let self else { return }
                await self.cancelConnection()
            }
        }

        return rawStream
    }

    /// Closex the connection to the server.
    public func disconnect() {
        Self.logger.info("Disconnecting from \(self.endpoint.host, privacy: .public):\(self.endpoint.port)")
        
        // Cancel the connection first - this will trigger state updates
        // But we need to handle the continuation before cancelling to avoid race conditions
        let continuationToResume: CheckedContinuation<Void, Error>?
        if let continuation = connectionContinuation, !connectionContinuationResumed {
            // Atomically claim the continuation
            connectionContinuation = nil
            connectionContinuationResumed = true
            continuationToResume = continuation
        } else {
            continuationToResume = nil
        }
        
        // Cancel the connection (this may trigger state updates)
        if let connection = connection {
            connection.cancel()
            self.connection = nil
        }
        self.isConnected = false
        
        // Resume the continuation AFTER cancelling to ensure state updates see the flag
        if let continuation = continuationToResume {
            continuation.resume(throwing: CancellationError())
        }
        
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
    /// Only messages with `.set`, `.get` (getProperties), `.pingReply`, or `.enableBlob` operations can be sent to the server.
    /// This method serializes the message to XML and sends it to the server.
    ///
    /// - Parameter message: The INDI message to send (must have `.set`, `.get`, `.pingReply`, or `.enableBlob` operation)
    /// - Throws: An error if not connected, if the message operation is not supported, or if serialization fails
    public func send(_ message: INDIMessage) async throws {
        let allowedOperations: [INDIOperation] = [.set, .get, .enableBlob, .pingReply]
        guard allowedOperations.contains(message.operation) else {
            let errorMessage = "Only messages with .set, .get, .pingReply, or .enableBlob " +
                "operations can be sent to the server. " +
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
    /// 
    /// ## Example
    ///
    /// ```swift
    /// let rawDataStream = try await server.rawDataMessages()
    ///
    /// for try await data in rawDataStream {
    ///     // Process each raw data chunk as it arrives
    ///     print("Received raw data: \(data.count) bytes")
    /// }
    /// 
    /// - Returns: A stream of raw data from the INDI server.
    public func rawDataMessages() -> AsyncThrowingStream<Data, Error>? {
        rawDataStream
    }

    /// Returns a stream of parsed INDI messages from the data stream.
    ///
    /// Returns an asynchronous stream of parsed INDI messages from the connected server.
    /// Messages are parsed from incoming XML data and yielded as they become available.
    /// 
    /// NB. You will need to call ``connect()`` first to establish the connection and start 
    /// the receive loop.
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
    ///
    /// - Returns: An `AsyncThrowingStream` that yields `INDIMessage` objects as they are parsed
    /// - Throws: An error if not connected (call `connect()` first)
    public func messages() async throws -> AsyncThrowingStream<INDIMessage, Error> {
        guard let dataStream = parsedDataStream else {
            throw NSError(domain: "INDIServer", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Not connected. Call connect() first."
            ])
        }
        
        let parsedStream = await parser.parse(dataStream)
        
        // Wrap the stream to automatically respond to pingRequest messages
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await message in parsedStream {
                        // Automatically respond to pingRequest messages
                        if case .pingRequest(let pingRequest) = message {
                            let pingReply = INDIPingReply(uid: pingRequest.uid)
                            Task.detached { [weak self] in
                                guard let self = self else { return }
                                do {
                                    try await self.send(.pingReply(pingReply))
                                    let uid = pingReply.uid ?? "no uid"
                                    Self.logger.debug("Automatically sent pingReply: \(uid, privacy: .public)")
                                } catch {
                                    Self.logger.error(
                                        "Error automatically sending pingReply: \(error, privacy: .public)"
                                    )
                                }
                            }
                        }
                        // Yield the message to the client (including pingRequest)
                        continuation.yield(message)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func handleStateUpdate(
        _ state: NWConnection.State,
        continuation: CheckedContinuation<Void, Error>
    ) async {
        // Check if this continuation has already been resumed
        // If it has, just handle state changes without resuming
        guard !connectionContinuationResumed, connectionContinuation != nil else {
            // Continuation was already resumed (connection was already established)
            // Just handle the state change without resuming
            switch state {
            case .cancelled:
                isConnected = false
                await finishReceiving(error: nil)
            case .failed(let error):
                isConnected = false
                await finishReceiving(error: error)
            default:
                break
            }
            return
        }
        
        // Only mark as resumed and clear continuation when we actually resume it
        switch state {
        case .ready:
            // Atomically claim and resume the continuation
            connectionContinuationResumed = true
            connectionContinuation = nil
            isConnected = true
            continuation.resume()
            // Start receive loop asynchronously to avoid blocking
            Task {
                await self.startReceiveLoop()
            }

        case .failed(let error):
            // Atomically claim and resume the continuation
            connectionContinuationResumed = true
            connectionContinuation = nil
            isConnected = false
            continuation.resume(throwing: error)
            await finishReceiving(error: error)

        case .cancelled:
            // Atomically claim and resume the continuation
            connectionContinuationResumed = true
            connectionContinuation = nil
            isConnected = false
            continuation.resume(throwing: CancellationError())
            await finishReceiving(error: nil)

        default:
            // For other states (.waiting, .setup, etc.), don't resume yet
            // The continuation will be resumed when we get .ready, .failed, or .cancelled
            break
        }
    }
    
    /// Cancel the current connection attempt and resume continuation if needed
    private func cancelConnection() async {
        // Atomically claim the continuation
        let continuationToResume: CheckedContinuation<Void, Error>?
        if let continuation = connectionContinuation, !connectionContinuationResumed {
            connectionContinuation = nil
            connectionContinuationResumed = true
            continuationToResume = continuation
        } else {
            continuationToResume = nil
        }
        
        // Cancel the connection
        if let connection = connection {
            connection.cancel()
        }
        
        // Resume the continuation if we claimed it
        if let continuation = continuationToResume {
            continuation.resume(throwing: CancellationError())
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

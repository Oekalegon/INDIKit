import Foundation
import INDIProtocol
import INDIState
import Observation

/// MainActor-isolated registry lookup for callbacks
@MainActor
private enum RegistryLookup {
    private static var registries: [ObjectIdentifier: ObservableINDIStateRegistry] = [:]
    
    static func register(_ registry: ObservableINDIStateRegistry) {
        registries[ObjectIdentifier(registry)] = registry
    }
    
    static func unregister(registryID: ObjectIdentifier) {
        registries.removeValue(forKey: registryID)
    }
    
    static func get(_ id: ObjectIdentifier) -> ObservableINDIStateRegistry? {
        return registries[id]
    }
}

/// Observable wrapper for INDIStateRegistry that enables SwiftUI integration.
///
/// This class wraps the `INDIStateRegistry` actor and provides `@Observable` state
/// that SwiftUI views can observe. It maintains a dictionary of `ObservableINDIDevice`
/// instances that stay in sync with the underlying registry through callbacks.
@MainActor
@Observable
public class ObservableINDIStateRegistry {
    
    private let registry: INDIStateRegistry
    
    /// Observable connection status - true only when actually connected
    public private(set) var connected: Bool = false

    /// Observable connecting status - true while connection is being established
    public private(set) var connecting: Bool = false

    /// Observable dictionary of devices, keyed by device name
    public private(set) var devices: [String: ObservableINDIDevice] = [:]
    
    /// Connection timeout in seconds. Default is 10 seconds.
    public var connectionTimeout: TimeInterval = 10.0

    /// Task that is running the connection, if any
    private var connectionTask: Task<Void, Error>?
    
    /// Initialize the observable registry with an INDI server endpoint.
    /// - Parameter endpoint: The endpoint of the INDI server to connect to
    public init(endpoint: INDIServerEndpoint) {
        self.registry = INDIStateRegistry(endpoint: endpoint)
        let registryID = ObjectIdentifier(self)
        
        // Register this instance for callback lookup on MainActor
        Task { @MainActor [weak self] in
            if let self = self {
                RegistryLookup.register(self)
            }
        }
        
        // Set up callbacks to sync observable state when registry updates
        Task {
            await registry.setOnDeviceUpdate { @Sendable deviceName, device in
                // This callback is called from within the actor
                // Dispatch to MainActor to look up and update the registry
                Task { @MainActor in
                    if let registry = RegistryLookup.get(registryID) {
                        await registry.syncDevice(deviceName: deviceName, device: device)
                    }
                }
            }
            
            await registry.setOnPropertyUpdate { @Sendable deviceName, _ in
                // When a property updates, we need to sync the device
                Task { @MainActor in
                    if let registry = RegistryLookup.get(registryID) {
                        await registry.syncDeviceFromRegistry(deviceName: deviceName)
                    }
                }
            }
        }
    }
    
    deinit {
        // Unregister this instance - capture ObjectIdentifier before deinit
        let registryID = ObjectIdentifier(self)
        Task { @MainActor in
            RegistryLookup.unregister(registryID: registryID)
        }
    }
    
    // swiftlint:disable:next orphaned_doc_comment
    /// Connect to the INDI server.
    /// 
    /// This method forwards to the underlying registry's connect method and
    /// updates the observable connection status. Note that this method will
    /// run the message stream and block until the connection is closed.
    /// 
    /// If already connected or connecting, this method does nothing.
    /// - Throws: An error if the connection fails
    // swiftlint:disable:next function_body_length
    public func connect() async throws {
        // Check if already connected
        if await registry.connected {
            // Update observable state immediately
            await MainActor.run {
                self.connected = true
            }
            return
        }
        
        // Cancel and wait for any existing connection task to finish
        if let existingTask = connectionTask {
            existingTask.cancel()
            // Wait a bit for cancellation to propagate, but don't wait forever
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            connectionTask = nil
        }

        // Mark as connecting (not connected yet)
        await MainActor.run {
            self.connecting = true
            self.connected = false
        }

        // Start monitoring connection status in a separate task
        let monitorTask = Task { @MainActor in
            // Poll the connected status from the registry periodically
            // The registry's connect() method will run the message stream and block,
            // so we monitor the status in parallel to keep the observable state in sync
            while !Task.isCancelled {
                let isConnected = await registry.connected
                if self.connected != isConnected {
                    self.connected = isConnected
                    // Once connected, we're no longer "connecting"
                    if isConnected {
                        self.connecting = false
                    }
                }
                // If we're not connected anymore and not connecting, stop monitoring
                if !isConnected && !self.connecting {
                    break
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
            }
        }

        // Set the timeout on the registry before connecting
        await setConnectionTimeout(connectionTimeout)
        
        // Create and store the connection task
        let connectTask = Task {
            do {
                try await registry.connect()
            } catch {
                // Connection failed, timed out, or was cancelled
                monitorTask.cancel()
                await MainActor.run {
                    self.connected = false
                    self.connecting = false
                    self.connectionTask = nil
                }
                throw error
            }
            // Connection closed normally
            monitorTask.cancel()
            await MainActor.run {
                self.connected = false
                self.connecting = false
                self.connectionTask = nil
            }
        }

        connectionTask = connectTask

        // Wait for the connection task to complete
        try await connectTask.value
    }
    
    /// Disconnect from the INDI server.
    ///
    /// This method forwards to the underlying registry's disconnect method
    /// and updates the observable connection status.
    /// - Throws: An error if disconnection fails
    public func disconnect() async throws {
        // Cancel any ongoing connection task
        connectionTask?.cancel()

        try await registry.disconnect()

        let isConnected = await registry.connected
        await MainActor.run {
            self.connected = isConnected
            self.connecting = false
            self.connectionTask = nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get a device from the registry by name.
    /// - Parameter name: The name of the device
    /// - Returns: The device if it exists, otherwise nil
    func getDevice(name: String) async -> INDIDevice? {
        return await registry.devices[name]
    }
    
    /// Update a device in the registry.
    /// 
    /// This will trigger callbacks which will sync the observable state.
    /// - Parameter device: The device to update
    func updateDevice(_ device: INDIDevice) async {
        await registry.registerDevice(device: device)
        // The callback will automatically sync the observable state
    }
    
    /// Enable BLOB reception for a property.
    ///
    /// This is a convenience wrapper around the underlying registry's enableBLOB method.
    /// - Parameters:
    ///   - device: The device name
    ///   - property: The property name
    ///   - state: The BLOB sending state
    func enableBLOB(device: String, property: INDIPropertyName, state: BLOBSendingState) async throws {
        try await registry.enableBLOB(device: device, property: property, state: state)
    }
    
    /// Sync a device from the registry.
    /// 
    /// This creates or updates an ObservableINDIDevice instance.
    /// - Parameters:
    ///   - deviceName: The name of the device
    ///   - device: The updated device from the registry
    @MainActor
    func syncDevice(deviceName: String, device: INDIDevice) async {
        if let observableDevice = devices[deviceName] {
            // Update existing observable device
            await observableDevice.sync(from: device)
        } else {
            // Create new observable device
            devices[deviceName] = ObservableINDIDevice(device: device, registry: self)
        }
    }
    
    /// Sync a device by fetching it from the registry.
    /// 
    /// This is called when a property update occurs.
    /// - Parameter deviceName: The name of the device to sync
    @MainActor
    func syncDeviceFromRegistry(deviceName: String) async {
        let device = await registry.devices[deviceName]
        if let device = device {
            await syncDevice(deviceName: deviceName, device: device)
        }
    }
    
    /// Set the connection timeout on the registry.
    /// - Parameter timeout: The timeout in seconds
    private func setConnectionTimeout(_ timeout: TimeInterval) async {
        await registry.setConnectionTimeout(timeout)
    }
    
    /// Returns a stream of raw message payloads received from the server.
    ///
    /// This provides access to the raw data stream for progress tracking and other purposes.
    /// The stream yields raw Data chunks as they arrive from the server.
    /// 
    /// - Returns: A stream of raw data from the INDI server, or nil if not connected
    /// - Throws: An error if not connected
    public func rawDataStream() async throws -> AsyncThrowingStream<Data, Error>? {
        guard await registry.connected else {
            throw NSError(
                domain: "ObservableINDIStateRegistry",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Not connected. Call connect() first."
                ]
            )
        }
        return await registry.server.rawDataMessages()
    }
}

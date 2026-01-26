import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for INDIDevice that enables SwiftUI integration.
///
/// This class wraps the `INDIDevice` struct and provides `@Observable` state
/// that SwiftUI views can observe. It maintains observable properties that
/// stay in sync with the underlying device through the registry's callbacks.
@Observable
public class ObservableINDIDevice {
    
    private let registry: ObservableINDIStateRegistry
    private let deviceName: String
    
    // Internal state that triggers observation
    private var _connectionStatus: INDIDevice.ConnectionStatus
    private var _properties: [ObservableINDIProperty] = []
    
    /// The device name
    public var name: String { deviceName }
    
    /// The connection status of the device
    public var connectionStatus: INDIDevice.ConnectionStatus {
        get { _connectionStatus }
        set { _connectionStatus = newValue }
    }
    
    /// The properties of the device
    public var properties: [ObservableINDIProperty] {
        get { _properties }
        set { _properties = newValue }
    }
    
    /// Initialize an observable device from an INDIDevice.
    /// - Parameters:
    ///   - device: The underlying device
    ///   - registry: The observable registry that manages this device
    init(device: INDIDevice, registry: ObservableINDIStateRegistry) {
        self.deviceName = device.name
        self.registry = registry
        self._connectionStatus = device.connectionStatus
        self._properties = device.properties.map { 
            createObservableProperty(from: $0, device: self)
        }
    }
    
    /// Sync this observable device from an updated INDIDevice.
    /// 
    /// This is called by the registry when it receives updates from the server.
    /// - Parameter device: The updated device from the registry
    @MainActor
    func sync(from device: INDIDevice) async {
        // Update connection status
        self._connectionStatus = device.connectionStatus
        
        // Update properties - merge with existing to preserve ObservableINDIProperty instances
        let existingPropertyMap = Dictionary(uniqueKeysWithValues: 
            _properties.map { ($0.name, $0) }
        )
        
        self._properties = device.properties.map { property in
            if let existing = existingPropertyMap[property.name] {
                // Update existing observable property
                existing.sync(from: property)
                return existing
            } else {
                // Create new observable property
                return createObservableProperty(from: property, device: self)
            }
        }
    }
    
    /// Connect to the device.
    /// 
    /// This wraps the underlying INDIDevice.connect() method and ensures
    /// the observable state stays in sync with the registry.
    /// - Throws: An error if the connection fails or device is not found
    public func connect() async throws {
        // Get current device from registry
        guard var device = await registry.getDevice(name: deviceName) else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 1, 
                userInfo: [NSLocalizedDescriptionKey: "Device not found in registry: \(deviceName)"]
            )
        }
        
        // Call mutating method
        try device.connect()
        
        // Update in registry (this will trigger callbacks which sync observable state)
        await registry.updateDevice(device)
    }
    
    /// Disconnect from the device.
    /// 
    /// This wraps the underlying INDIDevice.disconnect() method.
    /// - Throws: An error if disconnection fails or device is not found
    public func disconnect() async throws {
        guard var device = await registry.getDevice(name: deviceName) else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 1, 
                userInfo: [NSLocalizedDescriptionKey: "Device not found in registry: \(deviceName)"]
            )
        }
        
        try device.disconnect()
        await registry.updateDevice(device)
    }
    
    /// Get a property by name.
    /// - Parameter name: The name of the property to get
    /// - Returns: The property if it exists, otherwise nil
    public func getProperty(name: INDIPropertyName) -> ObservableINDIProperty? {
        return properties.first(where: { $0.name == name })
    }
    
    /// Set a property value.
    /// 
    /// This function is specifically intended to be used by a client.
    /// It sets the target value and time stamp, and sends a message to the INDI server.
    /// - Parameter property: The property to set (must be an ObservableINDIProperty)
    /// - Throws: An error if the property is not found or cannot be set
    public func setProperty(_ observableProperty: ObservableINDIProperty) async throws {
        guard var device = await registry.getDevice(name: deviceName) else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 1, 
                userInfo: [NSLocalizedDescriptionKey: "Device not found in registry: \(deviceName)"]
            )
        }
        
        // Get the underlying property from the device
        guard let underlyingProperty = device.getProperty(name: observableProperty.name) else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 2, 
                userInfo: [NSLocalizedDescriptionKey: "Property not found: \(observableProperty.name)"]
            )
        }
        
        // Create a copy of the property with the target values from the observable property
        var propertyToSet = underlyingProperty
        propertyToSet.targetValues = observableProperty.targetValues
        propertyToSet.targetTimeStamp = observableProperty.targetTimeStamp
        
        // Update the device
        try await device.setProperty(property: propertyToSet)
        
        // Update in registry (this will trigger callbacks which sync observable state)
        await registry.updateDevice(device)
    }
}


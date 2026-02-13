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
    
    let registry: ObservableINDIStateRegistry
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
    
    /// Enable BLOB reception for a property.
    ///
    /// This sends an enableBLOB message to the server to enable BLOB data transmission
    /// for a specific property. BLOB reception must be enabled before capture starts.
    /// - Parameters:
    ///   - property: The property name
    ///   - state: The BLOB sending state (typically `.also` or `.on`)
    /// - Throws: An error if the device is not found or if sending fails
    public func enableBLOB(property: INDIPropertyName, state: BLOBSendingState) async throws {
        guard await registry.getDevice(name: deviceName) != nil else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Device not found in registry: \(deviceName)"]
            )
        }
        
        try await registry.enableBLOB(device: deviceName, property: property, state: state)
    }
    
    /// Capture an image with automatic BLOB reception and progress tracking.
    ///
    /// This is a convenience method that orchestrates the complete capture workflow:
    /// 1. Enables BLOB reception for the CCD1 property
    /// 2. Sets the exposure time
    /// 3. Starts progress tracking
    /// 4. Waits for the image to arrive
    ///
    /// - Parameters:
    ///   - exposureTime: The exposure time in seconds
    ///   - progress: Optional callback for progress updates (0.0 to 1.0)
    /// - Returns: The captured image data
    /// - Throws: An error if any step fails
    public func captureImage(exposureTime: Double, progress: (@Sendable (Double) -> Void)? = nil) async throws -> Data? {
        // Get CCD1 BLOB property
        guard let ccd1Property = getProperty(name: .ccd1) as? ObservableBLOBProperty else {
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "CCD1 property not found"]
            )
        }
        
        // Step 1: Enable BLOB reception
        try await ccd1Property.enableBLOBReception(state: .also)
        
        // Step 2: Start progress tracking
        let progressStream = try await ccd1Property.startProgressTracking(valueName: .ccd1)
        
        // Monitor progress in background (on the main actor)
        let progressTask = Task { @MainActor in
            do {
                for try await progressValue in progressStream {
                    progress?(progressValue)
                }
            } catch {
                // Stream finished with error, ignore for now
            }
        }
        
        // Step 3: Set exposure time to trigger capture
        guard let exposureProperty = getProperty(name: .ccdExposureTime) as? ObservableNumberProperty else {
            progressTask.cancel()
            throw NSError(
                domain: "ObservableINDIDevice",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "CCD_EXPOSURE property not found"]
            )
        }
        
        try await exposureProperty.setTargetNumberValue(name: .ccdExposureValue, exposureTime)
        
        // Step 4: Wait for image (automatically arrives after capture)
        let imageData = try await ccd1Property.waitForImage(valueName: .ccd1, timeout: exposureTime + 60)
        
        // Cancel progress task
        progressTask.cancel()
        
        return imageData
    }
}

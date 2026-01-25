import Foundation
import INDIProtocol
import os

public actor INDIStateRegistry {

    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIState", category: "INDIServerStateRegistry")

    public var server: INDIServer

    public private(set) var connected: Bool = false

    public var devices: [String: INDIDevice] = [:]
    
    /// Callback invoked when a device is created or updated
    private var onDeviceUpdate: ((String, INDIDevice) -> Void)?
    
    /// Callback invoked when a property is updated
    private var onPropertyUpdate: ((String, any INDIProperty) -> Void)?
    
    /// Set the callback for device updates
    public func setOnDeviceUpdate(_ callback: @escaping (String, INDIDevice) -> Void) {
        self.onDeviceUpdate = callback
    }
    
    /// Set the callback for property updates
    public func setOnPropertyUpdate(_ callback: @escaping (String, any INDIProperty) -> Void) {
        self.onPropertyUpdate = callback
    }

    public init(endpoint: INDIServerEndpoint) {
        self.server = INDIServer(endpoint: endpoint)
    }

    public func connect() async throws {
        try await server.connect()
        Self.logger.info("Connected to INDI server")
        connected = true
        
        Self.logger.info("Sending INDI handshake to establish connection")
        // Send handshake to establish connection
        try await server.sendHandshake()

        let messageStream = try await server.messages()
        do {
        for try await message in messageStream {
            handleMessage(message: message)
            }
            // Stream finished normally (connection closed)
            connected = false
        } catch {
            // Stream finished with error (connection lost)
            connected = false
            throw error
        }
    }

    public func disconnect() async throws {
        Self.logger.info("Disconnecting from INDI server")
        for deviceName in devices.keys {
            if var device = devices[deviceName] {
                try device.disconnect()
                devices[deviceName] = device
            }
        }
        await server.disconnect()
        Self.logger.info("Disconnected from INDI server")
        connected = false
    }

    public func registerDevice(device: INDIDevice) {
        devices[device.name] = device
        Self.logger.debug("Registered device: \(device.name, privacy: .public)")
    }

    private func handleMessage(message: INDIMessage) {
        Self.logger.debug("Received message: \(message.name?.displayName ?? "unknown", privacy: .public)")
        switch message {
        case .updateProperty(let updateProperty):
            handleStateProperty(updateProperty)
        case .defineProperty(let defineProperty):
            handleStateProperty(defineProperty)
        case .deleteProperty(let deleteProperty):
            handleDeleteProperty(deleteProperty)
        default:
            // The others are messages sent (not received) by the client
            // Note: pingRequest is automatically handled by INDIServer
            break
        }
    }

    private func createDevice(deviceName: String) -> INDIDevice {
        return INDIDevice(stateRegistry: self, name: deviceName)
    }

    private func handleStateProperty(_ stateProperty: INDIStateProperty) {
        var device = devices[stateProperty.device] 
        let isNewDevice = device == nil
        if device == nil {
            device = createDevice(deviceName: stateProperty.device)
        }
        guard var device = device else { return }
        let updatedProperty = createINDIProperty(stateProperty: stateProperty)
        device.updateProperty(property: updatedProperty)
        devices[stateProperty.device] = device
        
        // Invoke callbacks
        if isNewDevice {
            Self.logger.debug("Device \(stateProperty.device, privacy: .public) created")
            onDeviceUpdate?(stateProperty.device, device)
        }
        onPropertyUpdate?(stateProperty.device, updatedProperty)
    }

    private func handleDeleteProperty(_ deleteProperty: INDIDeleteProperty) {
        if let deviceName = deleteProperty.device {
            // If the device name is present
            if let propertyName = deleteProperty.name {
                // If the property name is present
                if var device = devices[deviceName] {
                    device.deleteProperty(name: propertyName)
                    devices[deviceName] = device
                    onDeviceUpdate?(deviceName, device)
                }
            } else {
                // If the property name is not present, we need to delete the device
                devices.removeValue(forKey: deviceName)
            }
        } else {
            // If the device name is not present, we need to delete all devices
            devices.removeAll()
        }
    }
    
    /// Process a message and update state (for use when not using the built-in message stream)
    public func processMessage(_ message: INDIMessage) {
        handleMessage(message: message)
    }

    public func sendTargetPropertyValues(device: INDIDevice, property: any INDIProperty) async throws {
        guard let targetValues = property.targetValues else {
            return
        }
        let setPropertyMessage = INDISetProperty(
            propertyType: property.type, 
            device: device.name, 
            name: property.name, 
            values: targetValues.map { $0.toINDIValue(type: property.type) }
        )
        try await server.send(.setProperty(setPropertyMessage))
    }

    private func createINDIProperty(stateProperty: INDIStateProperty) -> INDIProperty {
        switch stateProperty.propertyType {
        case .text:
            return TextProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .text(let stringValue) = value.value else {
                        return nil
                    }
                    return TextValue(name: value.name, label: value.label, textValue: stringValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .number:
            return NumberProperty(
                name: stateProperty.name,
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .number(let numberValue) = value.value else {
                        return nil
                    }
                    return NumberValue(
                        name: value.name,
                        label: value.label,
                        format: value.format,
                        min: value.min,
                        max: value.max,
                        step: value.step,
                        unit: value.unit,
                        numberValue: numberValue
                    )
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .toggle:
            return SwitchProperty(
                name: stateProperty.name,
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                rule: stateProperty.rule, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .boolean(let booleanValue) = value.value else {
                        return nil
                    }
                    return SwitchValue(name: value.name, label: value.label, switchValue: booleanValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .light:
            return LightProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .state(let stateValue) = value.value else {
                        return nil
                    }
                    return LightValue(name: value.name, label: value.label, lightValue: stateValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )   
        case .blob:
            return BLOBProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .blob(let blobValue) = value.value else {
                        return nil
                    }
                    return BLOBValue(
                        name: value.name,
                        label: value.label,
                        format: value.format,
                        size: value.size,
                        compressed: value.compressed,
                        blobValue: blobValue
                    )
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        }
    }

    func createAndSendSetPropertyMessage(device: INDIDevice, property: INDIProperty) async throws {
        let setPropertyMessage = INDISetProperty(
            propertyType: property.type, 
            device: device.name, 
            name: property.name, 
            values: property.values.map { $0.toINDIValue(type: property.type) }
        )
        try await server.send(.setProperty(setPropertyMessage))
    }
}

private extension PropertyValue {
    func toINDIValue(type: INDIPropertyType) -> INDIValue {
        switch type {
        case .text:
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                propertyType: .text
            )
        case .number:
            let numberValue = self as? NumberValue
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                format: numberValue?.format,
                min: numberValue?.min,
                max: numberValue?.max,
                step: numberValue?.step,
                unit: numberValue?.unit,
                propertyType: .number
            )
        case .toggle:
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                propertyType: .toggle
            )
        case .light:
            return INDIValue(
                name: name,
                value: self.value, 
                label: label,
                propertyType: .light
            )
        case .blob:
            let blobValue = self as? BLOBValue
            return INDIValue(
                name: name, 
                value: self.value, 
                label: label, 
                format: blobValue?.format,
                size: blobValue?.size,
                compressed: blobValue?.compressed,
                propertyType: .blob
            )
        }
    }
}

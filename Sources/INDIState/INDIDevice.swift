import Foundation
import INDIProtocol
import os

public struct INDIDevice: Sendable {

    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIState", category: "device")

    public let stateRegistry: INDIStateRegistry

    public let name: String

    public var properties: [INDIProperty] = []

    public enum ConnectionStatus {
        case disconnected
        case connected
        case connecting
        case disconnecting
    }

    public var connectionStatus: ConnectionStatus {
        guard let connectionProperty = self.getProperty(name: .connection) as? SwitchProperty else {
            return .disconnected
        }
        let currentValue = connectionProperty.switchValue(name: .connect)
        guard let targetValue = connectionProperty.targetSwitchValue(name: .connect) else {
            // No target value set - use current value to determine status
            return currentValue ? .connected : .disconnected
        }
        switch (currentValue, targetValue) {
        case (true, true):
            return .connected
        case (false, false):
            return .disconnected
        case (true, false):
            return .disconnecting
        case (false, true):
            return .connecting
        }
    }

    /// Connect to the device.
    /// 
    /// If the device is already connected, or,
    /// already in the process of connecting or disconnecting, this function does nothing.
    public mutating func connect() throws {
        guard var connectionProperty = self.getProperty(name: .connection) as? SwitchProperty else {
            return
        }
        let currentValue = connectionProperty.switchValue(name: .connect)
        let targetValue = connectionProperty.targetSwitchValue(name: .connect)
        // If already connected, or if there's a target value that differs from current (transitioning)
        if currentValue || (targetValue != nil && currentValue != targetValue) {
            // Already connected, or,
            // already in the process of connecting or disconnecting, should not change the target value
            return
        }
        // NB. No error should be thrown as there are only two possible values for the connect property.
        try? connectionProperty.setTargetSwitchValue(name: .connect, true)
        // Send a message to the INDI server to set the property
        self.sendTargetPropertyValues(property: connectionProperty)
    }

    /// Disconnect from the device.
    /// 
    /// If the device is already disconnected, or,
    /// already in the process of connecting or disconnecting, this function does nothing.
    public mutating func disconnect() throws {
        guard var connectionProperty = self.getProperty(name: .connection) as? SwitchProperty else {
            return
        }
        let currentValue = connectionProperty.switchValue(name: .connect)
        let targetValue = connectionProperty.targetSwitchValue(name: .connect)
        // If already disconnected, or if there's a target value that differs from current (transitioning)
        if !currentValue || (targetValue != nil && currentValue != targetValue) {
            // Already disconnected, or,
            // already in the process of connecting or disconnecting, should not change the target value
            return
        }
        try connectionProperty.setTargetSwitchValue(name: .connect, false)
        // Send a message to the INDI server to set the property
        self.sendTargetPropertyValues(property: connectionProperty)
    }

    /// Send the target property values to the INDI server.
    /// - Parameter property: The property to send the target values for.
    private func sendTargetPropertyValues(property: any INDIProperty) {
        Task.detached {
            do {
                try await self.stateRegistry.sendTargetPropertyValues(device: self, property: property)
            } catch {
                Self.logger.error("Error sending target property values: \(error)")
            }
        }
    }

    mutating func updateProperty(property: INDIProperty, isTarget: Bool = false) {
        Self.logger.debug("Updating property: \(property.name.displayName, privacy: .public) isTarget: \(isTarget)")
        // If the property already exists, update it
        if let index = properties.firstIndex(where: { $0.name == property.name }) {
            // If the property is a target property, i.e. was set by the client
            // then we need to update the target value and time stamp
            if isTarget {
                properties[index].targetValues = mergePropertyValues(
                    newValues: property.values,
                    existingValues: properties[index].targetValues ?? properties[index].values
                )
                properties[index].targetTimeStamp = property.timeStamp
            } else {
                properties[index].values = mergePropertyValues(
                    newValues: property.values,
                    existingValues: properties[index].values
                )
                properties[index].timeStamp = property.timeStamp
                properties[index].targetValues = nil
                properties[index].targetTimeStamp = nil
            }
        } else {
            // If the property does not exist, create it
            var newProperty = property
            if isTarget {
                newProperty.targetValues = property.values
                newProperty.targetTimeStamp = property.timeStamp
            }
            properties.append(newProperty)
        }
    }

    /// Merges new property values with existing ones, preserving attributes from
    /// existing values that may not be present in update messages.
    ///
    /// When an update message arrives, it typically only contains the new value
    /// but not the full attribute set (format, min, max, step, unit, label) that
    /// was provided in the original define message. This function preserves those
    /// attributes by merging from existing values.
    /// - Parameters:
    ///   - newValues: The new values from the update message
    ///   - existingValues: The existing values with full attribute metadata
    /// - Returns: An array of values with attributes merged from existing values
    private func mergePropertyValues(
        newValues: [any PropertyValue],
        existingValues: [any PropertyValue]
    ) -> [any PropertyValue] {
        return newValues.map { newValue in
            // Find existing value with same name
            guard let existingValue = existingValues.first(where: { $0.name == newValue.name }) else {
                return newValue
            }

            // Merge based on value type
            switch (newValue, existingValue) {
            case (let newNumber as NumberValue, let existingNumber as NumberValue):
                return newNumber.mergingAttributes(from: existingNumber)
            case (let newText as TextValue, let existingText as TextValue):
                return newText.mergingAttributes(from: existingText)
            case (let newSwitch as SwitchValue, let existingSwitch as SwitchValue):
                return newSwitch.mergingAttributes(from: existingSwitch)
            case (let newLight as LightValue, let existingLight as LightValue):
                return newLight.mergingAttributes(from: existingLight)
            case (let newBlob as BLOBValue, let existingBlob as BLOBValue):
                return newBlob.mergingAttributes(from: existingBlob)
            default:
                // Types don't match or unknown type, return new value as-is
                return newValue
            }
        }
    }

    /// Get a property by name.
    /// - Parameter name: The name of the property to get.
    /// - Returns: The property if it exists, otherwise nil.
    public func getProperty(name: INDIPropertyName) -> (any INDIProperty)? {
        return properties.first(where: { $0.name == name })
    }

    /// Set a property value. This function is specifically intended to be
    /// used by a client. It sets the target value and time stamp, and sends 
    /// a message to the INDI server to set the property.
    /// - Parameter property: The property to set.
    /// - Throws: An error if the property is not set.
    public mutating func setProperty(property: INDIProperty) async throws {
        guard getProperty(name: property.name) != nil else {
            throw NSError(domain: "INDIDevice", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Property not found"
            ])
        }
        self.updateProperty(property: property, isTarget: true)
        self.sendTargetPropertyValues(property: property)
    }

    /// Delete a property by name.
    /// 
    /// This is as response to a `delProperty` message from the INDI server.
    /// - Parameter name: The name of the property to delete.
    public mutating func deleteProperty(name: INDIPropertyName) {
        properties.removeAll(where: { $0.name == name })
    }
    
    // MARK: - Device Type Detection
    
    /// Predicts the device type based on the properties this device has.
    ///
    /// This function analyzes all properties of the device and counts how many
    /// properties belong to each device type. The device type with the most
    /// associated properties is returned as the predicted type.
    ///
    /// General properties (like `connection`, `devicePort`) that map to all device types
    /// are excluded from the count, as they don't provide specific device type information.
    ///
    /// If multiple device types have the same count, the first one (in enum order)
    /// is returned. If no device-specific properties are found, returns `.unknown`.
    ///
    /// - Returns: The predicted device type, or `.unknown` if no specific type can be determined.
    public func predictedDeviceType() -> INDIDeviceType {
        // General properties that map to all device types - exclude from counting
        let generalProperties: Set<INDIPropertyName> = [
            .connection, .devicePort, .localSideralTime, .universalTime,
            .geographicCoordinates, .atmosphere, .uploadMode, .uploadSettings, .activeDevices
        ]
        
        // Count properties for each device type (excluding general properties)
        var typeCounts: [INDIDeviceType: Int] = [:]
        
        for property in properties {
            // Skip general properties
            guard !generalProperties.contains(property.name) else {
                continue
            }
            
            let associatedTypes = property.name.associatedDeviceTypes()
            for deviceType in associatedTypes {
                typeCounts[deviceType, default: 0] += 1
            }
        }
        
        // If no device-specific properties found, return unknown
        guard !typeCounts.isEmpty else {
            return .unknown
        }
        
        // Find the device type with the highest count
        let maxCount = typeCounts.values.max() ?? 0
        let topTypes = typeCounts.filter { $0.value == maxCount }
        
        // If there's a clear winner, return it
        if topTypes.count == 1 {
            return topTypes.keys.first!
        }
        
        // If there's a tie, prefer telescope > camera > focuser > filterWheel > dome > others
        let priorityOrder: [INDIDeviceType] = [
            .telescope, .camera, .focuser, .filterWheel, .dome,
            .rotator, .gps, .weather, .lightBox, .inputInterface, .outputInterface
        ]
        
        for preferredType in priorityOrder {
            if topTypes.keys.contains(preferredType) {
                return preferredType
            }
        }
        
        // Fallback: return the first one alphabetically
        return topTypes.keys.sorted(by: { $0.rawValue < $1.rawValue }).first ?? .unknown
    }
}

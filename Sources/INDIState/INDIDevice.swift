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
                properties[index].targetValues = property.values
                properties[index].targetTimeStamp = property.timeStamp
            } else {
                properties[index].values = property.values
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
}

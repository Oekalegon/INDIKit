import Foundation
import INDIProtocol

public struct INDIDevice: Sendable {

    public let stateRegistry: INDIServerStateRegistry

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
        let targetValue = connectionProperty.targetSwitchValue(name: .connect)
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
        if currentValue || currentValue != targetValue {
            // Already connected, or,
            // already in the process of connecting or disconnecting, should not change the target value
            return
        }
        // NB. No error should be thrown as there are only two possible values for the connect property.
        try? connectionProperty.setTargetSwitchValue(name: .connect, true)
        // TODO: send a message to the INDI server to set the property
    }

    /// Disconnect from the device.
    /// 
    /// If the device is already disconnected, or,
    /// already in the process of connecting or disconnecting, this function does nothing.
    public mutating func disconnect() {
        guard var connectionProperty = self.getProperty(name: .connection) as? SwitchProperty else {
            return
        }
        let currentValue = connectionProperty.switchValue(name: .connect)
        let targetValue = connectionProperty.targetSwitchValue(name: .connect)
        if !currentValue || currentValue != targetValue {
            // Already disconnected, or,
            // already in the process of connecting or disconnecting, should not change the target value
            return
        }
        connectionProperty.setTargetSwitchValue(name: .connect, value: false)
        // TODO: send a message to the INDI server to set the property
    }

    mutating func updateProperty(property: INDIProperty, isTarget: Bool = false) {
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
        try await stateRegistry.createAndSendSetPropertyMessage(device: self, property: property)
    }

    /// Delete a property by name.
    /// 
    /// This is as response to a `delProperty` message from the INDI server.
    /// - Parameter name: The name of the property to delete.
    public mutating func deleteProperty(name: INDIPropertyName) {
        properties.removeAll(where: { $0.name == name })
    }
}

import Foundation
import INDIProtocol

public struct INDIDevice: Sendable {

    public let stateRegistry: INDIServerStateRegistry

    public let name: String

    public var properties: [INDIProperty] = []

    // public var connected: Bool {
    //     get {
    //         // Find the connection property and the connect value. If that is true, the device is connected.
    //         guard let connectionProperty = properties.first(where: { $0.name == .connection }) else {
    //             return false
    //         }
    //         guard let value = connectionProperty.values.first(where: { $0.name == .connect }) else {
    //             return false
    //         }
    //         return value.value == .boolean(true)
    //     }
    //     set {

    //     }
    // }

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
    public func getProperty(name: INDIPropertyName) -> INDIProperty? {
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

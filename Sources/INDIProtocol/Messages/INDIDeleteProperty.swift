import Foundation
import os

/// An INDI delete property message.
///
/// This message is sent by the server to the client to indicate that a property has been deleted.
/// Delete property messages can only be received, not sent.
/// 
/// It is used by the server to indicate that a property has become unavailable.
/// Delete property messages have two optional attributes: `device` and `name`.
/// - `device`: The device name to which the property belongs.
/// - `name`: The name of the property.
/// 
/// If both `device` and `name` are present, the property is deleted from the device.
/// If only `device` is present, all properties of the device are deleted.
/// If only `name` is present, an error will be logged, a property without a device
/// cannot be identified.
/// If none are present, all properties of all devices are deleted.
public struct INDIDeleteProperty: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")

    /// The operation type of this message. This is always `.delete`.
    public let operation: INDIOperation = .delete

    /// The device name to which the property belongs.
    public let device: String?

    /// The name of the property.
    public let name: INDIPropertyName?

    /// The diagnostics for the property. This is used to store any errors or warnings that occur when parsing the property.
    /// This is set by the parser and can be accessed by the client to get the errors or warnings.
    public private(set) var diagnostics: [INDIDiagnostics]

    /// Parse a delete property message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        // Check if element name is delProperty (matches .delete operation via prefix "del")
        guard xmlNode.name == "delProperty" else {
            return nil
        }

        let attrs = xmlNode.attributes
        self.device = attrs["device"]
        if let nameString = attrs["name"] {
            self.name = INDIParsingHelpers.extractProperty(from: nameString)
        } else {
            self.name = nil
        }
        self.diagnostics = []

        validate(attrs: attrs, children: xmlNode.children)
    }

    // MARK: - Validation

    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Error if name is present but device is not
        if name != nil && device == nil {
            let message = "delProperty has 'name' attribute but missing 'device' attribute which " +
                "is required when 'name' is present."
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &diagnostics)
        }

        // Warn about unexpected attributes (only device and name are allowed)
        let allowedAttributes = ["device", "name"]
        for (key, _) in attrs where !allowedAttributes.contains(key) {
            let message = "delProperty element contains unexpected attribute '\(key)'. " +
                "Only 'device' and 'name' are allowed."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }

        // Warn if delProperty has child elements (it shouldn't have any)
        if !children.isEmpty {
            let message = "delProperty element contains \(children.count) child element(s), " +
                "but delProperty should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }
    }
}

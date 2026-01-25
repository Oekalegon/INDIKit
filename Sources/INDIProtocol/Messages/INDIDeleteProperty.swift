import Foundation
import os

/// An INDI delete property message.
///
/// This message is sent by the server to the client to indicate that a property has been deleted.
/// Delete property messages can only be received, not sent.
public struct INDIDeleteProperty: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")

    public let operation: INDIOperation = .delete
    public let device: String?
    public let name: INDIPropertyName?
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

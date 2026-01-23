import Foundation
import os

/// An INDI getProperties message.
///
/// This message is sent by the client to the server to request property information.
/// Device and name are optional - if omitted, all properties are requested.
public struct INDIGetProperties: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
    
    public let operation: INDIOperation = .get
    public let device: String?
    public let name: INDIPropertyName?
    public let version: String
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// Create a getProperties message programmatically.
    ///
    /// - Parameters:
    ///   - device: Optional device name. If provided, requests properties for that device.
    ///   - name: Optional property name. If provided, requests that specific property.
    ///   - version: Optional INDI protocol version (defaults to "1.7")
    public init(
        device: String? = nil,
        name: INDIPropertyName? = nil,
        version: String = "1.7"
    ) {
        self.device = device
        self.name = name
        self.version = version
        self.diagnostics = []
        validateProgrammatic()
    }
    
    /// Parse a getProperties message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard xmlNode.name == "getProperties" else {
            return nil
        }
        
        let attrs = xmlNode.attributes
        self.device = attrs["device"]
        if let nameString = attrs["name"] {
            self.name = INDIParsingHelpers.extractProperty(from: nameString)
        } else {
            self.name = nil
        }
        self.version = attrs["version"] ?? "1.7"
        self.diagnostics = []
        
        validate(attrs: attrs, children: xmlNode.children)
    }
    
    // MARK: - Validation
    
    private mutating func validateProgrammatic() {
        // No validation needed for programmatic creation of getProperties
    }
    
    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Warn about unexpected attributes (only version, device, and name are allowed)
        let allowedAttributes = ["version", "device", "name"]
        for (key, _) in attrs where !allowedAttributes.contains(key) {
            let message = "getProperties element contains unexpected attribute '\(key)'. " +
                "Only 'version', 'device', and 'name' are allowed."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Warn if getProperties has child elements (it shouldn't have any)
        if !children.isEmpty {
            let message = "getProperties element contains \(children.count) child element(s), " +
                "but getProperties should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
    }
    
    // MARK: - XML Serialization
    
    internal func toXML() throws -> String {
        var xml = "<getProperties"
        
        // Add version attribute
        xml += " version='\(version)'"
        
        // Add device and name if specified (they are optional for getProperties)
        if let device = device, !device.isEmpty {
            xml += " device=\"\(escapeXML(device))\""
        }
        if let name = name {
            xml += " name=\"\(escapeXML(name.indiName))\""
        }
        
        xml += "/>"
        return xml
    }
}

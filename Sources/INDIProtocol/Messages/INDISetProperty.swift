import Foundation
import os

/// An INDI set property message (new* operations).
///
/// This message is sent by the client to the server to change the value of a property.
/// Set operations only support device, name, and values - no other attributes.
public struct INDISetProperty: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
    
    public let operation: INDIOperation = .set
    public let device: String
    public let name: INDIPropertyName
    public let propertyType: INDIPropertyType
    public let values: [INDIValue]
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// Create a set property message programmatically.
    ///
    /// - Parameters:
    ///   - propertyType: The type of property (e.g., `.text`, `.number`, `.toggle`)
    ///   - device: The device name (required)
    ///   - name: The property name (required)
    ///   - values: The property values (required)
    public init(
        propertyType: INDIPropertyType,
        device: String,
        name: INDIPropertyName,
        values: [INDIValue]
    ) {
        self.propertyType = propertyType
        self.device = device
        self.name = name
        self.values = values
        self.diagnostics = []
        validateProgrammatic()
    }
    
    /// Parse a set property message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard let op = INDIParsingHelpers.extractOperation(from: xmlNode.name), op == .set else {
            return nil
        }
        
        guard let propType = INDIParsingHelpers.extractPropertyType(from: xmlNode.name) else {
            Self.logger.warning(
                "Failed to parse INDI set property: could not extract property type from element '\(xmlNode.name)'"
            )
            return nil
        }
        
        let attrs = xmlNode.attributes
        // Set to "UNKNOWN" if missing so validation can run
        self.propertyType = propType
        self.device = attrs["device"] ?? "UNKNOWN"
        let nameString = attrs["name"] ?? "UNKNOWN"
        self.name = INDIParsingHelpers.extractProperty(from: nameString)
        
        // Parse child elements into INDIValue objects
        var parsedValues: [INDIValue] = []
        for child in xmlNode.children {
            if let value = INDIValue(
                xmlNode: child,
                propertyType: propType,
                propertyName: self.name
            ) {
                parsedValues.append(value)
            } else {
                Self.logger.warning(
                    "Failed to parse INDI value from element '\(child.name)' in property '\(nameString)'"
                )
            }
        }
        self.values = parsedValues
        
        self.diagnostics = []
        validate(attrs: attrs, children: xmlNode.children)
    }
    
    // MARK: - Validation
    
    private mutating func validateProgrammatic() {
        // Check if the property has at least one value, which is required
        if self.values.isEmpty {
            let message = "The property must have at least one value"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
    }
    
    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Set operations only support name and device attributes
        let allowedAttributes = ["device", "name"]
        let unexpectedAttrs = attrs.keys.filter { !allowedAttributes.contains($0) }
        if !unexpectedAttrs.isEmpty {
            let message = "Set (new) operations only support name and device. " +
                "This message has other attributes: \(unexpectedAttrs.joined(separator: ", "))"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Check if the property has at least one value, which is required
        if self.values.isEmpty {
            let message = "The property must have at least one value"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
    }
    
    // MARK: - XML Serialization
    
    internal func toXML() throws -> String {
        let elementName = "\(operation.rawValue)\(propertyType.rawValue)Vector"
        var xml = "<\(elementName)"
        
        xml += " device=\"\(escapeXML(device))\""
        xml += " name=\"\(escapeXML(name.indiName))\""
        xml += ">"
        
        // Add child elements (values)
        for value in values {
            xml += "\n"
            xml += try value.toXML(propertyType: propertyType)
        }
        
        // Close the tag
        xml += "\n</\(elementName)>"
        
        return xml
    }
}

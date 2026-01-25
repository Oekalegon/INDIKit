import Foundation
import os

/// An INDI define property message (def* operations).
///
/// This message is sent by the server to the client to define a property of a device or driver.
/// Define operations support all optional attributes like group, label, permissions, state, etc.
public struct INDIDefineProperty: INDIStateProperty, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")
    
    /// Known INDI property attributes.
    private static let knownAttributes = [
        "device", "group", "label", "name", "perm", "state", "timeout", "timestamp", "rule", "format"
    ]
    
    public let operation: INDIOperation = .define
    public let device: String
    public let name: INDIPropertyName
    public let propertyType: INDIPropertyType
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?
    public let timeStamp: Date?
    public let rule: INDISwitchRule?
    public let format: String?
    public let values: [INDIValue]
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// The parsed XML node representation containing the property structure.
    private let xmlNode: XMLNodeRepresentation
    
    /// Create a define property message programmatically.
    ///
    /// - Parameters:
    ///   - propertyType: The type of property (e.g., `.text`, `.number`, `.toggle`)
    ///   - device: The device name (required)
    ///   - name: The property name (required)
    ///   - values: The property values (required)
    ///   - group: Optional UI grouping hint
    ///   - label: Optional human-readable label
    ///   - permissions: Optional property permissions
    ///   - state: Optional property state
    ///   - timeout: Optional timeout in seconds
    ///   - timeStamp: Optional timestamp
    ///   - rule: Optional switch rule (only for toggle properties)
    ///   - format: Optional format string (only for blob properties)
    public init(
        propertyType: INDIPropertyType,
        device: String,
        name: INDIPropertyName,
        group: String? = nil,
        label: String? = nil,
        permissions: INDIPropertyPermissions? = nil,
        state: INDIStatus? = nil,
        timeout: Double? = nil,
        timeStamp: Date? = nil,
        rule: INDISwitchRule? = nil,
        format: String? = nil,
        values: [INDIValue]
    ) {
        self.propertyType = propertyType
        self.device = device
        self.name = name
        self.group = group
        self.label = label
        self.permissions = permissions
        self.state = state
        self.timeout = timeout
        self.timeStamp = timeStamp
        self.rule = rule
        self.format = format
        self.values = values
        self.diagnostics = []
        
        // Create XMLNodeRepresentation for internal use
        let elementName = "\(operation.rawValue)\(propertyType.rawValue)Vector"
        var attrs: [String: String] = [
            "device": device,
            "name": name.indiName
        ]
        
        if let group = group { attrs["group"] = group }
        if let label = label { attrs["label"] = label }
        if let permissions = permissions { attrs["perm"] = permissions.indiValue }
        if let state = state { attrs["state"] = state.indiValue }
        if let timeout = timeout { attrs["timeout"] = String(timeout) }
        if let timeStamp = timeStamp {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            attrs["timestamp"] = formatter.string(from: timeStamp)
        }
        if let rule = rule { attrs["rule"] = rule.rawValue }
        if let format = format { attrs["format"] = format }
        
        self.xmlNode = XMLNodeRepresentation(
            name: elementName,
            attributes: attrs,
            text: nil,
            children: []
        )
        
        validateProgrammatic()
    }
    
    /// Parse a define property message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard let op = INDIParsingHelpers.extractOperation(from: xmlNode.name), op == .define else {
            return nil
        }
        
        guard let propType = INDIParsingHelpers.extractPropertyType(from: xmlNode.name) else {
            Self.logger.warning(
                "Failed to parse INDI define property: could not extract property type from element '\(xmlNode.name)'"
            )
            return nil
        }
        
        let attrs = xmlNode.attributes
        // Set to "UNKNOWN" if missing so validation can run
        self.propertyType = propType
        self.device = attrs["device"] ?? "UNKNOWN"
        let nameString = attrs["name"] ?? "UNKNOWN"
        self.name = INDIParsingHelpers.extractProperty(from: nameString)
        self.group = attrs["group"]
        self.label = attrs["label"]
        self.permissions = attrs["perm"].map { INDIParsingHelpers.extractPermissions(from: $0) }
        self.state = attrs["state"].map { INDIParsingHelpers.extractState(from: $0) }
        self.timeout = INDIParsingHelpers.extractTimeout(from: attrs["timeout"])
        self.timeStamp = INDIParsingHelpers.extractTimestamp(from: attrs["timestamp"])
        self.rule = attrs["rule"].flatMap { INDISwitchRule(indiValue: $0) }
        self.format = attrs["format"]
        
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
        
        self.xmlNode = xmlNode
        self.diagnostics = []
        validate(attrs: attrs, children: xmlNode.children)
    }
    
    // MARK: - Validation
    
    private mutating func validateProgrammatic() {
        // Warn if property name is unknown
        if case .other(let name) = self.name {
            let message = "The property name '\(name)' is unknown"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Type-specific attribute validation
        // Light properties do not support permissions
        if self.permissions != nil && self.propertyType == .light {
            let message = "Permissions are ignored for light properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Light properties do not support timeout
        if self.timeout != nil && self.propertyType == .light {
            let message = "Timeout is ignored for light properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Non-switch properties do not support rule
        if self.rule != nil && self.propertyType != .toggle {
            let message = "Rule is ignored for non-switch properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Not-BLOB properties do not support format
        if self.format != nil && self.propertyType != .blob {
            let message = "Format is ignored for non-blob properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Check if the property has at least one value
        if self.values.isEmpty {
            let message = "The property must have at least one value"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Validate switch rules for toggle/switch properties
        if self.propertyType == .toggle, let rule = self.rule {
            validateSwitchRule(rule: rule)
        }
    }
    
    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Check if the device and name are known
        if device == "UNKNOWN" {
            let message = "Device is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        if name.indiName == "UNKNOWN" {
            let message = "The property name is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        } else if case .other(let nameString) = name {
            let message = "The property name '\(nameString)' is unknown"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Check all attrs if they are known in INDI
        let unknownAttrs = attrs.keys.filter { !Self.knownAttributes.contains($0) }
        let elementName = xmlNode.name
        for unknownAttr in unknownAttrs {
            let message = "Unknown attribute '\(unknownAttr)' in INDI property element '\(elementName)'"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Light properties do not support permissions
        if self.permissions != nil && propertyType == .light {
            let message = "Permissions are ignored for light properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Light properties do not support timeout
        if self.timeout != nil && propertyType == .light {
            let message = "Timeout is ignored for light properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Non-switch properties do not support rule
        if self.rule != nil && propertyType != .toggle {
            let message = "Rule is ignored for non-switch properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Not-BLOB properties do not support format
        if self.format != nil && propertyType != .blob {
            let message = "Format is ignored for non-blob properties"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Check if the property has at least one value
        if self.values.isEmpty {
            let message = "The property must have at least one value"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Validate switch rules for toggle/switch properties
        if propertyType == .toggle, let rule = self.rule {
            validateSwitchRule(rule: rule)
        }
    }
    
    /// Validate that switch values adhere to the specified rule.
    private mutating func validateSwitchRule(rule: INDISwitchRule) {
        // Count how many switches are On
        let onCount = self.values.filter { value in
            if case .boolean(let bool) = value.value {
                return bool
            }
            return false
        }.count
        
        switch rule {
        case .oneOfMany:
            // OneOfMany: exactly one switch must be On
            if onCount != 1 {
                let message = "Switch rule 'OneOfMany' requires exactly one switch to be On, " +
                    "but \(onCount) switch(es) are On"
                INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }
            
        case .atMostOne:
            // AtMostOne: at most one switch can be On (0 or 1)
            if onCount > 1 {
                let message = "Switch rule 'AtMostOne' allows at most one switch to be On, " +
                    "but \(onCount) switch(es) are On"
                INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }
            
        case .anyOfMany:
            // AnyOfMany: any combination is allowed, no validation needed
            break
        }
    }
    
    // MARK: - XML Serialization
    
    internal func toXML() throws -> String {
        let elementName = xmlNode.name
        var xml = "<\(elementName)"
        
        // Include all attributes
        for (key, value) in xmlNode.attributes.sorted(by: { $0.key < $1.key }) {
            xml += " \(key)=\"\(escapeXML(value))\""
        }
        
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

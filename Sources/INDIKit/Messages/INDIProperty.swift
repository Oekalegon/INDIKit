import Foundation
import os

/// An INDI property parsed from XML.
///
/// INDI properties are parsed from XML but expose only structured data,
/// not raw XML strings. This provides a clean, type-safe API for working
/// with INDI protocol properties such as property definitions, updates, and commands.
public struct INDIProperty: Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
    
    /// The parsed XML node representation containing the property structure.
    let xmlNode: XMLNodeRepresentation
    
    public let operation: INDIPropertyOperation
    /// Property type. Optional for `.get` (getProperties) operations, required for all others.
    public let propertyType: INDIPropertyType?
    /// Device name. Optional for `.get` (getProperties) operations, required for all others.
    public let device: String?
    /// Property name. Optional for `.get` (getProperties) operations, required for all others.
    public let name: INDIPropertyName?
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIState?
    public let timeout: Double?
    public let timeStamp: Date?
    
    /// Rule for switch properties (only applicable to toggle/switch properties).
    ///
    /// Determines how multiple switches in a switch vector interact.
    public let rule: INDISwitchRule?
    
    /// Format for blob properties (only applicable to blob properties).
    ///
    /// Specifies the format of the blob data (e.g., ".fits", ".jpg", ".png").
    public let format: String?
    
    /// The parsed values contained in this property.
    public let values: [INDIValue]

    /// Diagnostic messages for the property.
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// Create a getProperties INDI property.
    ///
    /// - Parameters:
    ///   - device: Optional device name. If provided, requests properties for that device.
    ///   - name: Optional property name. If provided, requests that specific property.
    ///   - version: Optional INDI protocol version (defaults to "1.7")
    public init(
        operation: INDIPropertyOperation,
        device: String? = nil,
        name: INDIPropertyName? = nil,
        version: String = "1.7"
    ) {
        guard operation == .get else {
            fatalError(
                "This initializer is only for .get operations. " +
                "Use init(operation:propertyType:device:name:...) for other operations."
            )
        }
        
        self.operation = operation
        self.propertyType = nil
        self.device = device
        self.name = name
        self.group = nil
        self.label = nil
        self.permissions = nil
        self.state = nil
        self.timeout = nil
        self.timeStamp = nil
        self.rule = nil
        self.format = nil
        self.values = []
        self.diagnostics = []
        
        // Create XMLNodeRepresentation for getProperties
        var attrs: [String: String] = ["version": version]
        if let device = device {
            attrs["device"] = device
        }
        if let name = name {
            attrs["name"] = name.indiName
        }
        
        self.xmlNode = XMLNodeRepresentation(
            name: "getProperties",
            attributes: attrs,
            text: nil,
            children: []
        )
        
        self.validateProgrammatic()
    }
    
    /// Create an INDI property for operations other than getProperties.
    ///
    /// - Parameters:
    ///   - operation: The INDI operation (`.define`, `.set`, `.update`, `.enableBlob`, etc.)
    ///   - propertyType: The type of property (e.g., `.text`, `.number`, `.toggle`)
    ///   - device: The device name (required)
    ///   - name: The property name (required)
    ///   - values: The property values
    ///   - group: Optional UI grouping hint
    ///   - label: Optional human-readable label
    ///   - permissions: Optional property permissions
    ///   - state: Optional property state
    ///   - timeout: Optional timeout in seconds
    ///   - timeStamp: Optional timestamp
    ///   - rule: Optional switch rule (only for toggle properties)
    ///   - format: Optional format string (only for blob properties)
    public init(
        operation: INDIPropertyOperation,
        propertyType: INDIPropertyType,
        device: String,
        name: INDIPropertyName,
        group: String? = nil,
        label: String? = nil,
        permissions: INDIPropertyPermissions? = nil,
        state: INDIState? = nil,
        timeout: Double? = nil,
        timeStamp: Date? = nil,
        rule: INDISwitchRule? = nil,
        format: String? = nil,
        values: [INDIValue]
    ) {
        guard operation != .get else {
            fatalError(
                "This initializer is not for .get operations. " +
                "Use init(operation:device:name:version:) for getProperties."
            )
        }
        
        self.operation = operation
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
        
        // Create a minimal XMLNodeRepresentation for internal use
        // Special handling for enableBLOB which doesn't follow the vector pattern
        let elementName: String
        if operation == .enableBlob {
            elementName = "enableBLOB"
        } else {
            elementName = "\(operation.rawValue)\(propertyType.rawValue)Vector"
        }
        
        var attrs: [String: String] = [
            "device": device,
            "name": name.indiName
        ]
        
        // Add other attributes only for non-get operations
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
        
        self.validateProgrammatic()
    }
    
    init?(xmlNode: XMLNodeRepresentation) {
        self.xmlNode = xmlNode
        
        guard let op = Self.extractOperation(from: xmlNode.name) else {
            Self.logger.warning(
                "Failed to parse INDI property: could not extract operation from element '\(xmlNode.name)'"
            )
            return nil
        }
        self.operation = op
        
        // For getProperties, propertyType is not required
        let propType: INDIPropertyType?
        if op == .get {
            self.propertyType = nil
            propType = nil
        } else {
            guard let extractedPropType = Self.extractPropertyType(from: xmlNode.name) else {
                Self.logger.warning(
                    "Failed to parse INDI property: could not extract property type from element '\(xmlNode.name)'"
                )
                return nil
            }
            self.propertyType = extractedPropType
            propType = extractedPropType
        }
        
        let attrs = xmlNode.attributes
        // For getProperties, device and name are optional
        if op == .get {
            self.device = attrs["device"]
            if let nameString = attrs["name"] {
                self.name = Self.extractProperty(from: nameString)
            } else {
                self.name = nil
            }
        } else {
            self.device = attrs["device"] ?? "UNKNOWN"
            self.name = Self.extractProperty(from: attrs["name"] ?? "UNKNOWN")
        }
        self.group = attrs["group"]
        self.label = attrs["label"]
        self.permissions = attrs["perm"].map { Self.extractPermissions(from: $0) }
        self.state = attrs["state"].map { Self.extractState(from: $0) }
        self.timeout = Self.extractTimeout(from: attrs["timeout"])
        self.timeStamp = Self.extractTimestamp(from: attrs["timestamp"])
        self.rule = attrs["rule"].flatMap { INDISwitchRule(indiValue: $0) }
        self.format = attrs["format"]
        
        // Parse child elements into INDIValue objects
        // Note: getProperties don't have values, so this should only run for other operations
        var parsedValues: [INDIValue] = []
        for child in xmlNode.children {
            // For getProperties, we don't have a property type, so use .text as default
            let propTypeForValue = propType ?? .text
            // When parsing from XML, we should always have a property name (even if unknown)
            // For getProperties, name can be nil, but getProperties don't have values anyway
            let nameString = attrs["name"] ?? "UNKNOWN"
            let propertyNameForValue = self.name ?? Self.extractProperty(from: nameString)
            if let value = INDIValue(
                xmlNode: child,
                propertyType: propTypeForValue,
                propertyName: propertyNameForValue
            ) {
                parsedValues.append(value)
            } else {
                let propertyName = self.name?.indiName ?? attrs["name"] ?? "unknown"
                Self.logger.warning(
                    "Failed to parse INDI value from element '\(child.name)' in property '\(propertyName)'"
                )
            }
        }
        self.values = parsedValues

        self.diagnostics = []
        validate(attrs: attrs, children: xmlNode.children)
    }

    // MARK: - Validation

    /// Known INDI property attributes.
    private static let knownAttributes = [
        "device", "group", "label", "name", "perm", "state", "timeout", "timestamp", "rule", "format"
    ]

    /// Validate a programmatically created property.
    ///
    /// This validation skips checks that don't apply to programmatic creation:
    /// - Device/name presence (user explicitly provides them)
    /// - Unknown XML attributes (no XML to validate)
    /// - Set operation extra attributes (no XML attributes to check)
    ///
    /// But still validates:
    /// - Unknown property name warnings
    /// - Type-specific attribute usage (permissions on light, etc.)
    /// - At least one value requirement
    /// - Switch rule compliance
    private mutating func validateProgrammatic() {
        let operationsToSkip = [INDIPropertyOperation.get, .message, .ping, .pingReply, .delete, .enableBlob]
        if operationsToSkip.contains(self.operation) {
            let operationValue = self.operation.rawValue
            let message = "Validation skipped for operation: \(operationValue)"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
            return
        }
        
        // Warn if property name is unknown (still useful for programmatic creation)
        if case .other(let name) = self.name {
            let message = "The property name '\(name)' is unknown"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }

        // Type-specific attribute validation (still applies)
        if self.operation == .update || self.operation == .define {
            // Light properties do not support permissions.
            if self.permissions != nil && self.propertyType == .light {
                let message = "Permissions are ignored for light properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Light properties do not support timeout.
            if self.timeout != nil && self.propertyType == .light {
                let message = "Timeout is ignored for light properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Non-switch properties do not support rule.
            if self.rule != nil && self.propertyType != .toggle {
                let message = "Rule is ignored for non-switch properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Not-BLOB properties do not support format.
            if self.format != nil && self.propertyType != .blob {
                let message = "Format is ignored for non-blob properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }
        }

        // Check if the property has at least one value, which is required for all properties.
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
        // Special validation for getProperties
        if self.operation == .get {
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
            return
        }
        
        let operationsToSkip = [INDIPropertyOperation.message, .ping, .pingReply, .delete, .enableBlob]
        if operationsToSkip.contains(self.operation) {
            let operationValue = self.operation.rawValue
            let message = "Validation skipped for operation: \(operationValue)"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
            return
        }
        
        // Check if the device and name are known, as they are required and must be set.
        // (Skip for getProperties where they are optional)
        if let device = self.device, device == "UNKNOWN" {
            let message = "Device is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        } else if self.device == nil && self.operation != .get {
            let message = "Device is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        if let name = self.name {
            if name.indiName == "UNKNOWN" {
                let message = "The property name is required but not found"
                INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
            } else if case .other(let nameString) = name {
                let message = "The property name '\(nameString)' is unknown"
                INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }
        } else if self.operation != .get {
            let message = "The property name is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }

        // Update and set operations are the only ones that can properties other than
        // name and device.
        if let propType = self.propertyType, self.operation == .update || self.operation == .define {

            // Check all attrs if they are known in INDI
            let unknownAttrs = attrs.keys.filter { !Self.knownAttributes.contains($0) }
            let elementName = xmlNode.name
            for unknownAttr in unknownAttrs {
                let message = "Unknown attribute '\(unknownAttr)' in INDI property element '\(elementName)'"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Light properties do not support permissions.
            if self.permissions != nil && propType == .light {
                let message = "Permissions are ignored for light properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Light properties do not support timeout.
            if self.timeout != nil && propType == .light {
                let message = "Timeout is ignored for light properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Non-switch properties do not support rule.
            if self.rule != nil && propType != .toggle {
                let message = "Rule is ignored for non-switch properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

            // Not-BLOB properties do not support format.
            if self.format != nil && propType != .blob {
                let message = "Format is ignored for non-blob properties"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }
        } else if self.operation == .set {
            let message = "Set (new) operations only support name and device. " +
                "This message has other attributes: \(attrs.keys.joined(separator: ", "))"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }

        // Check if the property has at least one value, which is required for all properties.
        if self.values.isEmpty {
            let message = "The property must have at least one value"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Validate switch rules for toggle/switch properties
        if let propType = self.propertyType, propType == .toggle, let rule = self.rule {
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
    
    // MARK: - Private Helpers
    
    private static func extractOperation(from elementName: String) -> INDIPropertyOperation? {
        INDIPropertyOperation(elementName: elementName) ?? .update
    }
    
    private static func extractPropertyType(from elementName: String) -> INDIPropertyType? {
        INDIPropertyType(elementName: elementName) ?? .text
    }
    
    private static func extractProperty(from name: String) -> INDIPropertyName {
        INDIPropertyName(indiName: name)
    }
    
    private static func extractPermissions(from permString: String) -> INDIPropertyPermissions {
        INDIPropertyPermissions(indiValue: permString)
    }
    
    private static func extractState(from stateString: String) -> INDIState {
        INDIState(indiValue: stateString)
    }
    
    private static func extractTimeout(from timeoutString: String?) -> Double? {
        guard let timeoutString, let timeoutValue = Double(timeoutString) else {
            return nil
        }
        return timeoutValue
    }
    
    private static func extractTimestamp(from timestampString: String?) -> Date? {
        guard let timestampString else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestampString) {
            return date
        }
        if let unixTimestamp = Double(timestampString) {
            return Date(timeIntervalSince1970: unixTimestamp)
        }
        return nil
    }
}

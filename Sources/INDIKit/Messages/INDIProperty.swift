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
    public let propertyType: INDIPropertyType
    public let device: String
    public let name: INDIPropertyName
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIPropertyState?
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
    
    init?(xmlNode: XMLNodeRepresentation) {
        self.xmlNode = xmlNode
        
        guard let op = Self.extractOperation(from: xmlNode.name) else {
            Self.logger.warning(
                "Failed to parse INDI property: could not extract operation from element '\(xmlNode.name)'"
            )
            return nil
        }
        self.operation = op
        
        guard let propType = Self.extractPropertyType(from: xmlNode.name) else {
            Self.logger.warning(
                "Failed to parse INDI property: could not extract property type from element '\(xmlNode.name)'"
            )
            return nil
        }
        self.propertyType = propType
        
        let attrs = xmlNode.attributes
        self.device = attrs["device"] ?? "UNKNOWN"
        self.group = attrs["group"]
        self.label = attrs["label"]
        self.name = Self.extractProperty(from: attrs["name"] ?? "UNKNOWN")
        self.permissions = attrs["perm"].map { Self.extractPermissions(from: $0) }
        self.state = attrs["state"].map { Self.extractState(from: $0) }
        self.timeout = Self.extractTimeout(from: attrs["timeout"])
        self.timeStamp = Self.extractTimestamp(from: attrs["timestamp"])
        self.rule = attrs["rule"].flatMap { INDISwitchRule(indiValue: $0) }
        self.format = attrs["format"]
        
        // Parse child elements into INDIValue objects
        var parsedValues: [INDIValue] = []
        for child in xmlNode.children {
            if let value = INDIValue(xmlNode: child, propertyType: propType, propertyName: self.name) {
                parsedValues.append(value)
            } else {
                let propertyName = attrs["name"] ?? "unknown"
                Self.logger.warning(
                    "Failed to parse INDI value from element '\(child.name)' in property '\(propertyName)'"
                )
            }
        }
        self.values = parsedValues

        self.diagnostics = []
        validate(attrs: attrs)
    }

    // MARK: - Validation

    /// Known INDI property attributes.
    private static let knownAttributes = [
        "device", "group", "label", "name", "perm", "state", "timeout", "timestamp", "rule", "format"
    ]

    private mutating func validate(attrs: [String: String]) {

        let operationsToSkip = [INDIPropertyOperation.get, .message, .ping, .pingReply, .delete, .enableBlob]
        if operationsToSkip.contains(self.operation) {
            let operationValue = self.operation.rawValue
            let message = "Validation skipped for operation: \(operationValue)"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
            return
        }
        
        // Check if the device and name are known, as they are required and must be set.
        if self.device == "UNKNOWN" {
            let message = "Device is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        if self.name.indiName == "UNKNOWN" {
            let message = "The property name is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        } else if case .other(let name) = self.name {
            let message = "The property name '\(name)' is unknown"
            INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }

        // Update and set operations are the only ones that can properties other than
        // name and device.
        if self.operation == .update || self.operation == .define {

            // Check all attrs if they are known in INDI
            let unknownAttrs = attrs.keys.filter { !Self.knownAttributes.contains($0) }
            let elementName = xmlNode.name
            for unknownAttr in unknownAttrs {
                let message = "Unknown attribute '\(unknownAttr)' in INDI property element '\(elementName)'"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
            }

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
    
    private static func extractState(from stateString: String) -> INDIPropertyState {
        INDIPropertyState(indiValue: stateString)
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

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
    
    public let operation: INDIMessageOperation
    public let propertyType: INDIPropertyType
    public let device: String
    public let property: INDIPropertyName
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
        self.device = attrs["device"] ?? ""
        self.group = attrs["group"]
        self.label = attrs["label"]
        self.property = Self.extractProperty(from: attrs["name"] ?? "")
        self.permissions = attrs["perm"].map { Self.extractPermissions(from: $0) }
        self.state = attrs["state"].map { Self.extractState(from: $0) }
        self.timeout = Self.extractTimeout(from: attrs["timeout"])
        self.timeStamp = Self.extractTimestamp(from: attrs["timestamp"])
        self.rule = attrs["rule"].flatMap { INDISwitchRule(indiValue: $0) }
        self.format = attrs["format"]
        
        // Parse child elements into INDIValue objects
        var parsedValues: [INDIValue] = []
        for child in xmlNode.children {
            if let value = INDIValue(xmlNode: child, propertyType: propType) {
                parsedValues.append(value)
            } else {
                let propertyName = attrs["name"] ?? "unknown"
                Self.logger.warning(
                    "Failed to parse INDI value from element '\(child.name)' in property '\(propertyName)'"
                )
            }
        }
        self.values = parsedValues
    }
    
    // MARK: - Private Helpers
    
    private static func extractOperation(from elementName: String) -> INDIMessageOperation? {
        INDIMessageOperation(elementName: elementName) ?? .update
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

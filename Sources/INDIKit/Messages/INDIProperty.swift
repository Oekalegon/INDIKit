import Foundation

/// An INDI property parsed from XML.
///
/// INDI properties are parsed from XML but expose only structured data,
/// not raw XML strings. This provides a clean, type-safe API for working
/// with INDI protocol properties such as property definitions, updates, and commands.
public struct INDIProperty: Sendable {
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
    
    init?(xmlNode: XMLNodeRepresentation) {
        self.xmlNode = xmlNode
        
        guard let op = Self.extractOperation(from: xmlNode.name) else {
            return nil
        }
        self.operation = op
        
        guard let propType = Self.extractPropertyType(from: xmlNode.name) else {
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

import Foundation

/// A Sendable representation of an XML element.
public struct XMLNodeRepresentation: Sendable {
    public let name: String
    public let attributes: [String: String]
    public let text: String?
    public let children: [XMLNodeRepresentation]
    
    public init(name: String, attributes: [String: String] = [:], text: String? = nil, children: [XMLNodeRepresentation] = []) {
        self.name = name
        self.attributes = attributes
        self.text = text
        self.children = children
    }
}

/// Base protocol for all INDI messages.
///
/// INDI messages are parsed from XML but expose only structured data,
/// not raw XML strings. This provides a clean, type-safe API for working
/// with INDI protocol messages such as property definitions, updates, and commands.
public protocol INDIMessage: Sendable {

    var operation: INDIMessageOperation { get }
    var propertyType: INDIPropertyType { get }
    var device: String { get }
    var group: String { get }
    var label: String { get }
    var property: INDIProperty { get }
    var permissions: INDIPropertyPermissions { get }
    var state: INDIPropertyState { get }
    var timeout: Double { get }
    var timeStamp: Date { get }

    /// The XML element name of this message type.
    static var elementName: String { get }
    
    /// Initialize a message from an XML node representation.
    init?(xmlNode: XMLNodeRepresentation)
}

/// A raw XML message that hasn't been parsed into a specific message type yet.
///
/// This message type contains the parsed XML structure but not the original XML string.
/// Use the `xmlNode` property to access the structured data.
public struct RawINDIMessage: INDIMessage, Sendable {
    public static let elementName = ""
    
    /// The parsed XML node representation containing the message structure.
    public let xmlNode: XMLNodeRepresentation
    
    // MARK: - INDIMessage Protocol Requirements
    
    public let operation: INDIMessageOperation
    public let propertyType: INDIPropertyType
    public let device: String
    public let group: String
    public let label: String
    public let property: INDIProperty
    public let permissions: INDIPropertyPermissions
    public let state: INDIPropertyState
    public let timeout: Double
    public let timeStamp: Date
    
    public init?(xmlNode: XMLNodeRepresentation) {
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
        self.group = attrs["group"] ?? ""
        self.label = attrs["label"] ?? ""
        self.property = Self.extractProperty(from: attrs["name"] ?? "")
        self.permissions = Self.extractPermissions(from: attrs["perm"] ?? "rw")
        self.state = Self.extractState(from: attrs["state"] ?? "Idle")
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
    
    private static func extractProperty(from name: String) -> INDIProperty {
        INDIProperty(indiName: name)
    }
    
    private static func extractPermissions(from permString: String) -> INDIPropertyPermissions {
        INDIPropertyPermissions(indiValue: permString)
    }
    
    private static func extractState(from stateString: String) -> INDIPropertyState {
        INDIPropertyState(indiValue: stateString)
    }
    
    private static func extractTimeout(from timeoutString: String?) -> Double {
        guard let timeoutString, let timeoutValue = Double(timeoutString) else {
            return 0.0
        }
        return timeoutValue
    }
    
    private static func extractTimestamp(from timestampString: String?) -> Date {
        guard let timestampString else {
            return Date()
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestampString) {
            return date
        }
        if let unixTimestamp = Double(timestampString) {
            return Date(timeIntervalSince1970: unixTimestamp)
        }
        return Date()
    }
}

import Foundation

/// An INDI message wrapper that unifies all message types.
///
/// This enum wraps different command types (getProperties, set, update, define, enableBLOB)
/// into a single type for use in streams and parsing. It provides computed properties that delegate
/// to the wrapped type, allowing code to work with `INDIMessage` without needing to know the
/// specific type.
public enum INDIMessage: Sendable {
    case getProperties(INDIGetProperties)
    case setProperty(INDISetProperty)
    case updateProperty(INDIUpdateProperty)
    case defineProperty(INDIDefineProperty)
    case enableBlob(INDIEnableBlob)
    case serverMessage(INDIServerMessage)
    case deleteProperty(INDIDeleteProperty)
    case ping(INDIPing)
    case pingReply(INDIPingReply)
    
    /// The operation type of this message.
    public var operation: INDIOperation {
        switch self {
        case .getProperties(let prop): return prop.operation
        case .setProperty(let prop): return prop.operation
        case .updateProperty(let prop): return prop.operation
        case .defineProperty(let prop): return prop.operation
        case .enableBlob(let prop): return prop.operation
        case .serverMessage(let msg): return msg.operation
        case .deleteProperty(let prop): return prop.operation
        case .ping(let ping): return ping.operation
        case .pingReply(let reply): return reply.operation
        }
    }
    
    /// Diagnostic messages for the message.
    public var diagnostics: [INDIDiagnostics] {
        switch self {
        case .getProperties(let prop): return prop.diagnostics
        case .setProperty(let prop): return prop.diagnostics
        case .updateProperty(let prop): return prop.diagnostics
        case .defineProperty(let prop): return prop.diagnostics
        case .enableBlob(let prop): return prop.diagnostics
        case .serverMessage(let msg): return msg.diagnostics
        case .deleteProperty(let prop): return prop.diagnostics
        case .ping(let ping): return ping.diagnostics
        case .pingReply(let reply): return reply.diagnostics
        }
    }
    
    /// Device name (optional for getProperties, required for others).
    public var device: String? {
        switch self {
        case .getProperties(let prop): return prop.device
        case .setProperty(let prop): return prop.device
        case .updateProperty(let prop): return prop.device
        case .defineProperty(let prop): return prop.device
        case .enableBlob(let prop): return prop.device
        case .serverMessage(let msg): return msg.device
        case .deleteProperty(let prop): return prop.device
        case .ping, .pingReply: return nil
        }
    }
    
    /// Property name (optional for getProperties, required for others).
    public var name: INDIPropertyName? {
        switch self {
        case .getProperties(let prop): return prop.name
        case .setProperty(let prop): return prop.name
        case .updateProperty(let prop): return prop.name
        case .defineProperty(let prop): return prop.name
        case .enableBlob(let prop): return prop.name
        case .serverMessage, .ping, .pingReply: return nil
        case .deleteProperty(let prop): return prop.name
        }
    }
    
    /// Property type (nil for getProperties and enableBLOB, required for others).
    public var propertyType: INDIPropertyType? {
        switch self {
        case .getProperties, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .setProperty(let prop): return prop.propertyType
        case .updateProperty(let prop): return prop.propertyType
        case .defineProperty(let prop): return prop.propertyType
        }
    }
    
    /// The parsed values contained in this property (empty for getProperties and enableBLOB).
    public var values: [INDIValue] {
        switch self {
        case .getProperties, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return []
        case .setProperty(let prop): return prop.values
        case .updateProperty(let prop): return prop.values
        case .defineProperty(let prop): return prop.values
        }
    }
    
    /// Group (only for update and define properties).
    public var group: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.group
        case .defineProperty(let prop): return prop.group
        }
    }
    
    /// Label (only for update and define properties).
    public var label: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.label
        case .defineProperty(let prop): return prop.label
        }
    }
    
    /// Permissions (only for update and define properties).
    public var permissions: INDIPropertyPermissions? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.permissions
        case .defineProperty(let prop): return prop.permissions
        }
    }
    
    /// State (only for update and define properties).
    public var state: INDIStatus? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.state
        case .defineProperty(let prop): return prop.state
        }
    }
    
    /// Timeout (only for update and define properties).
    public var timeout: Double? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.timeout
        case .defineProperty(let prop): return prop.timeout
        }
    }
    
    /// Timestamp (only for update and define properties).
    public var timeStamp: Date? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.timeStamp
        case .defineProperty(let prop): return prop.timeStamp
        case .serverMessage(let msg): return msg.timeStamp
        }
    }
    
    /// Rule for switch properties (only for update and define toggle properties).
    public var rule: INDISwitchRule? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.rule
        case .defineProperty(let prop): return prop.rule
        }
    }
    
    /// Format for blob properties (only for update and define blob properties).
    public var format: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .updateProperty(let prop): return prop.format
        case .defineProperty(let prop): return prop.format
        }
    }
    
    /// BLOB sending state (only for enableBLOB properties).
    public var blobSendingState: BLOBSendingState? {
        switch self {
        case .getProperties, .setProperty, .updateProperty, .defineProperty,
             .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        case .enableBlob(let prop): return prop.blobSendingState
        }
    }
    
    /// Version (only for getProperties).
    public var version: String? {
        switch self {
        case .getProperties(let prop): return prop.version
        case .setProperty, .updateProperty, .defineProperty, .enableBlob,
             .serverMessage, .deleteProperty, .ping, .pingReply: return nil
        }
    }
    
    /// Message text (only for server messages).
    public var messageText: String? {
        switch self {
        case .serverMessage(let msg): return msg.message
        case .getProperties, .setProperty, .updateProperty, .defineProperty,
             .enableBlob, .deleteProperty, .ping, .pingReply: return nil
        }
    }
    
    /// Parse an INDI message from XML.
    ///
    /// This factory method determines the operation type from the XML element name
    /// and creates the appropriate command type.
    ///
    /// - Parameter xmlNode: The XML node representation to parse
    /// - Returns: A parsed `INDIMessage` if successful, nil otherwise
    init?(xmlNode: XMLNodeRepresentation) {
        // Try special cases first (they don't follow the standard pattern)
        if let message = Self.parseSpecialCase(xmlNode: xmlNode) {
            self = message
            return
        }
        
        // Determine operation from element name
        guard let operation = INDIOperation(elementName: xmlNode.name) else {
            return nil
        }
        
        // Parse based on operation type
        guard let message = Self.parseOperation(operation: operation, xmlNode: xmlNode) else {
            return nil
        }
        self = message
    }
    
    // MARK: - Parsing Helpers
    
    /// Parse special case messages that don't follow the standard operation pattern.
    private static func parseSpecialCase(xmlNode: XMLNodeRepresentation) -> INDIMessage? {
        switch xmlNode.name {
        case "getProperties":
            return INDIGetProperties(xmlNode: xmlNode).map { .getProperties($0) }
        case "enableBLOB":
            return INDIEnableBlob(xmlNode: xmlNode).map { .enableBlob($0) }
        default:
            return nil
        }
    }
    
    /// Parse a message based on operation type.
    private static func parseOperation(
        operation: INDIOperation,
        xmlNode: XMLNodeRepresentation
    ) -> INDIMessage? {
        switch operation {
        case .get:
            return INDIGetProperties(xmlNode: xmlNode).map { .getProperties($0) }
        case .set:
            return INDISetProperty(xmlNode: xmlNode).map { .setProperty($0) }
        case .update:
            return INDIUpdateProperty(xmlNode: xmlNode).map { .updateProperty($0) }
        case .define:
            return INDIDefineProperty(xmlNode: xmlNode).map { .defineProperty($0) }
        case .enableBlob:
            return INDIEnableBlob(xmlNode: xmlNode).map { .enableBlob($0) }
        case .message:
            return INDIServerMessage(xmlNode: xmlNode).map { .serverMessage($0) }
        case .delete:
            return INDIDeleteProperty(xmlNode: xmlNode).map { .deleteProperty($0) }
        case .ping:
            // Ping messages are send-only, cannot be parsed from XML
            return nil
        case .pingReply:
            return INDIPingReply(xmlNode: xmlNode).map { .pingReply($0) }
        }
    }
    
    /// Serialize this message to XML string format.
    ///
    /// - Returns: XML string representation of the message
    /// - Throws: An error if the message cannot be serialized
    internal func toXML() throws -> String {
        switch self {
        case .getProperties(let prop): return try prop.toXML()
        case .setProperty(let prop): return try prop.toXML()
        case .updateProperty(let prop): return try prop.toXML()
        case .defineProperty(let prop): return try prop.toXML()
        case .enableBlob(let prop): return try prop.toXML()
        case .serverMessage(let msg): return try msg.toXML()
        case .ping(let ping): return try ping.toXML()
        case .deleteProperty, .pingReply:
            // These messages are receive-only and cannot be serialized
            let errorMessage = "\(operation.rawValue) messages cannot be serialized"
            throw NSError(
                domain: "INDIKit",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
    }
}

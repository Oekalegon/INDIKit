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
    
    /// The operation type of this message.
    public var operation: INDIOperation {
        switch self {
        case .getProperties(let prop): return prop.operation
        case .setProperty(let prop): return prop.operation
        case .updateProperty(let prop): return prop.operation
        case .defineProperty(let prop): return prop.operation
        case .enableBlob(let prop): return prop.operation
        case .serverMessage(let msg): return msg.operation
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
        case .serverMessage: return nil
        }
    }
    
    /// Property type (nil for getProperties and enableBLOB, required for others).
    public var propertyType: INDIPropertyType? {
        switch self {
        case .getProperties: return nil
        case .setProperty(let prop): return prop.propertyType
        case .updateProperty(let prop): return prop.propertyType
        case .defineProperty(let prop): return prop.propertyType
        case .enableBlob: return nil
        case .serverMessage: return nil
        }
    }
    
    /// The parsed values contained in this property (empty for getProperties and enableBLOB).
    public var values: [INDIValue] {
        switch self {
        case .getProperties: return []
        case .setProperty(let prop): return prop.values
        case .updateProperty(let prop): return prop.values
        case .defineProperty(let prop): return prop.values
        case .enableBlob: return []
        case .serverMessage: return []
        }
    }
    
    /// Group (only for update and define properties).
    public var group: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.group
        case .defineProperty(let prop): return prop.group
        }
    }
    
    /// Label (only for update and define properties).
    public var label: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.label
        case .defineProperty(let prop): return prop.label
        }
    }
    
    /// Permissions (only for update and define properties).
    public var permissions: INDIPropertyPermissions? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.permissions
        case .defineProperty(let prop): return prop.permissions
        }
    }
    
    /// State (only for update and define properties).
    public var state: INDIState? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.state
        case .defineProperty(let prop): return prop.state
        }
    }
    
    /// Timeout (only for update and define properties).
    public var timeout: Double? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.timeout
        case .defineProperty(let prop): return prop.timeout
        }
    }
    
    /// Timestamp (only for update and define properties).
    public var timeStamp: Date? {
        switch self {
        case .getProperties, .setProperty, .enableBlob: return nil
        case .updateProperty(let prop): return prop.timeStamp
        case .defineProperty(let prop): return prop.timeStamp
        case .serverMessage(let msg): return msg.timeStamp
        }
    }
    
    /// Rule for switch properties (only for update and define toggle properties).
    public var rule: INDISwitchRule? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.rule
        case .defineProperty(let prop): return prop.rule
        }
    }
    
    /// Format for blob properties (only for update and define blob properties).
    public var format: String? {
        switch self {
        case .getProperties, .setProperty, .enableBlob, .serverMessage: return nil
        case .updateProperty(let prop): return prop.format
        case .defineProperty(let prop): return prop.format
        }
    }
    
    /// BLOB sending state (only for enableBLOB properties).
    public var blobSendingState: BLOBSendingState? {
        switch self {
        case .getProperties, .setProperty, .updateProperty, .defineProperty, .serverMessage: return nil
        case .enableBlob(let prop): return prop.blobSendingState
        }
    }
    
    /// Version (only for getProperties).
    public var version: String? {
        switch self {
        case .getProperties(let prop): return prop.version
        case .setProperty, .updateProperty, .defineProperty, .enableBlob, .serverMessage: return nil
        }
    }
    
    /// Message text (only for server messages).
    public var messageText: String? {
        switch self {
        case .serverMessage(let msg): return msg.message
        case .getProperties, .setProperty, .updateProperty, .defineProperty, .enableBlob: return nil
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
        // Determine operation from element name
        guard let operation = INDIOperation(elementName: xmlNode.name) else {
            // Try to parse as getProperties or enableBLOB (they don't follow the pattern)
            if xmlNode.name == "getProperties" {
                if let getProps = INDIGetProperties(xmlNode: xmlNode) {
                    self = .getProperties(getProps)
                    return
                }
            } else if xmlNode.name == "enableBLOB" {
                if let enableBlob = INDIEnableBlob(xmlNode: xmlNode) {
                    self = .enableBlob(enableBlob)
                    return
                }
            }
            return nil
        }
        
        // Parse based on operation type
        switch operation {
        case .get:
            if let getProps = INDIGetProperties(xmlNode: xmlNode) {
                self = .getProperties(getProps)
            } else {
                return nil
            }
            
        case .set:
            if let setProp = INDISetProperty(xmlNode: xmlNode) {
                self = .setProperty(setProp)
            } else {
                return nil
            }
            
        case .update:
            if let updateProp = INDIUpdateProperty(xmlNode: xmlNode) {
                self = .updateProperty(updateProp)
            } else {
                return nil
            }
            
        case .define:
            if let defineProp = INDIDefineProperty(xmlNode: xmlNode) {
                self = .defineProperty(defineProp)
            } else {
                return nil
            }
            
        case .enableBlob:
            if let enableBlob = INDIEnableBlob(xmlNode: xmlNode) {
                self = .enableBlob(enableBlob)
            } else {
                return nil
            }
            
        case .message:
            if let serverMessage = INDIServerMessage(xmlNode: xmlNode) {
                self = .serverMessage(serverMessage)
            } else {
                return nil
            }
            
        case .ping, .pingReply, .delete:
            // These operations are not yet supported
            return nil
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
        }
    }
}

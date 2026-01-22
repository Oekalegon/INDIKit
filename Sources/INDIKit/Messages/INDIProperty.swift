import Foundation

/// An INDI property message wrapper that unifies all property types.
///
/// This enum wraps different property message types (getProperties, set, update, define, enableBLOB)
/// into a single type for use in streams and parsing. It provides computed properties that delegate
/// to the wrapped type, allowing code to work with `INDIProperty` without needing to know the
/// specific type.
public enum INDIProperty: Sendable {
    case get(INDIGetProperties)
    case set(INDISetProperty)
    case update(INDIUpdateProperty)
    case define(INDIDefineProperty)
    case enableBlob(INDIEnableBlobProperty)
    
    /// The operation type of this property.
    public var operation: INDIPropertyOperation {
        switch self {
        case .get(let prop): return prop.operation
        case .set(let prop): return prop.operation
        case .update(let prop): return prop.operation
        case .define(let prop): return prop.operation
        case .enableBlob(let prop): return prop.operation
        }
    }
    
    /// Diagnostic messages for the property.
    public var diagnostics: [INDIDiagnostics] {
        switch self {
        case .get(let prop): return prop.diagnostics
        case .set(let prop): return prop.diagnostics
        case .update(let prop): return prop.diagnostics
        case .define(let prop): return prop.diagnostics
        case .enableBlob(let prop): return prop.diagnostics
        }
    }
    
    /// Device name (optional for getProperties, required for others).
    public var device: String? {
        switch self {
        case .get(let prop): return prop.device
        case .set(let prop): return prop.device
        case .update(let prop): return prop.device
        case .define(let prop): return prop.device
        case .enableBlob(let prop): return prop.device
        }
    }
    
    /// Property name (optional for getProperties, required for others).
    public var name: INDIPropertyName? {
        switch self {
        case .get(let prop): return prop.name
        case .set(let prop): return prop.name
        case .update(let prop): return prop.name
        case .define(let prop): return prop.name
        case .enableBlob(let prop): return prop.name
        }
    }
    
    /// Property type (nil for getProperties and enableBLOB, required for others).
    public var propertyType: INDIPropertyType? {
        switch self {
        case .get: return nil
        case .set(let prop): return prop.propertyType
        case .update(let prop): return prop.propertyType
        case .define(let prop): return prop.propertyType
        case .enableBlob: return nil
        }
    }
    
    /// The parsed values contained in this property (empty for getProperties and enableBLOB).
    public var values: [INDIValue] {
        switch self {
        case .get: return []
        case .set(let prop): return prop.values
        case .update(let prop): return prop.values
        case .define(let prop): return prop.values
        case .enableBlob: return []
        }
    }
    
    /// Group (only for update and define properties).
    public var group: String? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.group
        case .define(let prop): return prop.group
        }
    }
    
    /// Label (only for update and define properties).
    public var label: String? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.label
        case .define(let prop): return prop.label
        }
    }
    
    /// Permissions (only for update and define properties).
    public var permissions: INDIPropertyPermissions? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.permissions
        case .define(let prop): return prop.permissions
        }
    }
    
    /// State (only for update and define properties).
    public var state: INDIState? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.state
        case .define(let prop): return prop.state
        }
    }
    
    /// Timeout (only for update and define properties).
    public var timeout: Double? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.timeout
        case .define(let prop): return prop.timeout
        }
    }
    
    /// Timestamp (only for update and define properties).
    public var timeStamp: Date? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.timeStamp
        case .define(let prop): return prop.timeStamp
        }
    }
    
    /// Rule for switch properties (only for update and define toggle properties).
    public var rule: INDISwitchRule? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.rule
        case .define(let prop): return prop.rule
        }
    }
    
    /// Format for blob properties (only for update and define blob properties).
    public var format: String? {
        switch self {
        case .get, .set, .enableBlob: return nil
        case .update(let prop): return prop.format
        case .define(let prop): return prop.format
        }
    }
    
    /// BLOB sending state (only for enableBLOB properties).
    public var blobSendingState: BLOBSendingState? {
        switch self {
        case .get, .set, .update, .define: return nil
        case .enableBlob(let prop): return prop.blobSendingState
        }
    }
    
    /// Version (only for getProperties).
    public var version: String? {
        switch self {
        case .get(let prop): return prop.version
        case .set, .update, .define, .enableBlob: return nil
        }
    }
    
    /// Parse an INDI property from XML.
    ///
    /// This factory method determines the operation type from the XML element name
    /// and creates the appropriate property type.
    ///
    /// - Parameter xmlNode: The XML node representation to parse
    /// - Returns: A parsed `INDIProperty` if successful, nil otherwise
    init?(xmlNode: XMLNodeRepresentation) {
        // Determine operation from element name
        guard let operation = INDIPropertyOperation(elementName: xmlNode.name) else {
            // Try to parse as getProperties or enableBLOB (they don't follow the pattern)
            if xmlNode.name == "getProperties" {
                if let getProps = INDIGetProperties(xmlNode: xmlNode) {
                    self = .get(getProps)
                    return
                }
            } else if xmlNode.name == "enableBLOB" {
                if let enableBlob = INDIEnableBlobProperty(xmlNode: xmlNode) {
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
                self = .get(getProps)
            } else {
                return nil
            }
            
        case .set:
            if let setProp = INDISetProperty(xmlNode: xmlNode) {
                self = .set(setProp)
            } else {
                return nil
            }
            
        case .update:
            if let updateProp = INDIUpdateProperty(xmlNode: xmlNode) {
                self = .update(updateProp)
            } else {
                return nil
            }
            
        case .define:
            if let defineProp = INDIDefineProperty(xmlNode: xmlNode) {
                self = .define(defineProp)
            } else {
                return nil
            }
            
        case .enableBlob:
            if let enableBlob = INDIEnableBlobProperty(xmlNode: xmlNode) {
                self = .enableBlob(enableBlob)
            } else {
                return nil
            }
            
        case .message, .ping, .pingReply, .delete:
            // These operations are not yet supported
            return nil
        }
    }
    
    /// Serialize this property to XML string format.
    ///
    /// - Returns: XML string representation of the property
    /// - Throws: An error if the property cannot be serialized
    internal func toXML() throws -> String {
        switch self {
        case .get(let prop): return try prop.toXML()
        case .set(let prop): return try prop.toXML()
        case .update(let prop): return try prop.toXML()
        case .define(let prop): return try prop.toXML()
        case .enableBlob(let prop): return try prop.toXML()
        }
    }
}

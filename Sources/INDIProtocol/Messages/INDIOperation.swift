import Foundation

public enum INDIOperation: String, Sendable, CaseIterable {

    /// Defines a property of a device or driver.
    /// 
    /// This message is sent by the server to the client to define a property of a device or driver.
    /// It gives information about the property, such as its name, type, and value.
    /// In the INDI protocol the associated XML elements are prefixed with `def**`.
    case define = "def"

    /// Updates a property of a device or driver.
    /// 
    /// These messages are sent when the server updates a value of a property.
    /// In the INDI protocol the associated XML elements are prefixed with `set**`.
    case update = "set"

    /// Sets a new value for a property. 
    /// 
    /// These messages are sent by the client to the server
    /// to change the value of a property.
    /// In the INDI protocol the associated XML elements are prefixed with `new**`.
    case set = "new"

    /// A request sent by the client to the server to get information about a device.
    /// 
    /// In the INDI protocol the associated XML element is `getProperties`.
    case get = "getProperties"

    /// A message sent by the server to the client.
    /// 
    /// These messages are sent by the server to the client to send a message.
    /// In the INDI protocol the associated XML element is `message`.
    case message = "message"

    /// Deletes a property of a device or driver.
    /// 
    /// Used when:
    /// - A device disconnects
    /// - A driver dynamically removes features
    /// - A camera switches modes (main vs guider)
    /// In the INDI protocol the associated XML element is `del**`.
    case delete = "del"

    /// A pingRequest message sent by the server to the client during binary transfers.
    /// 
    /// The client should reply with a `pingReply` message.
    /// In the INDI protocol the associated XML element is `pingRequest`.
    case pingRequest = "pingRequest"

    /// A pingReply message.
    /// 
    /// The reply to a `pingRequest` message, sent by the client to the server.
    /// In the INDI protocol the associated XML element is `pingReply`.
    case pingReply = "pingReply"

    /// Enables a blob transfer.
    /// 
    /// Legacy - replaced by `setBLOBVector`.
    case enableBlob = "enableBLOB"
    
    /// Initialize from an element name by matching its prefix or exact name.
    ///
    /// - Parameter elementName: The XML element name (e.g., "defTextVector", "setNumberVector", "getProperties")
    /// - Returns: The matching operation, or nil if no match is found
    public init?(elementName: String) {
        // First try exact match for non-prefix operations
        if let exactMatch = Self(rawValue: elementName) {
            self = exactMatch
            return
        }
        
        // Then try prefix matching for prefixed operations
        for operation in Self.allCases {
            let rawValue = operation.rawValue
            // Skip exact matches we already tried
            if rawValue == elementName {
                continue
            }
            // Check if element name starts with the raw value (for prefixes like "def", "set", "new", "del")
            if elementName.hasPrefix(rawValue) {
                self = operation
                return
            }
        }
        
        return nil
    }
}

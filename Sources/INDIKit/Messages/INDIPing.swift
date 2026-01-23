import Foundation

/// An INDI ping message.
///
/// This message is sent by the client to the server for liveness detection.
/// Ping messages can only be sent, not received.
public struct INDIPing: INDICommand, Sendable {
    public let operation: INDIOperation = .ping
    public let uid: String?
    public private(set) var diagnostics: [INDIDiagnostics]

    /// Create a ping message programmatically.
    ///
    /// - Parameter uid: Optional unique identifier for this ping
    public init(uid: String? = nil) {
        self.uid = uid
        self.diagnostics = []
    }

    // MARK: - XML Serialization

    internal func toXML() throws -> String {
        var xml = "<ping"
        if let uid = uid, !uid.isEmpty {
            xml += " uid=\"\(escapeXML(uid))\""
        }
        xml += "/>"
        return xml
    }
}


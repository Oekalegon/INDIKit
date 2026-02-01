import Foundation
import os

/// An INDI pingReply message.
///
/// This message is sent by the client to the server in response to a pingRequest message.
/// PingReply messages can only be sent, not received.
public struct INDIPingReply: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")

    /// The operation type of this message. This is always `.pingReply`.
    public let operation: INDIOperation = .pingReply

    /// The unique identifier for this pingReply.
    public let uid: String?

    /// The diagnostics for the message. This is used to store any errors or warnings that occur when parsing the message.
    /// This is set by the parser and can be accessed by the client to get the errors or warnings.
    public private(set) var diagnostics: [INDIDiagnostics]

    /// Create a pingReply message programmatically.
    ///
    /// - Parameter uid: Optional unique identifier for this pingReply (should match the pingRequest uid)
    public init(uid: String? = nil) {
        self.uid = uid
        self.diagnostics = []
    }

    /// Parse a pingReply message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard xmlNode.name == "pingReply" else {
            return nil
        }

        let attrs = xmlNode.attributes
        self.uid = attrs["uid"]
        self.diagnostics = []

        validate(attrs: attrs, children: xmlNode.children)
    }

    // MARK: - Validation

    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Warn about unexpected attributes (only uid is allowed)
        let allowedAttributes = ["uid"]
        for (key, _) in attrs where !allowedAttributes.contains(key) {
            let message = "pingReply element contains unexpected attribute '\(key)'. " +
                "Only 'uid' is allowed."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }

        // Warn if pingReply has child elements (it shouldn't have any)
        if !children.isEmpty {
            let message = "pingReply element contains \(children.count) child element(s), " +
                "but pingReply should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }
    }

    // MARK: - XML Serialization

    internal func toXML() throws -> String {
        var xml = "<pingReply"
        if let uid = uid, !uid.isEmpty {
            xml += " uid=\"\(escapeXML(uid))\""
        }
        xml += "/>"
        return xml
    }
}

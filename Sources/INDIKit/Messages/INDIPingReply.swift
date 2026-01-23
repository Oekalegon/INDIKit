import Foundation
import os

/// An INDI pingReply message.
///
/// This message is sent by the server to the client in response to a ping message.
/// PingReply messages can only be received, not sent.
public struct INDIPingReply: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")

    public let operation: INDIOperation = .pingReply
    public let uid: String?
    public private(set) var diagnostics: [INDIDiagnostics]

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
}


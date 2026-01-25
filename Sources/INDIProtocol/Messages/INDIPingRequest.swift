import Foundation
import os

/// An INDI pingRequest message.
///
/// This message is sent by the server to the client during binary transfers.
/// The client should reply with a `pingReply` message.
/// PingRequest messages can only be received, not sent.
public struct INDIPingRequest: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")

    public let operation: INDIOperation = .pingRequest
    public let uid: String?
    public private(set) var diagnostics: [INDIDiagnostics]

    /// Parse a pingRequest message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard xmlNode.name == "pingRequest" else {
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
            let message = "pingRequest element contains unexpected attribute '\(key)'. " +
                "Only 'uid' is allowed."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }

        // Warn if pingRequest has child elements (it shouldn't have any)
        if !children.isEmpty {
            let message = "pingRequest element contains \(children.count) child element(s), " +
                "but pingRequest should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }
    }
}


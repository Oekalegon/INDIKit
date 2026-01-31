import Foundation
import os

/// An INDI server message.
///
/// This message is sent by the server to the client to provide informational messages.
/// Server messages can only be received, not sent.
public struct INDIServerMessage: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")

    /// The operation type of this message. This is always `.message`.
    public let operation: INDIOperation = .message

    /// The device name to which the message belongs.
    public let device: String?

    /// The timestamp of the message.
    public let timeStamp: Date?

    /// The message text.
    public let message: String

    /// The diagnostics for the message. This is used to store any errors or warnings that occur when parsing the message.
    /// This is set by the parser and can be accessed by the client to get the errors or warnings.
    public private(set) var diagnostics: [INDIDiagnostics]

    /// Create a server message programmatically.
    ///
    /// - Parameters:
    ///   - device: Optional device name
    ///   - timeStamp: Optional timestamp
    ///   - message: The message text
    public init(device: String? = nil, timeStamp: Date? = nil, message: String) {
        self.device = device
        self.timeStamp = timeStamp
        self.message = message
        self.diagnostics = []
    }

    /// Parse a server message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard xmlNode.name == "message" else {
            return nil
        }

        let attrs = xmlNode.attributes
        self.device = attrs["device"]
        self.timeStamp = INDIParsingHelpers.extractTimestamp(from: attrs["timestamp"])
        self.message = xmlNode.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.diagnostics = []

        validate(attrs: attrs, children: xmlNode.children)
    }

    // MARK: - Validation

    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Warn about unexpected attributes (only device and timestamp are allowed)
        let allowedAttributes = ["device", "timestamp"]
        for (key, _) in attrs where !allowedAttributes.contains(key) {
            let message = "message element contains unexpected attribute '\(key)'. " +
                "Only 'device' and 'timestamp' are allowed."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }

        // Warn if message has child elements (it shouldn't have any, only text content)
        if !children.isEmpty {
            let message = "message element contains \(children.count) child element(s), " +
                "but message should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }
    }

    // MARK: - XML Serialization

    internal func toXML() throws -> String {
        var xml = "<message"

        if let device = device, !device.isEmpty {
            xml += " device=\"\(escapeXML(device))\""
        }

        if let timeStamp = timeStamp {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            xml += " timestamp=\"\(escapeXML(formatter.string(from: timeStamp)))\""
        }

        xml += ">"
        xml += escapeXML(message)
        xml += "</message>"

        return xml
    }
}

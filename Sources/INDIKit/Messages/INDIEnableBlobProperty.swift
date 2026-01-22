import Foundation
import os

/// An INDI enableBLOB message.
///
/// This message is sent by the client to the server to control BLOB data transmission
/// for a specific property.
public struct INDIEnableBlobProperty: INDIPropertyMessage, Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
    
    public let operation: INDIPropertyOperation = .enableBlob
    public let device: String
    public let name: INDIPropertyName
    public let blobSendingState: BLOBSendingState?
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// Create an enableBLOB message programmatically.
    ///
    /// - Parameters:
    ///   - device: The device name (required)
    ///   - name: The property name (required)
    ///   - blobSendingState: Optional BLOB sending state. If nil, the state attribute is omitted.
    public init(
        device: String,
        name: INDIPropertyName,
        blobSendingState: BLOBSendingState? = nil
    ) {
        self.device = device
        self.name = name
        self.blobSendingState = blobSendingState
        self.diagnostics = []
        validateProgrammatic()
    }
    
    /// Parse an enableBLOB message from XML.
    init?(xmlNode: XMLNodeRepresentation) {
        guard xmlNode.name == "enableBLOB" else {
            return nil
        }
        
        let attrs = xmlNode.attributes
        // Set to "UNKNOWN" if missing so validation can run
        self.device = attrs["device"] ?? "UNKNOWN"
        let nameString = attrs["name"] ?? "UNKNOWN"
        self.name = Self.extractProperty(from: nameString)
        
        // Parse blob sending state from state attribute
        if let stateString = attrs["state"], let blobState = BLOBSendingState(rawValue: stateString) {
            self.blobSendingState = blobState
        } else {
            self.blobSendingState = nil // Optional, no default
        }
        
        self.diagnostics = []
        validate(attrs: attrs, children: xmlNode.children)
    }
    
    // MARK: - Validation
    
    private mutating func validateProgrammatic() {
        // No validation needed for programmatic creation of enableBLOB
    }
    
    private mutating func validate(attrs: [String: String], children: [XMLNodeRepresentation]) {
        // Validate that device and name are present
        if device == "UNKNOWN" || device.isEmpty {
            let message = "Device is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        if name.indiName == "UNKNOWN" {
            let message = "The property name is required but not found"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Warn if enableBLOB has child elements (it shouldn't have any)
        if !children.isEmpty {
            let message = "enableBLOB element contains \(children.count) child element(s), " +
                "but enableBLOB should not have any child elements."
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
    }
    
    // MARK: - XML Serialization
    
    public func toXML() throws -> String {
        var xml = "<enableBLOB"
        
        xml += " device=\"\(escapeXML(device))\""
        xml += " name=\"\(escapeXML(name.indiName))\""
        
        // Include blob sending state as attribute if available (it's optional)
        if let blobState = blobSendingState {
            xml += " state=\"\(escapeXML(blobState.rawValue))\""
        }
        
        xml += "/>"
        
        return xml
    }
    
    // MARK: - Private Helpers
    
    private static func extractProperty(from name: String) -> INDIPropertyName {
        INDIPropertyName(indiName: name)
    }
}

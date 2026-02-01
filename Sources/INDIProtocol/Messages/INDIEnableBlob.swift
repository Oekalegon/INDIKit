import Foundation
import os

/// An INDI enableBLOB message. 
/// 
/// You will need to enable BLOB data transmission for a property
/// before you can receive BLOB data from the server. BLOB data is usually used for image and video
/// data.
///
/// This message is sent by the client to the server to control BLOB data transmission
/// for a specific property.
/// 
/// It is used by the client to control the BLOB data transmission for a specific property.
/// EnableBLOB messages have three required attributes: `device`, `name`, and `state`.
/// - `device`: The device name to which the property belongs.
/// - `name`: The name of the property.
/// - `state`: The BLOB sending state.
/// 
/// If the `state` is not present, the message is invalid.
public struct INDIEnableBlob: INDICommand, Sendable {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIProtocol", category: "parsing")
    
    /// The operation type of this message. This is always `.enableBlob`.
    public let operation: INDIOperation = .enableBlob

    /// The device name to which the property belongs.
    public let device: String

    /// The name of the property.
    public let name: INDIPropertyName

    /// The BLOB sending state.
    public let blobSendingState: BLOBSendingState?

    /// The diagnostics for the property. This is used to store any errors or warnings that occur when parsing the property.
    /// This is set by the parser and can be accessed by the client to get the errors or warnings.
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// Create an enableBLOB message programmatically.
    ///
    /// - Parameters:
    ///   - device: The device name (required)
    ///   - name: The property name (required)
    ///   - blobSendingState: The BLOB sending state. If nil, the state attribute is omitted.
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
        self.name = INDIParsingHelpers.extractProperty(from: nameString)
        
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
    
    internal func toXML() throws -> String {
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
}

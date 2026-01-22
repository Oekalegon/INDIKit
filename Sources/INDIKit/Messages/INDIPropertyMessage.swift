import Foundation

/// Protocol that all INDI property message types conform to.
///
/// This protocol defines the common interface for all INDI property operations,
/// including getProperties, set, update, define, and enableBLOB.
public protocol INDIPropertyMessage: Sendable {
    /// The operation type of this property.
    var operation: INDIPropertyOperation { get }
    
    /// Diagnostic messages for the property.
    var diagnostics: [INDIDiagnostics] { get }
    
    /// Serialize this property to XML string format.
    ///
    /// - Returns: XML string representation of the property
    /// - Throws: An error if the property cannot be serialized
    func toXML() throws -> String
}


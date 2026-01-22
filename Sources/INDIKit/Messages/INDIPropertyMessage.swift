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
}

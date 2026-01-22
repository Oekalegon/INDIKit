import Foundation

/// Protocol that all INDI command types conform to.
///
/// This protocol defines the common interface for all INDI command operations,
/// including getProperties, set, update, define, and enableBLOB.
public protocol INDICommand: Sendable {
    /// The operation type of this command.
    var operation: INDIOperation { get }
    
    /// Diagnostic messages for the command.
    var diagnostics: [INDIDiagnostics] { get }
}

import Testing
@testable import INDIKit

/// Shared test helpers for checking diagnostics across test suites.
enum INDIDiagnosticsTestHelpers {
    
    /// Check if diagnostics contain a specific type of diagnostic with a message containing all of the given texts
    static func hasDiagnostic(
        _ diagnostics: [INDIDiagnostics],
        matching predicate: (INDIDiagnostics) -> Bool,
        containing texts: [String]
    ) -> Bool {
        diagnostics.contains { diagnostic in
            guard predicate(diagnostic) else { return false }
            let message: String
            switch diagnostic {
            case .error(let msg): message = msg
            case .warning(let msg): message = msg
            case .note(let msg): message = msg
            case .info(let msg): message = msg
            case .debug(let msg): message = msg
            case .fatal(let msg): message = msg
            }
            return texts.isEmpty || texts.allSatisfy { message.contains($0) }
        }
    }
    
    /// Check if diagnostics contain an error with a message containing all of the given texts
    static func hasError(_ diagnostics: [INDIDiagnostics], containing texts: String...) -> Bool {
        hasDiagnostic(diagnostics, matching: { if case .error = $0 { return true }; return false }, containing: Array(texts))
    }
    
    /// Check if diagnostics contain a warning with a message containing all of the given texts
    static func hasWarning(_ diagnostics: [INDIDiagnostics], containing texts: String...) -> Bool {
        hasDiagnostic(diagnostics, matching: { if case .warning = $0 { return true }; return false }, containing: Array(texts))
    }
    
    /// Check if diagnostics contain a note with a message containing all of the given texts
    static func hasNote(_ diagnostics: [INDIDiagnostics], containing texts: String...) -> Bool {
        hasDiagnostic(diagnostics, matching: { if case .note = $0 { return true }; return false }, containing: Array(texts))
    }
    
    /// Check if diagnostics contain any error
    static func hasAnyError(_ diagnostics: [INDIDiagnostics]) -> Bool {
        diagnostics.contains { if case .error = $0 { return true }; return false }
    }
}


import Foundation
import os

public enum INDIDiagnostics: Sendable {

    case debug(String)
    case note(String)
    case info(String)
    case warning(String)
    case error(String)
    case fatal(String)
    
    /// Log a debug message and add a debug diagnostic.
    public static func logDebug(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.debug("\(message)")
        diagnostics.append(.debug(message))
    }
    
    /// Log a notice message and add a note diagnostic.
    public static func logNote(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.notice("\(message)")
        diagnostics.append(.note(message))
    }

    /// Log an info message and add an info diagnostic.
    public static func logInfo(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.info("\(message)")
        diagnostics.append(.info(message))
    }
    
    /// Log a warning message and add a warning diagnostic.
    public static func logWarning(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.warning("\(message)")
        diagnostics.append(.warning(message))
    }
    
    /// Log an error message and add an error diagnostic.
    public static func logError(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.error("\(message)")
        diagnostics.append(.error(message))
    }
    
    /// Log a fatal message and add a fatal diagnostic.
    public static func logFatal(_ message: String, logger: Logger, diagnostics: inout [INDIDiagnostics]) {
        logger.critical("\(message)")
        diagnostics.append(.fatal(message))
    }
}
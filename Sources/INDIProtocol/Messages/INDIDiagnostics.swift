import Foundation
import os

/// A diagnostic message.
///
/// This is used to store any errors or warnings that occur when parsing an INDI message.
/// This is set by the parser and can be accessed by the client to get the errors or warnings.
/// Diagnostics are usually specific to a property or device and are stored with the message.
public enum INDIDiagnostics: Sendable {

    /// A debug diagnostic message.
    case debug(String)

    /// A note diagnostic message.
    case note(String)

    /// An info diagnostic message.
    case info(String)

    /// A warning diagnostic message. This is used to indicate a potential problem that may not
    /// necessarily cause a problem, but should be addressed.
    case warning(String)

    /// An error diagnostic message. This is used to indicate a problem that will cause the
    /// message to be ignored.
    case error(String)

    /// A fatal error diagnostic message. This is used to indicate a problem that will cause the
    /// message to be ignored and the client to exit.
    case fatal(String)
    
    /// Log a debug message and add a debug diagnostic.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logDebug(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.debug("\(message, privacy: .public)")
        diagnostics.append(.debug(message))
    }
    
    /// Log a notice message and add a note diagnostic.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logNote(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.notice("\(message, privacy: .public)")
        diagnostics.append(.note(message))
    }

    /// Log an info message and add an info diagnostic.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logInfo(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.info("\(message, privacy: .public)")
        diagnostics.append(.info(message))
    }
    
    /// Log a warning message and add a warning diagnostic.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logWarning(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.warning("\(message, privacy: .public)")
        diagnostics.append(.warning(message))
    }
    
    /// Log an error message and add an error diagnostic.   
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logError(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.error("\(message, privacy: .public)")
        diagnostics.append(.error(message))
    }
    
    /// Log a fatal message and add a fatal diagnostic. 
    /// - Parameters:
    ///   - message: The message to log.
    ///   - logger: The system logger to which the message will be logged. This will appear in the
    ///             system logs. If set to nil, the message will still be added to the diagnostics,
    ///   - diagnostics: The diagnostics to add the message to.
    public static func logFatal(_ message: String, logger: Logger? = nil, diagnostics: inout [INDIDiagnostics]) {
        logger?.critical("\(message, privacy: .public)")
        diagnostics.append(.fatal(message))
    }
}

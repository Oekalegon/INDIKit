import Foundation

/// State of a property.
///
/// This is used to indicate the state of the property.
/// In INDI protocol, this is represented as "Idle", "Busy", "Alert", or "Ok".
public enum INDIPropertyState: Sendable, CaseIterable {

    /// The property is not doing anything (initial state)
    case idle 

    /// The operation was successful, the value is valid
    case ok

    /// An operation on the property is in progress
    case busy

    /// The property is in an alert state (e.g. error, warning, etc.)
    case alert

    public var indiValue: String {
        switch self {
        case .idle: return "Idle"
        case .busy: return "Busy"
        case .alert: return "Alert"
        case .ok: return "Ok"
        }
    }
    
    /// Initialize from an INDI state string.
    ///
    /// - Parameter indiValue: The INDI state value ("Idle", "Ok", "Busy", or "Alert")
    /// - Returns: The matching state, or `.idle` as default if no match is found
    public init(indiValue: String) {
        if let found = Self.allCases.first(where: { $0.indiValue == indiValue }) {
            self = found
        } else {
            self = .idle
        }
    }
}

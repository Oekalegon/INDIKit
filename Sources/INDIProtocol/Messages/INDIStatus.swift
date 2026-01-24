import Foundation

/// INDI state value.
///
/// This represents a state value used in the INDI protocol.
/// It can be used for property states or light values.
/// In INDI protocol, this is represented as "Idle", "Busy", "Alert", or "Ok".
public enum INDIStatus: Sendable, CaseIterable {

    /// The state is idle (not doing anything, initial state)
    case idle 

    /// The state is ok (operation was successful, value is valid)
    case ok

    /// The state is busy (an operation is in progress)
    case busy

    /// The state is alert (error, warning, etc.)
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

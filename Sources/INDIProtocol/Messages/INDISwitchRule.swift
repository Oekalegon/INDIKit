import Foundation

/// Rule for switch property behavior.
///
/// This determines how multiple switches in a switch vector property interact.
/// In INDI protocol, this is represented as "OneOfMany", "AtMostOne", or "AnyOfMany".
public enum INDISwitchRule: String, Sendable, CaseIterable {
    /// Only one switch can be ON at a time (mutually exclusive).
    ///
    /// In INDI protocol, this is represented as "OneOfMany".
    case oneOfMany = "OneOfMany"
    
    /// At most one switch can be ON (all can be OFF, but only one can be ON).
    ///
    /// In INDI protocol, this is represented as "AtMostOne".
    case atMostOne = "AtMostOne"
    
    /// Any combination of switches can be ON (independent switches).
    ///
    /// In INDI protocol, this is represented as "AnyOfMany".
    case anyOfMany = "AnyOfMany"
    
    /// Initialize from an INDI rule string.
    ///
    /// - Parameter indiValue: The INDI rule value ("OneOfMany", "AtMostOne", or "AnyOfMany")
    /// - Returns: The matching rule, or `nil` if no match is found
    public init?(indiValue: String) {
        if let found = Self.allCases.first(where: { $0.rawValue == indiValue }) {
            self = found
        } else {
            return nil
        }
    }
}

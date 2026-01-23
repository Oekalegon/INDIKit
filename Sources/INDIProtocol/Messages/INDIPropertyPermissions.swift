import Foundation

/// Permissions for a property.
///
/// This is used to indicate the permissions of the client on the property.
/// In INDI protocol, this is represented as "ro", "wo", or "rw".
public enum INDIPropertyPermissions: Sendable, CaseIterable {

    // Read only
    case readOnly

    // Write only
    case writeOnly

    // Read and write
    case readWrite

    // The INDI value for the permissions.
    public var indiValue: String {
        switch self {
        case .readOnly: return "ro"
        case .writeOnly: return "wo"
        case .readWrite: return "rw"
        }
    }
    
    /// Initialize from an INDI permissions string.
    ///
    /// - Parameter indiValue: The INDI permissions value ("ro", "wo", or "rw")
    /// - Returns: The matching permissions, or `.readWrite` as default if no match is found
    public init(indiValue: String) {
        if let found = Self.allCases.first(where: { $0.indiValue == indiValue }) {
            self = found
        } else {
            self = .readWrite
        }
    }
}

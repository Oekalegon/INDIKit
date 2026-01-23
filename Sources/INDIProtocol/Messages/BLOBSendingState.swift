import Foundation

/// BLOB sending state for enableBLOB operations.
///
/// Determines how BLOB data should be sent for a specific property.
public enum BLOBSendingState: String, Sendable, CaseIterable {
    /// BLOB sending is off (disabled).
    case off = "Off"
    
    /// BLOB sending is on (enabled).
    case on = "On"
    
    /// BLOB sending is enabled for this property only.
    case also = "Also"
    
    /// BLOB sending is enabled in raw format.
    case raw = "Raw"
}

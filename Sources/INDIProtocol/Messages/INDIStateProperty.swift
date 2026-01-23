import Foundation

/// Protocol for INDI properties that have full state information (update and define operations).
///
/// This protocol defines the shared properties between `INDIUpdateProperty` and `INDIDefineProperty`,
/// which both support all optional attributes like group, label, permissions, state, timeout, etc.
public protocol INDIStateProperty: INDICommand {
    /// Device name (required).
    var device: String { get }
    
    /// Property name (required).
    var name: INDIPropertyName { get }
    
    /// Property type (required).
    var propertyType: INDIPropertyType { get }
    
    /// UI grouping hint (optional).
    var group: String? { get }
    
    /// Human-readable label (optional).
    var label: String? { get }
    
    /// Property permissions (optional).
    var permissions: INDIPropertyPermissions? { get }
    
    /// Property state (optional).
    var state: INDIState? { get }
    
    /// Timeout in seconds (optional).
    var timeout: Double? { get }
    
    /// Timestamp (optional).
    var timeStamp: Date? { get }
    
    /// Rule for switch properties (optional, only for toggle properties).
    var rule: INDISwitchRule? { get }
    
    /// Format for blob properties (optional, only for blob properties).
    var format: String? { get }
    
    /// The parsed values contained in this property.
    var values: [INDIValue] { get }
}


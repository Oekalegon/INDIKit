import Foundation
import INDIProtocol
import INDIState
import Observation

/// Protocol for observable INDI properties that enables SwiftUI integration.
///
/// This protocol wraps the `INDIProperty` protocol and provides `@Observable` state
/// that SwiftUI views can observe. Concrete implementations wrap specific property types.
public protocol ObservableINDIProperty: AnyObject {
    
    /// The property name
    var name: INDIPropertyName { get }
    
    /// The property type
    var type: INDIPropertyType { get }
    
    /// UI grouping hint
    var group: String? { get }
    
    /// Human-readable label
    var label: String? { get }
    
    /// Property permissions
    var permissions: INDIPropertyPermissions? { get }
    
    /// Property state
    var state: INDIStatus? { get }
    
    /// Timeout in seconds
    var timeout: Double? { get }
    
    /// The current property values
    var values: [any PropertyValue] { get }
    
    /// The target property values (set by client, not yet applied)
    var targetValues: [any PropertyValue]? { get }
    
    /// Timestamp of the current values
    var timeStamp: Date { get }
    
    /// Timestamp of the target values
    var targetTimeStamp: Date? { get }
    
    /// Sync this observable property from an updated INDIProperty.
    /// 
    /// This method is called when the underlying property is updated,
    /// allowing the observable property to update its state.
    /// - Parameter property: The updated property from the registry
    func sync(from property: any INDIProperty)
}

/// Factory function to create an appropriate ObservableINDIProperty from an INDIProperty.
/// 
/// This function examines the property type and creates the corresponding
/// observable property wrapper.
/// - Parameters:
///   - property: The INDIProperty to wrap
///   - device: The observable device that owns this property
/// - Returns: An instance of the appropriate ObservableINDIProperty type
func createObservableProperty(from property: any INDIProperty, device: ObservableINDIDevice) -> ObservableINDIProperty {
    switch property.type {
    case .text:
        if let textProperty = property as? TextProperty {
            return ObservableTextProperty(property: textProperty, device: device)
        }
    case .toggle:
        if let switchProperty = property as? SwitchProperty {
            return ObservableSwitchProperty(property: switchProperty, device: device)
        }
    case .number:
        if let numberProperty = property as? NumberProperty {
            return ObservableNumberProperty(property: numberProperty, device: device)
        }
    case .light:
        if let lightProperty = property as? LightProperty {
            return ObservableLightProperty(property: lightProperty, device: device)
        }
    case .blob:
        if let blobProperty = property as? BLOBProperty {
            return ObservableBLOBProperty(property: blobProperty, device: device)
        }
    }
    
    // Fallback: This shouldn't happen, but create a generic wrapper if needed
    fatalError("Unknown property type: \(property.type)")
}


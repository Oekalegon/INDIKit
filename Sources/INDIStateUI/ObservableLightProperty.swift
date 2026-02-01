import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for LightProperty that enables SwiftUI integration.
@Observable
public class ObservableLightProperty: ObservableINDIProperty {
    
    private var _property: LightProperty
    private weak var device: ObservableINDIDevice?
    
    public var name: INDIPropertyName { _property.name }
    public var type: INDIPropertyType { .light }
    public var group: String? { _property.group }
    public var label: String? { _property.label }
    public var permissions: INDIPropertyPermissions? { _property.permissions }
    public var state: INDIStatus? { _property.state }
    public var timeout: Double? { _property.timeout }
    public var values: [any PropertyValue] { _property.values }
    public var targetValues: [any PropertyValue]? { _property.targetValues }
    public var timeStamp: Date { _property.timeStamp }
    public var targetTimeStamp: Date? { _property.targetTimeStamp }
    
    /// Get light values
    public var lightValues: [LightValue] {
        return _property.lightValues
    }
    
    /// Get target light values
    public var targetLightValues: [LightValue]? {
        return _property.targetLightValues
    }
    
    init(property: LightProperty, device: ObservableINDIDevice) {
        self._property = property
        self.device = device
    }
    
    public func sync(from property: any INDIProperty) {
        guard let lightProperty = property as? LightProperty else { return }
        self._property = lightProperty
    }
}

import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for NumberProperty that enables SwiftUI integration.
@Observable
public class ObservableNumberProperty: ObservableINDIProperty {
    
    private var _property: NumberProperty
    private weak var device: ObservableINDIDevice?
    
    public var name: INDIPropertyName { _property.name }
    public var type: INDIPropertyType { .number }
    public var group: String? { _property.group }
    public var label: String? { _property.label }
    public var permissions: INDIPropertyPermissions? { _property.permissions }
    public var state: INDIStatus? { _property.state }
    public var timeout: Double? { _property.timeout }
    public var values: [any PropertyValue] { _property.values }
    public var targetValues: [any PropertyValue]? { _property.targetValues }
    public var timeStamp: Date { _property.timeStamp }
    public var targetTimeStamp: Date? { _property.targetTimeStamp }
    
    /// Get number values
    public var numberValues: [NumberValue] {
        return _property.numberValues
    }
    
    /// Get target number values
    public var targetNumberValues: [NumberValue]? {
        return _property.targetNumberValues
    }
    
    init(property: NumberProperty, device: ObservableINDIDevice) {
        self._property = property
        self.device = device
    }
    
    public func sync(from property: any INDIProperty) {
        guard let numberProperty = property as? NumberProperty else { return }
        self._property = numberProperty
    }
    
    /// Set target number values.
    /// 
    /// This will update the underlying property and send the update to the server.
    /// - Parameter targetNumberValues: Array of tuples with name and number value
    /// - Throws: An error if a value name doesn't exist
    public func setTargetNumberValues(_ targetNumberValues: [(name: INDIPropertyValueName, numberValue: Double)]) async throws {
        var property = _property
        try property.setTargetNumberValues(targetNumberValues)
        self._property = property
        
        // Update the device in the registry
        if let device = device {
            try await device.setProperty(self)
        }
    }
    
    /// Set a single target number value.
    /// - Parameters:
    ///   - name: The name of the value
    ///   - numberValue: The number value to set
    /// - Throws: An error if the value name doesn't exist
    public func setTargetNumberValue(name: INDIPropertyValueName, _ numberValue: Double) async throws {
        try await setTargetNumberValues([(name: name, numberValue: numberValue)])
    }
}

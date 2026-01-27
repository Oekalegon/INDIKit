import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for SwitchProperty that enables SwiftUI integration.
@Observable
public class ObservableSwitchProperty: ObservableINDIProperty {
    
    private var _property: SwitchProperty
    private weak var device: ObservableINDIDevice?
    
    public var name: INDIPropertyName { _property.name }
    public var type: INDIPropertyType { .toggle }
    public var group: String? { _property.group }
    public var label: String? { _property.label }
    public var permissions: INDIPropertyPermissions? { _property.permissions }
    public var state: INDIStatus? { _property.state }
    public var timeout: Double? { _property.timeout }
    public var values: [any PropertyValue] { _property.values }
    public var targetValues: [any PropertyValue]? { _property.targetValues }
    public var timeStamp: Date { _property.timeStamp }
    public var targetTimeStamp: Date? { _property.targetTimeStamp }
    
    /// The switch rule
    public var rule: INDISwitchRule? { _property.rule }
    
    /// Get switch values
    public var switchValues: [SwitchValue] {
        return _property.switchValues
    }
    
    /// Get target switch values
    public var targetSwitchValues: [SwitchValue]? {
        return _property.targetSwitchValues
    }
    
    /// Get names of switches that are on
    public var on: [INDIPropertyValueName] {
        return _property.on
    }
    
    /// Get names of switches that are off
    public var off: [INDIPropertyValueName] {
        return _property.off
    }
    
    /// Get names of target switches that are on
    public var targetOn: [INDIPropertyValueName]? {
        return _property.targetOn
    }
    
    /// Get names of target switches that are off
    public var targetOff: [INDIPropertyValueName]? {
        return _property.targetOff
    }
    
    init(property: SwitchProperty, device: ObservableINDIDevice) {
        self._property = property
        self.device = device
    }
    
    public func sync(from property: any INDIProperty) {
        guard let switchProperty = property as? SwitchProperty else { return }
        self._property = switchProperty
    }
    
    /// Check if a switch is on.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the switch is on, false otherwise
    public func isOn(name: INDIPropertyValueName) -> Bool {
        return _property.isOn(name: name)
    }
    
    /// Check if a switch is off.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the switch is off, false otherwise
    public func isOff(name: INDIPropertyValueName) -> Bool {
        return _property.isOff(name: name)
    }
    
    /// Get the switch value for a given name.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the switch is on, false otherwise
    public func switchValue(name: INDIPropertyValueName) -> Bool {
        return _property.switchValue(name: name)
    }
    
    /// Check if a target switch is on.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the target switch is on, false otherwise
    public func isTargetOn(name: INDIPropertyValueName) -> Bool? {
        return _property.isTargetOn(name: name)
    }
    
    /// Check if a target switch is off.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the target switch is off, false otherwise
    public func isTargetOff(name: INDIPropertyValueName) -> Bool? {
        return _property.isTargetOff(name: name)
    }
    
    /// Get the target switch value for a given name.
    /// - Parameter name: The name of the switch
    /// - Returns: True if the target switch is on, false if off, nil if no target value is set
    public func targetSwitchValue(name: INDIPropertyValueName) -> Bool? {
        return _property.targetSwitchValue(name: name)
    }
    
    /// Set target switch values.
    /// 
    /// This will update the underlying property and send the update to the server.
    /// - Parameter targetBooleanValues: Array of tuples with name and boolean value
    /// - Throws: An error if a value name doesn't exist or switch rule is violated
    public func setTargetSwitchValues(_ targetBooleanValues: [(name: INDIPropertyValueName, booleanValue: Bool)]) async throws {
        var property = _property
        try property.setTargetSwitchValues(targetBooleanValues)
        self._property = property
        
        // Update the device in the registry
        if let device = device {
            try await device.setProperty(self)
        }
    }
    
    /// Set a single target switch value.
    /// 
    /// This will update the underlying property and send the update to the server.
    /// - Parameters:
    ///   - name: The name of the switch
    ///   - booleanValue: The boolean value to set
    /// - Throws: An error if the value name doesn't exist or switch rule is violated
    public func setTargetSwitchValue(name: INDIPropertyValueName, _ booleanValue: Bool) async throws {
        var property = _property
        try property.setTargetSwitchValue(name: name, booleanValue)
        self._property = property
        
        // Update the device in the registry
        if let device = device {
            try await device.setProperty(self)
        }
    }
}


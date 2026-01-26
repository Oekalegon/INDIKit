import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for TextProperty that enables SwiftUI integration.
@Observable
public class ObservableTextProperty: ObservableINDIProperty {
    
    private var _property: TextProperty
    private weak var device: ObservableINDIDevice?
    
    public var name: INDIPropertyName { _property.name }
    public var type: INDIPropertyType { .text }
    public var group: String? { _property.group }
    public var label: String? { _property.label }
    public var permissions: INDIPropertyPermissions? { _property.permissions }
    public var state: INDIStatus? { _property.state }
    public var timeout: Double? { _property.timeout }
    public var values: [any PropertyValue] { _property.values }
    public var targetValues: [any PropertyValue]? { _property.targetValues }
    public var timeStamp: Date { _property.timeStamp }
    public var targetTimeStamp: Date? { _property.targetTimeStamp }
    
    /// Get text values
    public var textValues: [TextValue] {
        return _property.textValues
    }
    
    /// Get target text values
    public var targetTextValues: [TextValue]? {
        return _property.targetTextValues
    }
    
    init(property: TextProperty, device: ObservableINDIDevice) {
        self._property = property
        self.device = device
    }
    
    public func sync(from property: any INDIProperty) {
        guard let textProperty = property as? TextProperty else { return }
        self._property = textProperty
    }
    
    /// Get a text value by name.
    /// - Parameter name: The name of the value
    /// - Returns: The text value, or empty string if not found
    public func textValue(name: INDIPropertyValueName) -> String {
        return _property.textValue(name: name)
    }
    
    /// Set target text values.
    /// 
    /// This will update the underlying property and send the update to the server.
    /// - Parameter targetTextValues: Array of tuples with name and text value
    /// - Throws: An error if a value name doesn't exist
    public func setTargetTextValues(_ targetTextValues: [(name: INDIPropertyValueName, textValue: String)]) async throws {
        var property = _property
        try property.setTargetTextValues(targetTextValues)
        self._property = property
        
        // Update the device in the registry
        if let device = device {
            try await device.setProperty(self)
        }
    }
    
    /// Set a single target text value.
    /// - Parameters:
    ///   - name: The name of the value
    ///   - textValue: The text value to set
    /// - Throws: An error if the value name doesn't exist
    public func setTargetTextValue(name: INDIPropertyValueName, _ textValue: String) async throws {
        try await setTargetTextValues([(name: name, textValue: textValue)])
    }
}


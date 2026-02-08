import Foundation
import INDIProtocol
import os

public struct LightProperty: INDIProperty {

    public let name: INDIPropertyName
    public let type: INDIPropertyType = .light
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?

    public var lightValues: [LightValue] {
        return values.compactMap { $0 as? LightValue }
    }
    
    /// Get a light value by name.
    /// - Parameter name: The name of the value
    /// - Returns: The light value status, or nil if not found
    public func lightValue(name: INDIPropertyValueName) -> INDIStatus? {
        return lightValues.first(where: { $0.name == name })?.lightValue
    }

    public var values: [any PropertyValue]

    public var targetLightValues: [LightValue]? {
        return targetValues?.compactMap { $0 as? LightValue }
    }
    
    /// Get a target light value by name.
    /// - Parameter name: The name of the value
    /// - Returns: The target light value status, or nil if not found or no target values are set
    public func targetLightValue(name: INDIPropertyValueName) -> INDIStatus? {
        return targetLightValues?.first(where: { $0.name == name })?.lightValue
    }

    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 
}

public struct LightValue: PropertyValue {

    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIState", category: "properties")

    public let name: INDIPropertyValueName
    public let label: String?

    public var lightValue: INDIStatus

    public var value: INDIValue.Value {
        get {
            return .state(lightValue)
        }
        set {
            if case .state(let lightValue) = newValue {
                self.lightValue = lightValue
            }
        }
    }

    /// Creates a new LightValue with the current value but preserving attributes
    /// from the existing value if they are nil in this value.
    ///
    /// This is used when updating property values from update messages that may
    /// not include all the attribute metadata that was provided in the original
    /// define message.
    /// - Parameter existing: The existing value to take attributes from if not present in self
    /// - Returns: A new LightValue with merged attributes
    public func mergingAttributes(from existing: LightValue) -> LightValue {
        return LightValue(
            name: self.name,
            label: self.label ?? existing.label,
            lightValue: self.lightValue
        )
    }
}

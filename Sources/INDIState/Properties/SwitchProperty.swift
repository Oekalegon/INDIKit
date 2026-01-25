import Foundation
import INDIProtocol

public struct SwitchProperty: INDIProperty {

    public let name: INDIPropertyName
    public let type: INDIPropertyType = .toggle
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?
    public let rule: INDISwitchRule?

    public var on: [INDIPropertyValueName] {
        return switchValues.filter { $0.switchValue }.map { $0.name }
    }

    public func isOn(name: INDIPropertyValueName) -> Bool {
        return on.contains(name)
    }

    public var off: [INDIPropertyValueName] {
        return switchValues.filter { !$0.switchValue }.map { $0.name }
    }

    public func isOff(name: INDIPropertyValueName) -> Bool {
        return off.contains(name)
    }

    public var switchValues: [SwitchValue] {
        return values.compactMap { $0 as? SwitchValue }
    }

    public func switchValue(name: INDIPropertyValueName) -> Bool {
        return switchValues.first(where: { $0.name == name })?.switchValue ?? false
    }

    public var values: [any PropertyValue]

    public var targetOn: [INDIPropertyValueName] {
        return targetSwitchValues?.filter { $0.switchValue }.map { $0.name } ?? []
    }

    public func isTargetOn(name: INDIPropertyValueName) -> Bool {
        return targetOn.contains(name)
    }

    public var targetOff: [INDIPropertyValueName] {
        return targetSwitchValues?.filter { !$0.switchValue }.map { $0.name } ?? []
    }

    public func isTargetOff(name: INDIPropertyValueName) -> Bool {
        return targetOff.contains(name)
    }

    public func targetSwitchValue(name: INDIPropertyValueName) -> Bool {
        return targetSwitchValues?.first(where: { $0.name == name })?.switchValue ?? false
    }

    public var targetSwitchValues: [SwitchValue]? {
        return targetValues?.compactMap { $0 as? SwitchValue }
    }

    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 

    /// Set the target values of a switch property.
    /// 
    /// This function updates the target values of the property based on the rule and the new values.
    /// 
    /// - Parameters:
    ///   - targetBooleanValues: An array of tuples containing the name and value of the switch values to set
    /// - Throws: ``INDISwitchRuleErrors`` if the switch rule is violated
    public mutating func setTargetSwitchValues(_ targetBooleanValues: [(name: INDIPropertyValueName, booleanValue: Bool)]) throws {
        var newTargetValues: [SwitchValue] = []
        // Get an array of the missing names from the targetBooleanValues
        let missingNames = targetBooleanValues.map { $0.name }.filter { !values.map { $0.name }.contains($0) }

        // Current switch values, use existing target values if they are available.
        let currentSwitchValues = targetSwitchValues ?? switchValues
        
        // Add the new target values to the newTargetValues
        for (name, booleanValue) in targetBooleanValues {
            if var newValue = currentSwitchValues.first(where: { $0.name == name }) {
                newValue.switchValue = booleanValue
                newTargetValues.append(newValue)
            } else {
                throw INDIPropertyErrors.valueNotFound(
                    message: "Value with name \(name) does not exist",
                    propertyName: self.name,
                    valueName: name
                )
            }
        }
        // Add the missing names to the newTargetValues
        for name in missingNames {
            if let existingValue = currentSwitchValues.first(where: { $0.name == name }) {
                newTargetValues.append(existingValue)
            }
        }
        let trueValues = targetBooleanValues.filter { $0.booleanValue }.map { $0.name }
        if rule == .atMostOne && trueValues.count > 1 {
            throw INDISwitchRuleErrors.atMostOneRuleViolation(
                message: "AtMostOne rule requires at most one value to be true",
                values: newTargetValues
            )
        } else if rule == .oneOfMany && trueValues.count != 1 {
            throw INDISwitchRuleErrors.oneOfManyRuleViolation(
                message: "OneOfMany rule requires exactly one value to be true",
                values: newTargetValues
            )
        }
        targetValues = newTargetValues
        targetTimeStamp = Date()
    }

    /// Set the `target value of a switch property.
    /// 
    /// This function updates the target values of the property based on the rule and the new value.
    /// 
    /// - If the rule is ``INDISwitchRule.atMostOne`` or ``INDISwitchRule.oneOfMany``, and the new value is `true`, 
    /// the other values are set to `false`.
    /// - If the new value is `false`, and the rule is ``INDISwitchRule.oneOfMany``, we do not know which other 
    /// value is `true` (unless there are only two values), we throw an error.
    /// - If the the rule is ``INDISwitchRule.anyOfMany``, all values can be either `true` or `false`, we do not have
    /// to change any other values.
    /// - If the new value is `false`, and the rule is ``INDISwitchRule.atMostOne``, we also do not have to change
    /// any other values. They will be false anyway.
    /// 
    /// - Parameters:
    ///   - name: The name of the switch value to set
    ///   - booleanValue: The new value to set the switch value to for the given name
    /// - Throws: ``INDISwitchRuleErrors`` if the switch rule is violated
    public mutating func setTargetSwitchValue(name: INDIPropertyValueName, _ booleanValue: Bool) throws {
        var newTargetValues: [(INDIPropertyValueName, Bool)] = []
        newTargetValues.append((name, booleanValue))

        // All the other existing values
        let otherValues = targetSwitchValues?.filter { $0.name != name } ?? switchValues.filter { $0.name != name }

        if booleanValue && (rule == .atMostOne || rule == .oneOfMany) {
            for otherValue in otherValues {
                // All the other values are set to false
                newTargetValues.append((otherValue.name, false))
            }
        } else if !booleanValue && rule == .oneOfMany && otherValues.count == 1 {
            // If there is only one other value, and the new value is false, we set the other value to true
            newTargetValues.append((otherValues[0].name, true))
        }

        // An error can still be thrown if the rule is .oneOfMany and there are more than one other value while
        // the new value to be set is false. We cannot know which other value is `true`.
        try self.setTargetSwitchValues(newTargetValues)
    }
}

public struct SwitchValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public var switchValue: Bool
    public var value: INDIValue.Value {
        get {
            return .boolean(switchValue)
        }
        set {
            if case .boolean(let booleanValue) = newValue {
                switchValue = booleanValue
            }
        }
    }
}

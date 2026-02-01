import Foundation
import INDIProtocol

public struct NumberProperty: INDIProperty {

    public let name: INDIPropertyName
    public let type: INDIPropertyType = .number
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?

    public var numberValues: [NumberValue] {
        return values.compactMap { $0 as? NumberValue }
    }

    public var values: [any PropertyValue]

    public var targetNumberValues: [NumberValue]? {
        return targetValues?.compactMap { $0 as? NumberValue }
    }
    
    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 

    public mutating func setTargetNumberValues(_ targetNumberValues: [(name: INDIPropertyValueName, numberValue: Double)]) throws {
        var newTargetValues: [NumberValue] = self.targetNumberValues ?? numberValues
        for (name, numberValue) in targetNumberValues {
            if let index = newTargetValues.firstIndex(where: { $0.name == name }) {
                newTargetValues[index].numberValue = numberValue
            } else {
                throw INDIPropertyErrors.valueNotFound(
                    message: "Value with name \(name) does not exist",
                    propertyName: self.name,
                    valueName: name
                )
            }
        }
        self.targetValues = newTargetValues
        self.targetTimeStamp = Date()
    }

    public mutating func setTargetNumberValue(name: INDIPropertyValueName, _ numberValue: Double) throws {
        try self.setTargetNumberValues([(name: name, numberValue: numberValue)])
    }
}

public struct NumberValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public let format: String?
    public let min: Double?
    public let max: Double?
    public let step: Double?
    public let unit: String?

    public var numberValue: Double

    /// Creates a new NumberValue.
    ///
    /// - Parameters:
    ///   - name: The value name
    ///   - label: Optional human-readable label
    ///   - format: Optional printf-style format string
    ///   - min: Optional minimum value
    ///   - max: Optional maximum value
    ///   - step: Optional step size
    ///   - unit: Optional unit string
    ///   - numberValue: The numeric value
    public init(
        name: INDIPropertyValueName,
        label: String?,
        format: String?,
        min: Double?,
        max: Double?,
        step: Double?,
        unit: String?,
        numberValue: Double
    ) {
        self.name = name
        self.label = label
        self.format = format
        self.min = min
        self.max = max
        self.step = step
        self.unit = unit
        self.numberValue = numberValue
    }
    public var value: INDIValue.Value {
        get {
            return .number(numberValue)
        }
        set {
            if case .number(let numberValue) = newValue {
                self.numberValue = numberValue
            }
        }
    }

    /// Parsed representation of the `format` string, if available and valid.
    public var parsedFormat: INDIFormat? {
        guard let format = format else { return nil }
        return INDIFormat(raw: format)
    }

    /// Creates a new NumberValue with the current value but preserving attributes
    /// from the existing value if they are nil in this value.
    ///
    /// This is used when updating property values from update messages that may
    /// not include all the attribute metadata that was provided in the original
    /// define message.
    /// - Parameter existing: The existing value to take attributes from if not present in self
    /// - Returns: A new NumberValue with merged attributes
    public func mergingAttributes(from existing: NumberValue) -> NumberValue {
        return NumberValue(
            name: self.name,
            label: self.label ?? existing.label,
            format: self.format ?? existing.format,
            min: self.min ?? existing.min,
            max: self.max ?? existing.max,
            step: self.step ?? existing.step,
            unit: self.unit ?? existing.unit,
            numberValue: self.numberValue
        )
    }
}

import Foundation
import INDIProtocol

public struct TextProperty: INDIProperty {

    public let name: INDIPropertyName
    public let type: INDIPropertyType = .text
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?

    public func textValue(name: INDIPropertyValueName) -> String {
        return textValues.first(where: { $0.name == name })?.textValue ?? ""
    }

    public var textValues: [TextValue] {
        return values.compactMap { $0 as? TextValue }
    }

    public var values: [any PropertyValue]

    public var targetTextValues: [TextValue]? {
        return targetValues?.compactMap { $0 as? TextValue }
    }
    
    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 

    public mutating func setTargetTextValues(_ targetTextValues: [(name: INDIPropertyValueName, textValue: String)]) throws {
        var newTargetValues: [TextValue] = self.targetTextValues ?? textValues
        for (name, textValue) in targetTextValues {
            if let index = newTargetValues.firstIndex(where: { $0.name == name }) {
                newTargetValues[index].textValue = textValue
            } else {
                // Value with specified name does not exist.
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

    public mutating func setTargetTextValue(name: INDIPropertyValueName, _ textValue: String) throws {
        try self.setTargetTextValues([(name: name, textValue: textValue)])
    }
}

public struct TextValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?

    public var textValue: String
    public var value: INDIValue.Value {
        get {
            return .text(textValue)
        }
        set {
            if case .text(let stringValue) = newValue {
                textValue = stringValue
            }
        }
    }
}

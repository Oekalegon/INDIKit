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
}

public struct NumberValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public let format: String?
    public let min: Double?
    public let max: Double?
    public let step: Double?
    public let unit: String?

    public let numberValue: Double
    public var value: INDIValue.Value {
        return .number(numberValue)
    }
}

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
}

public struct TextValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?

    public let textValue: String
    public var value: INDIValue.Value {
        return .text(textValue)
    }
}

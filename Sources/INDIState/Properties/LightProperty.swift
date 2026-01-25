import Foundation
import INDIProtocol

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

    public var values: [any PropertyValue]

    public var targetLightValues: [LightValue]? {
        return targetValues?.compactMap { $0 as? LightValue }
    }

    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 
}

public struct LightValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    
    public let lightValue: INDIStatus
    public var value: INDIValue.Value {
        return .state(lightValue)
    }
}

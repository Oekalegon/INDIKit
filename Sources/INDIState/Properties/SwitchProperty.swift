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

    public var switchValues: [SwitchValue] {
        return values.compactMap { $0 as? SwitchValue }
    }

    public var values: [any PropertyValue]

    public var targetSwitchValues: [SwitchValue]? {
        return targetValues?.compactMap { $0 as? SwitchValue }
    }

    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 
}

public struct SwitchValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public let switchValue: Bool
    public var value: INDIValue.Value {
        return .boolean(switchValue)
    }
}

import Foundation
import INDIProtocol

public protocol INDIProperty: Sendable {

    var name: INDIPropertyName { get }
    var type: INDIPropertyType { get }
    var group: String? { get }
    var label: String? { get }
    var permissions: INDIPropertyPermissions? { get }
    var state: INDIStatus? { get }
    var timeout: Double? { get }

    var values: [any PropertyValue] { get set }
    var targetValues: [any PropertyValue]? { get set }

    var timeStamp: Date { get set }
    var targetTimeStamp: Date? { get set }
}

public protocol PropertyValue: Sendable {

    var name: INDIPropertyValueName { get }
    var label: String? { get }
    var value: INDIValue.Value { get set }
}

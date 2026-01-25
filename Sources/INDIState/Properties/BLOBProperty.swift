import Foundation
import INDIProtocol

public struct BLOBProperty: INDIProperty {

    public let name: INDIPropertyName
    public let type: INDIPropertyType = .blob
    public let group: String?
    public let label: String?
    public let permissions: INDIPropertyPermissions?
    public let state: INDIStatus?
    public let timeout: Double?

    public var blobValues: [BLOBValue] {
        return values.compactMap { $0 as? BLOBValue }
    }

    public var values: [any PropertyValue]

    public var targetBlobValues: [BLOBValue]? {
        return targetValues?.compactMap { $0 as? BLOBValue }
    }

    public var targetValues: [any PropertyValue]?

    public var timeStamp: Date
    public var targetTimeStamp: Date? 
}

public struct BLOBValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public let format: String?
    public let size: Int?
    public let compressed: Bool?
    public let blobValue: Data
    public var value: INDIValue.Value {
        return .blob(blobValue)
    }
}

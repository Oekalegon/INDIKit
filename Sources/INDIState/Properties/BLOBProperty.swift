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

    public mutating func setTargetBlobValue(
        name: INDIPropertyValueName,
        format: String?,
        size: Int?,
        compressed: Bool?,
        blobValue: Data
    ) throws {
        var newTargetValues: [BLOBValue] = self.targetBlobValues ?? blobValues
        for value in newTargetValues {
            var newValue = value
            if value.name == name {
                newValue.format = format
                newValue.size = size
                newValue.compressed = compressed
                newValue.blobValue = blobValue
            }
            newTargetValues.append(newValue)
        }
        self.targetValues = newTargetValues
        self.targetTimeStamp = Date()
    }
}

public struct BLOBValue: PropertyValue {

    public let name: INDIPropertyValueName
    public let label: String?
    public var format: String?
    public var size: Int?
    public var compressed: Bool?
    public var blobValue: Data
    public var value: INDIValue.Value {
        get {
            return .blob(blobValue)
        }
        set {
            if case .blob(let blobValue) = newValue {
                self.blobValue = blobValue
            }
        }
    }

    /// Creates a new BLOBValue with the current value but preserving attributes
    /// from the existing value if they are nil in this value.
    ///
    /// This is used when updating property values from update messages that may
    /// not include all the attribute metadata that was provided in the original
    /// define message.
    /// - Parameter existing: The existing value to take attributes from if not present in self
    /// - Returns: A new BLOBValue with merged attributes
    public func mergingAttributes(from existing: BLOBValue) -> BLOBValue {
        return BLOBValue(
            name: self.name,
            label: self.label ?? existing.label,
            format: self.format ?? existing.format,
            size: self.size ?? existing.size,
            compressed: self.compressed ?? existing.compressed,
            blobValue: self.blobValue
        )
    }
}

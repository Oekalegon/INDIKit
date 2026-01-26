import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for BLOBProperty that enables SwiftUI integration.
@Observable
public class ObservableBLOBProperty: ObservableINDIProperty {
    
    private var _property: BLOBProperty
    private weak var device: ObservableINDIDevice?
    
    public var name: INDIPropertyName { _property.name }
    public var type: INDIPropertyType { .blob }
    public var group: String? { _property.group }
    public var label: String? { _property.label }
    public var permissions: INDIPropertyPermissions? { _property.permissions }
    public var state: INDIStatus? { _property.state }
    public var timeout: Double? { _property.timeout }
    public var values: [any PropertyValue] { _property.values }
    public var targetValues: [any PropertyValue]? { _property.targetValues }
    public var timeStamp: Date { _property.timeStamp }
    public var targetTimeStamp: Date? { _property.targetTimeStamp }
    
    /// Get BLOB values
    public var blobValues: [BLOBValue] {
        return _property.blobValues
    }
    
    /// Get target BLOB values
    public var targetBlobValues: [BLOBValue]? {
        return _property.targetBlobValues
    }
    
    init(property: BLOBProperty, device: ObservableINDIDevice) {
        self._property = property
        self.device = device
    }
    
    public func sync(from property: any INDIProperty) {
        guard let blobProperty = property as? BLOBProperty else { return }
        self._property = blobProperty
    }
    
    /// Set a target BLOB value.
    /// 
    /// This will update the underlying property and send the update to the server.
    /// - Parameters:
    ///   - name: The name of the BLOB value
    ///   - format: Optional format string
    ///   - size: Optional size hint
    ///   - compressed: Optional compression flag
    ///   - blobValue: The BLOB data
    /// - Throws: An error if the value name doesn't exist
    public func setTargetBlobValue(
        name: INDIPropertyValueName,
        format: String?,
        size: Int?,
        compressed: Bool?,
        blobValue: Data
    ) async throws {
        var property = _property
        try property.setTargetBlobValue(
            name: name,
            format: format,
            size: size,
            compressed: compressed,
            blobValue: blobValue
        )
        self._property = property
        
        // Update the device in the registry
        if let device = device {
            try await device.setProperty(self)
        }
    }
}


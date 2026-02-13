import Foundation
import INDIProtocol
import INDIState
import Observation

/// Observable wrapper for BLOBProperty that enables SwiftUI integration.
@Observable
public class ObservableBLOBProperty: ObservableINDIProperty {
    
    private var _property: BLOBProperty
    private weak var device: ObservableINDIDevice?
    
    // Progress tracking helper
    private var progressTracker: BLOBProgressTracker?
    
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
    
    /// Get the image format for a specific BLOB value.
    ///
    /// The format is typically ".fits" or ".fits.z" for compressed FITS files.
    /// - Parameter valueName: The name of the BLOB value
    /// - Returns: The format string if available, otherwise nil
    public func imageFormat(valueName: INDIPropertyValueName) -> String? {
        return blobValues.first(where: { $0.name == valueName })?.format
    }
    
    /// Check if a BLOB value is compressed.
    ///
    /// Compression is indicated by the format ending with ".z" or the compressed flag being true.
    /// - Parameter valueName: The name of the BLOB value
    /// - Returns: True if the BLOB is compressed, false otherwise
    public func isCompressed(valueName: INDIPropertyValueName) -> Bool {
        guard let blobValue = blobValues.first(where: { $0.name == valueName }) else {
            return false
        }
        
        // Check format for .z extension (e.g., ".fits.z")
        if let format = blobValue.format, format.hasSuffix(".z") {
            return true
        }
        
        // Check compressed flag
        return blobValue.compressed == true
    }
    
    /// Get the expected uncompressed size for a BLOB value.
    ///
    /// This is the size attribute from the `<oneBLOB>` element, representing
    /// the uncompressed binary size in bytes.
    /// - Parameter valueName: The name of the BLOB value
    /// - Returns: The expected size in bytes if available, otherwise nil
    public func expectedSize(valueName: INDIPropertyValueName) -> Int? {
        return blobValues.first(where: { $0.name == valueName })?.size
    }
    
    /// Enable BLOB reception for this property.
    ///
    /// This sends an enableBLOB message to the server to enable BLOB data transmission
    /// for this property. BLOB reception must be enabled before capture starts.
    /// - Parameter state: The BLOB sending state (typically `.also` or `.on`)
    /// - Throws: An error if the device is not found or if sending fails
    public func enableBLOBReception(state: BLOBSendingState) async throws {
        guard let device = device else {
            throw NSError(
                domain: "ObservableBLOBProperty",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Device not available"]
            )
        }
        
        try await device.enableBLOB(property: name, state: state)
    }
    
    /// Start progress tracking for BLOB downloads.
    ///
    /// This monitors the raw data stream to track download progress in real-time.
    /// Progress updates are published via the returned stream; callers can
    /// consume the stream and update UI state on the main actor as needed.
    /// - Parameter valueName: The name of the BLOB value to track
    /// - Returns: A stream of progress updates (0.0 to 1.0)
    /// - Throws: An error if the device or registry is not available
    public func startProgressTracking(valueName: INDIPropertyValueName) async throws -> AsyncStream<Double> {
        guard let device = device else {
            throw NSError(
                domain: "ObservableBLOBProperty",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Device not available"]
            )
        }
        
        // Get the registry from the device
        let registry = device.registry
        
        // Get raw data stream
        guard let rawStream = try await registry.rawDataStream() else {
            throw NSError(
                domain: "ObservableBLOBProperty",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Raw data stream not available"]
            )
        }
        
        // Create or reuse progress tracker
        if progressTracker == nil {
            progressTracker = BLOBProgressTracker()
        }
        
        // Start tracking and return the progress stream to the caller
        return await progressTracker!.startTracking(
            device: device.name,
            property: name,
            valueName: valueName,
            rawStream: rawStream
        )
    }
    
    /// Wait for a BLOB image to be received.
    ///
    /// This waits for the specified BLOB value to be received after capture completes.
    /// The image data is automatically sent by the device after capture.
    /// - Parameters:
    ///   - valueName: The name of the BLOB value to wait for
    ///   - timeout: Maximum time to wait in seconds (default: 300 seconds)
    /// - Returns: The image data if received, otherwise nil
    /// - Throws: An error if timeout occurs or if an error occurs
    public func waitForImage(valueName: INDIPropertyValueName, timeout: TimeInterval = 300) async throws -> Data? {
        let startTime = Date()
        
        // Poll for the image data
        while Date().timeIntervalSince(startTime) < timeout {
            if let imageData = blobValue(name: valueName), !imageData.isEmpty {
                return imageData
            }
            
            // Wait a bit before checking again
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Timeout
        throw NSError(
            domain: "ObservableBLOBProperty",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Timeout waiting for image after \(timeout) seconds"]
        )
    }
}

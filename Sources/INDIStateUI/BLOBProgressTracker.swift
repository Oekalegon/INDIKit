import Foundation
import INDIProtocol
import os

/// Tracks progress of BLOB downloads by monitoring raw data stream.
///
/// This actor monitors the raw TCP data stream to detect `<oneBLOB>` opening tags
/// and extract size/format attributes for accurate progress tracking.
actor BLOBProgressTracker {
    private static let logger = Logger(subsystem: "com.lapsedPacifist.INDIStateUI", category: "BLOBProgressTracker")
    
    private var rawDataStream: AsyncThrowingStream<Data, Error>?
    private var trackedBLOBs: [String: BLOBTrackingInfo] = [:]
    private var buffer = Data()
    private var monitoringTask: Task<Void, Error>?
    
    /// Information about a BLOB being tracked.
    struct BLOBTrackingInfo {
        let device: String
        let property: String
        let valueName: String  // from oneBLOB name attribute
        let expectedSize: Int  // from oneBLOB size attribute (uncompressed binary)
        let format: String?  // from oneBLOB format attribute
        var bytesReceived: Int = 0
        var messageStartIndex: Int = 0  // position where <updateBLOBVector started
        
        var estimatedTotalXMLSize: Int {
            // size * 4/3 (base64) + XML overhead
            return Int(Double(expectedSize) * 4.0 / 3.0) + 500
        }
        
        var progress: Double {
            guard estimatedTotalXMLSize > 0 else { return 0.0 }
            return min(1.0, Double(bytesReceived) / Double(estimatedTotalXMLSize))
        }
    }
    
    /// Start tracking BLOB downloads for a specific property.
    ///
    /// - Parameters:
    ///   - device: The device name
    ///   - property: The property name
    ///   - valueName: The value name to track
    ///   - rawStream: The raw data stream from the server
    /// - Returns: A stream of progress updates (0.0 to 1.0)
    func startTracking(
        device: String,
        property: INDIPropertyName,
        valueName: INDIPropertyValueName,
        rawStream: AsyncThrowingStream<Data, Error>
    ) -> AsyncThrowingStream<Double, Error> {
        // Stop any existing monitoring
        stopTracking()
        
        self.rawDataStream = rawStream
        let trackingKey = "\(device):\(property.indiName):\(valueName.indiName)"
        
        return AsyncThrowingStream<Double, Error> { continuation in
            // Start monitoring task
            Task {
                do {
                    guard let stream = self.rawDataStream else {
                        continuation.finish()
                        return
                    }
                    
                    for try await data in stream {
                        await self.processRawChunk(data, trackingKey: trackingKey, continuation: continuation)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Stop tracking and clean up resources.
    func stopTracking() {
        monitoringTask?.cancel()
        monitoringTask = nil
        trackedBLOBs.removeAll()
        buffer.removeAll()
    }
    
    /// Process a raw data chunk and update progress.
    private func processRawChunk(
        _ data: Data,
        trackingKey: String,
        continuation: AsyncThrowingStream<Double, Error>.Continuation
    ) async {
        buffer.append(data)
        
        // Limit buffer size to prevent memory issues (keep last 10MB for scanning)
        let maxBufferSize = 10 * 1024 * 1024 // 10MB
        if buffer.count > maxBufferSize {
            // Keep only the last portion
            let keepSize = maxBufferSize / 2
            buffer = buffer.suffix(keepSize)
        }
        
        // Convert buffer to string for scanning
        guard let bufferString = String(data: buffer, encoding: .utf8) else {
            // Invalid UTF-8, skip this chunk
            return
        }
        
        // Check for <updateBLOBVector> start
        if let updateStart = bufferString.range(of: "<updateBLOBVector") {
            // Extract device and property from updateBLOBVector attributes
            let updateEnd = bufferString[updateStart.upperBound...].firstIndex(of: ">") ?? bufferString.endIndex
            let updateTag = String(bufferString[updateStart.lowerBound..<bufferString.index(after: updateEnd)])
            
            if let (device, property) = extractUpdateAttributes(from: updateTag) {
                // Look for <oneBLOB> tag within this update
                if let oneBlobInfo = detectOneBLOBStart(in: bufferString, after: updateStart.upperBound) {
                    let blobKey = "\(device):\(property):\(oneBlobInfo.valueName)"
                    
                    // Check if this matches what we're tracking
                    if blobKey == trackingKey {
                        // Create or update tracking info
                        if trackedBLOBs[blobKey] == nil {
                            // Calculate byte offset of message start
                            let updateStartBytes = String(bufferString[..<updateStart.lowerBound]).utf8.count
                            trackedBLOBs[blobKey] = BLOBTrackingInfo(
                                device: device,
                                property: property,
                                valueName: oneBlobInfo.valueName,
                                expectedSize: oneBlobInfo.size,
                                format: oneBlobInfo.format,
                                bytesReceived: 0,
                                messageStartIndex: updateStartBytes
                            )
                        }
                    }
                }
            }
        }
        
        // Update progress for tracked BLOBs
        for (key, var info) in trackedBLOBs where key == trackingKey {
            // Calculate bytes received from message start to current buffer end
            let currentBytes = buffer.count
            info.bytesReceived = max(0, currentBytes - info.messageStartIndex)
            
            let progress = info.progress
            trackedBLOBs[key] = info
            continuation.yield(progress)
            
            // Check if we've received the complete message (look for closing tag)
            if bufferString.contains("</updateBLOBVector>") {
                continuation.yield(1.0)
                trackedBLOBs.removeValue(forKey: key)
            }
        }
    }
    
    /// Extract device and property from <updateBLOBVector> tag.
    private func extractUpdateAttributes(from tag: String) -> (device: String, property: String)? {
        let attributes = extractAttributes(from: tag)
        guard let device = attributes["device"],
              let property = attributes["name"] else {
            return nil
        }
        return (device: device, property: property)
    }
    
    /// Detect <oneBLOB> opening tag and extract attributes.
    private func detectOneBLOBStart(in buffer: String, after startIndex: String.Index) -> (valueName: String, size: Int, format: String?)? {
        // Find "<oneBLOB" after the given index
        let searchRange = buffer[startIndex...]
        guard let tagStart = searchRange.range(of: "<oneBLOB") else {
            return nil
        }
        
        // Find the closing '>' of the opening tag
        guard let tagEnd = buffer[tagStart.upperBound...].firstIndex(of: ">") else {
            return nil
        }
        
        // Extract the tag content: <oneBLOB name="..." size="..." format="...">
        let tagContent = String(buffer[tagStart.lowerBound..<buffer.index(after: tagEnd)])
        
        // Extract attributes
        let attributes = extractAttributes(from: tagContent)
        
        guard let name = attributes["name"],
              let sizeString = attributes["size"],
              let size = Int(sizeString) else {
            return nil
        }
        
        return (valueName: name, size: size, format: attributes["format"])
    }
    
    /// Extract attributes from an XML tag string.
    ///
    /// Handles quoted attribute values properly, similar to XMLParser.
    /// Skips the tag name and only parses attributes.
    private func extractAttributes(from tag: String) -> [String: String] {
        var attributes: [String: String] = [:]
        
        // Find the end of the tag name (first space or >)
        guard let tagNameEnd = tag.firstIndex(where: { $0 == " " || $0 == ">" || $0 == "/" }) else {
            return attributes
        }
        
        // Start parsing after the tag name
        var i = tag.index(after: tagNameEnd)
        var inQuotes = false
        var quoteChar: Character?
        var currentAttrName: String?
        var currentAttrValue: String?
        var parsingName = true
        
        while i < tag.endIndex {
            let char = tag[i]
            
            // Handle quotes
            if char == "\"" || char == "'" {
                if !inQuotes {
                    inQuotes = true
                    quoteChar = char
                    parsingName = false
                } else if char == quoteChar {
                    inQuotes = false
                    quoteChar = nil
                    // Save attribute
                    if let name = currentAttrName, let value = currentAttrValue {
                        attributes[name] = value
                    }
                    currentAttrName = nil
                    currentAttrValue = nil
                    parsingName = true
                } else if inQuotes {
                    currentAttrValue?.append(char)
                }
            } else if inQuotes {
                // Inside quoted value
                if currentAttrValue == nil {
                    currentAttrValue = String(char)
                } else {
                    currentAttrValue?.append(char)
                }
            } else if char == "=" {
                // Attribute name finished, start value
                parsingName = false
            } else if char.isWhitespace {
                // Whitespace outside quotes - reset for next attribute
                if !parsingName && currentAttrValue == nil {
                    parsingName = true
                    currentAttrName = nil
                }
            } else if parsingName {
                // Parsing attribute name
                if currentAttrName == nil {
                    currentAttrName = String(char)
                } else {
                    currentAttrName?.append(char)
                }
            }
            
            i = tag.index(after: i)
        }
        
        return attributes
    }
}

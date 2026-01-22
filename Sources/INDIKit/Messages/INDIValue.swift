import Foundation

/// An INDI property value with metadata.
///
/// INDI values contain both the actual value data and metadata about that value
/// such as name, label, format, min/max, step, and unit.
public struct INDIValue: Sendable {
    /// Required: The element name of this value.
    public let name: INDIPropertyValueName
    
    /// Optional: Human-readable label for this value.
    public let label: String?
    
    /// Optional: printf-style format string.
    public let format: String?
    
    /// Optional: Minimum value (for number types).
    public let min: Double?
    
    /// Optional: Maximum value (for number types).
    public let max: Double?
    
    /// Optional: Step size (for number types).
    public let step: Double?
    
    /// Optional: Unit string (e.g., "mm", "degrees", "Hz").
    public let unit: String?
    
    /// The actual value data.
    public let value: Value
    
    /// The type of value stored.
    public enum Value: Sendable {
        case text(String)
        case number(Double)
        case boolean(Bool)
        case light(Bool)
        case blob(Data)
    }
    
    /// Initialize from an XML node representation.
    ///
    /// - Parameter xmlNode: The XML node representing the value element
    /// - Parameter propertyType: The type of property this value belongs to (used to parse the value correctly)
    init?(xmlNode: XMLNodeRepresentation, propertyType: INDIPropertyType) {
        let attrs = xmlNode.attributes
        
        // Extract required name
        guard let nameString = attrs["name"] else {
            return nil
        }
        self.name = INDIPropertyValueName(indiName: nameString)
        
        // Extract optional metadata
        self.label = attrs["label"]
        self.format = attrs["format"]
        
        if let minString = attrs["min"], let minValue = Double(minString) {
            self.min = minValue
        } else {
            self.min = nil
        }
        
        if let maxString = attrs["max"], let maxValue = Double(maxString) {
            self.max = maxValue
        } else {
            self.max = nil
        }
        
        if let stepString = attrs["step"], let stepValue = Double(stepString) {
            self.step = stepValue
        } else {
            self.step = nil
        }
        
        self.unit = attrs["unit"]
        
        // Parse the actual value from text content
        self.value = Self.parseValue(from: xmlNode.text ?? "", propertyType: propertyType)
    }
    
    /// Parse a value from text content based on property type.
    private static func parseValue(from textContent: String, propertyType: INDIPropertyType) -> Value {
        switch propertyType {
        case .text:
            return .text(textContent)
            
        case .number:
            if let numberValue = Double(textContent) {
                return .number(numberValue)
            } else {
                // Invalid number, use 0.0 as fallback
                return .number(0.0)
            }
            
        case .toggle:
            // INDI uses "On"/"Off" for switches
            return .boolean(parseBoolean(from: textContent))
            
        case .light:
            // Lights also use "On"/"Off"
            return .light(parseBoolean(from: textContent))
            
        case .blob:
            // BLOBs are base64-encoded
            if let data = Data(base64Encoded: textContent) {
                return .blob(data)
            } else {
                // Invalid base64, use empty data as fallback
                return .blob(Data())
            }
        }
    }
    
    /// Parse a boolean value from INDI text format.
    private static func parseBoolean(from text: String) -> Bool {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "on" || normalized == "true" || normalized == "1"
    }
}

import Foundation
import os

/// An INDI property value with metadata.
///
/// INDI values contain both the actual value data and metadata about that value
/// such as name, label, format, min/max, step, and unit.
public struct INDIValue: Sendable {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
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
    
    /// Optional: Size hint for BLOB values.
    public let size: Int?
    
    /// Optional: Compression flag for BLOB values (runtime only, oneBLOB).
    public let compressed: Bool?
    
    /// The actual value data.
    public let value: Value
    
    /// Diagnostic messages for the value.
    public private(set) var diagnostics: [INDIDiagnostics]
    
    /// The type of value stored.
    public enum Value: Sendable {
        case text(String)
        case number(Double)
        case boolean(Bool)
        case state(INDIState)  // State value for light properties: Idle, Ok, Busy, or Alert
        case blob(Data)
    }
    
    /// Initialize from an XML node representation.
    ///
    /// - Parameter xmlNode: The XML node representing the value element
    /// - Parameter propertyType: The type of property this value belongs to (used to parse the value correctly)
    /// - Parameter propertyName: The name of the parent property (used to validate the value name)
    init?(xmlNode: XMLNodeRepresentation, propertyType: INDIPropertyType, propertyName: INDIPropertyName) {
        // Initialize diagnostics array at the start
        self.diagnostics = []
        
        let attrs = xmlNode.attributes
        
        // Extract required name
        guard let nameString = attrs["name"] else {
            let elementName = xmlNode.name
            let propType = propertyType.rawValue
            let message = "Failed to parse INDI value: missing 'name' attribute in element " +
                "'\(elementName)' for property type '\(propType)'"
            Self.logger.warning("\(message)")
            return nil
        }
        let valueName = INDIPropertyValueName(indiName: nameString)
        self.name = valueName
        
        // Validate value name (only if property is known)
        if case .other = propertyName {
            // Property is unknown, so we can't validate value names - skip all validation
        } else {
            // Property is known, so we can validate value names
            // Check if value name is expected for this property
            if let expectedNames = valueName.expectedValueNames(for: propertyName) {
                if !expectedNames.contains(where: { $0.indiName == valueName.indiName }) {
                    let expectedList = expectedNames.map { $0.indiName }.joined(separator: ", ")
                    let message = "Value name '\(valueName.indiName)' is not expected for property " +
                        "'\(propertyName.indiName)'. Expected: \(expectedList)"
                    INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
                }
            } else {
                // If there are no expected value names, check if the value name is unknown,
                // if it is unknown, log a note
                if case .other(let unknownName) = valueName {
                    let message = "Unknown value name '\(unknownName)'"
                    INDIDiagnostics.logNote(message, logger: Self.logger, diagnostics: &self.diagnostics)
                } else {
                    // If it is however a known value name, but not expected for this property, 
                    // log a warning
                    let message = "Value name '\(valueName.indiName)' is not expected for property " +
                        "'\(propertyName.indiName)'"
                    INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
                }
            }
        }
        
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
        
        // Validate that min <= max if both are available
        if let minValue = self.min, let maxValue = self.max, minValue > maxValue {
            let message = "Minimum value \(minValue) is greater than maximum value \(maxValue)"
            INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        if let stepString = attrs["step"], let stepValue = Double(stepString) {
            self.step = stepValue
        } else {
            self.step = nil
        }
        
        self.unit = attrs["unit"]
        
        if let sizeString = attrs["size"], let sizeValue = Int(sizeString) {
            self.size = sizeValue
        } else {
            self.size = nil
        }
        
        if let compressedString = attrs["compressed"] {
            self.compressed = Self.parseBoolean(
                from: compressedString,
                context: "for 'compressed' attribute",
                diagnostics: &self.diagnostics
            )
        } else {
            self.compressed = nil
        }
        
        // Parse the actual value from text content
        self.value = Self.parseValue(
            from: xmlNode.text ?? "",
            propertyType: propertyType,
            min: self.min,
            max: self.max,
            diagnostics: &self.diagnostics
        )
        
        validate(attrs: attrs, propertyType: propertyType)
    }
    
    /// Parse a value from text content based on property type.
    private static func parseValue(
        from textContent: String,
        propertyType: INDIPropertyType,
        min: Double?,
        max: Double?,
        diagnostics: inout [INDIDiagnostics]
    ) -> Value {
        switch propertyType {
        case .text:
            return .text(textContent.trimmingCharacters(in: .whitespacesAndNewlines))
            
        case .number:
            let trimmed = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let numberValue = Double(trimmed) else {
                let message = "Invalid number value: '\(trimmed)'. Expected a numeric value"
                INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &diagnostics)
                // Invalid number, use 0.0 as fallback
                return .number(0.0)
            }
            
            // Validate range if min/max are available
            if let minValue = min, numberValue < minValue {
                let message = "Number value \(numberValue) is below minimum \(minValue)"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
            }
            
            if let maxValue = max, numberValue > maxValue {
                let message = "Number value \(numberValue) is above maximum \(maxValue)"
                INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
            }
            
            return .number(numberValue)
            
        case .toggle:
            // INDI uses "On"/"Off" for switches
            return .boolean(parseBoolean(from: textContent, context: "value", diagnostics: &diagnostics))
            
        case .light:
            // Lights use state strings: "Idle", "Ok", "Busy", "Alert" (case-insensitive)
            return .state(parseLightState(from: textContent, diagnostics: &diagnostics))
            
        case .blob:
            // BLOBs are base64-encoded
            let trimmed = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if let data = Data(base64Encoded: trimmed) {
                return .blob(data)
            } else {
                // Invalid base64, use empty data as fallback
                return .blob(Data())
            }
        }
    }
    
    /// Parse a boolean value from INDI text format.
    /// Validates the input, logs a warning if invalid, and adds diagnostic.
    private static func parseBoolean(
        from text: String,
        context: String = "value",
        diagnostics: inout [INDIDiagnostics]
    ) -> Bool {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let validValues = ["on", "off", "true", "false", "1", "0"]
        let isValid = validValues.contains(normalized)
        
        if !isValid {
            let message = "Invalid boolean \(context): '\(text)'. " +
                "Expected 'On', 'Off', 'True', 'False', '1', or '0'"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &diagnostics)
        }
        
        // Parse: "on", "true", "1" are true; "off", "false", "0" are false
        return normalized == "on" || normalized == "true" || normalized == "1"
    }
    
    /// Parse a light state value from INDI text format.
    /// Lights use state strings: "Idle", "Ok", "Busy", "Alert" (case-insensitive).
    /// Returns the corresponding INDIState enum value with proper capitalization.
    private static func parseLightState(
        from text: String,
        diagnostics: inout [INDIDiagnostics]
    ) -> INDIState {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try exact match first (most common case)
        if let found = INDIState.allCases.first(where: { $0.indiValue == trimmed }) {
            return found
        }
        
        // Try case-insensitive match
        let normalized = trimmed.lowercased()
        if let found = INDIState.allCases.first(where: { $0.indiValue.lowercased() == normalized }) {
            INDIDiagnostics.logWarning("Found light state with wrong capitalization: '\(trimmed)'", logger: Self.logger, diagnostics: &diagnostics)
            return found
        }
        
        // Invalid state - log warning and return default
        let expectedStates = INDIState.allCases.map { $0.indiValue }.joined(separator: "', '")
        let message = "Invalid light state: '\(trimmed)'. " +
            "Expected '\(expectedStates)'"
        INDIDiagnostics.logError(message, logger: Self.logger, diagnostics: &diagnostics)
        
        return .idle
    }
    
    // MARK: - Validation
    
    /// Known INDI value attributes.
    private static let knownAttributes = [
        "name", "label", "format", "min", "max", "step", "unit", "size", "compressed"
    ]
    
    private mutating func validate(attrs: [String: String], propertyType: INDIPropertyType) {
        // Check for unknown attributes
        let unknownAttrs = attrs.keys.filter { !Self.knownAttributes.contains($0) }
        for unknownAttr in unknownAttrs {
            let message = "Unknown attribute '\(unknownAttr)' in INDI value element"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // Format is only valid for Number and BLOB types
        if self.format != nil && propertyType != .number && propertyType != .blob {
            let message = "Format is ignored for non-number, non-blob property types"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // min, max, step, unit are only valid for Number type
        let numberOnlyAttributes: [(String, Any?)] = [
            ("Min", self.min),
            ("Max", self.max),
            ("Step", self.step),
            ("Unit", self.unit)
        ]
        for (name, value) in numberOnlyAttributes where value != nil && propertyType != .number {
            let message = "\(name) is ignored for non-number property types"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
        
        // size and compressed are only valid for BLOB type
        let blobOnlyAttributes: [(String, Any?)] = [
            ("Size", self.size),
            ("Compressed", self.compressed)
        ]
        for (name, value) in blobOnlyAttributes where value != nil && propertyType != .blob {
            let message = "\(name) is ignored for non-blob property types"
            INDIDiagnostics.logWarning(message, logger: Self.logger, diagnostics: &self.diagnostics)
        }
    }
}

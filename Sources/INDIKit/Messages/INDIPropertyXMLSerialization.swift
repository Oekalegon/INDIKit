import Foundation

/// Escape XML special characters in attribute values and text content.
private func escapeXML(_ string: String) -> String {
    return string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&apos;")
}

extension INDIProperty {
    /// Serialize this property to XML string format.
    ///
    /// - Returns: XML string representation of the property
    /// - Throws: An error if the property cannot be serialized
    func toXML() throws -> String {
        // Special handling for getProperties and enableBLOB operations
        if operation == .get {
            return serializeGetProperties()
        } else if operation == .enableBlob {
            return serializeEnableBLOB()
        }
        
        // Build the opening tag
        var xml = "<\(xmlNode.name)"
        
        // Validate device and name for operations that require them
        if operation == .set || operation == .update || operation == .define {
            guard let deviceValue = device else {
                throw NSError(domain: "INDIProperty", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "device is required for .\(operation.rawValue) operations"
                ])
            }
            guard let nameValue = name else {
                throw NSError(domain: "INDIProperty", code: 2, userInfo: [
                    NSLocalizedDescriptionKey: "name is required for .\(operation.rawValue) operations"
                ])
            }
            
            // For set operations, only include device and name
            if operation == .set {
                xml += " device=\"\(escapeXML(deviceValue))\""
                xml += " name=\"\(escapeXML(nameValue.indiName))\""
            } else {
                // For update and define operations, include all attributes
                for (key, value) in xmlNode.attributes.sorted(by: { $0.key < $1.key }) {
                    xml += " \(key)=\"\(escapeXML(value))\""
                }
            }
        } else {
            // For other operations, include all attributes
            for (key, value) in xmlNode.attributes.sorted(by: { $0.key < $1.key }) {
                xml += " \(key)=\"\(escapeXML(value))\""
            }
        }
        
        xml += ">"
        
        // Add child elements (values)
        // For getProperties, there are no values, so skip
        if operation != .get {
            for value in values {
                xml += "\n"
                // propertyType is required for non-get operations
                guard let propType = propertyType else {
                    throw NSError(domain: "INDIProperty", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "propertyType is required for operation \(operation.rawValue)"
                    ])
                }
                xml += try value.toXML(propertyType: propType)
            }
        }
        
        // Close the tag
        xml += "\n</\(xmlNode.name)>"
        
        return xml
    }
    
    /// Serialize getProperties operation.
    ///
    /// Format: `<getProperties version='1.7'/>` or `<getProperties device="..." name="..." version='1.7'/>`
    private func serializeGetProperties() -> String {
        var xml = "<getProperties"
        
        // Add version attribute (default to 1.7 if not specified)
        let version = xmlNode.attributes["version"] ?? "1.7"
        xml += " version='\(version)'"
        
        // Add device and name if specified (they are optional for getProperties)
        if let device = device, !device.isEmpty {
            xml += " device=\"\(escapeXML(device))\""
        }
        if let name = name {
            xml += " name=\"\(escapeXML(name.indiName))\""
        }
        
        xml += "/>"
        return xml
    }
    
    /// Serialize enableBLOB operation.
    ///
    /// Format: `<enableBLOB device="..." name="...">Also</enableBLOB>` or `<enableBLOB device="..." name="...">Never</enableBLOB>`
    private func serializeEnableBLOB() -> String {
        var xml = "<enableBLOB"
        
        // Add device and name (required for enableBLOB)
        let deviceValue = device ?? "UNKNOWN"
        let nameValue = name?.indiName ?? "UNKNOWN"
        xml += " device=\"\(escapeXML(deviceValue))\""
        xml += " name=\"\(escapeXML(nameValue))\""
        
        xml += ">"
        
        // Get the value from the first value if present, otherwise default to "Also"
        let blobValue: String
        if let firstValue = values.first,
           case .text(let text) = firstValue.value {
            blobValue = text
        } else {
            blobValue = "Also" // Default: enable BLOB for this property
        }
        
        xml += escapeXML(blobValue)
        xml += "</enableBLOB>"
        
        return xml
    }
}

extension INDIValue {
    /// Serialize this value to XML string format.
    ///
    /// - Parameter propertyType: The type of property this value belongs to
    /// - Returns: XML string representation of the value
    /// - Throws: An error if the value cannot be serialized
    func toXML(propertyType: INDIPropertyType) throws -> String {
        let elementName = elementName(for: propertyType)
        var xml = "  <\(elementName) name=\"\(escapeXML(name.indiName))\""
        
        // Add optional attributes
        if let label = label {
            xml += " label=\"\(escapeXML(label))\""
        }
        
        // Add type-specific attributes
        xml += typeSpecificAttributes(for: propertyType)
        
        xml += ">"
        xml += escapeXML(valueString)
        xml += "</\(elementName)>"
        
        return xml
    }
    
    /// Get the XML element name for a property type.
    private func elementName(for propertyType: INDIPropertyType) -> String {
        switch propertyType {
        case .text: return "oneText"
        case .number: return "oneNumber"
        case .toggle: return "oneSwitch"
        case .light: return "oneLight"
        case .blob: return "oneBLOB"
        }
    }
    
    /// Get type-specific XML attributes.
    private func typeSpecificAttributes(for propertyType: INDIPropertyType) -> String {
        switch propertyType {
        case .number:
            return numberAttributes()
        case .blob:
            return blobAttributes()
        default:
            return ""
        }
    }
    
    /// Get number-specific attributes.
    private func numberAttributes() -> String {
        var attrs = ""
        if let format = format {
            attrs += " format=\"\(escapeXML(format))\""
        }
        if let min = min {
            attrs += " min=\"\(min)\""
        }
        if let max = max {
            attrs += " max=\"\(max)\""
        }
        if let step = step {
            attrs += " step=\"\(step)\""
        }
        if let unit = unit {
            attrs += " unit=\"\(escapeXML(unit))\""
        }
        return attrs
    }
    
    /// Get blob-specific attributes.
    private func blobAttributes() -> String {
        var attrs = ""
        if let format = format {
            attrs += " format=\"\(escapeXML(format))\""
        }
        if let size = size {
            attrs += " size=\"\(size)\""
        }
        if let compressed = compressed {
            attrs += " compressed=\"\(compressed ? "On" : "Off")\""
        }
        return attrs
    }
    
    /// Get the string representation of the value.
    private var valueString: String {
        switch value {
        case .text(let text):
            return text
        case .number(let num):
            return String(num)
        case .boolean(let bool):
            return bool ? "On" : "Off"
        case .state(let state):
            return state.indiValue
        case .blob(let data):
            return data.base64EncodedString()
        }
    }
}

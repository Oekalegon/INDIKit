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
        // Build the opening tag
        var xml = "<\(xmlNode.name)"
        
        // Add attributes (only device and name for set operations)
        if operation == .set {
            xml += " device=\"\(escapeXML(device))\""
            xml += " name=\"\(escapeXML(name.indiName))\""
        } else {
            // For other operations, include all attributes
            for (key, value) in xmlNode.attributes.sorted(by: { $0.key < $1.key }) {
                xml += " \(key)=\"\(escapeXML(value))\""
            }
        }
        
        xml += ">"
        
        // Add child elements (values)
        for value in values {
            xml += "\n"
            xml += try value.toXML(propertyType: propertyType)
        }
        
        // Close the tag
        xml += "\n</\(xmlNode.name)>"
        
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

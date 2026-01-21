import Foundation

public enum INDIPropertyType: String, Sendable, CaseIterable {

    /// A text property type.
    ///
    /// In INDI protocol, this is represented as "text".
    case text = "text"

    /// A number property type.
    ///
    /// In INDI protocol, this is represented as "number".
    case number = "number"

    /// A boolean on/off control property type.
    ///
    /// In INDI protocol, this is represented as "switch" but we use "toggle"
    /// as the case name since "switch" is a reserved keyword in Swift.
    case toggle = "switch"

    /// A light property type.
    ///
    /// In INDI protocol, this is represented as "light".
    case light = "light"

    /// A blob property type.
    ///
    /// In INDI protocol, this is represented as "blob".
    case blob = "blob"
    
    /// Initialize from an element name by matching property type keywords.
    ///
    /// - Parameter elementName: The XML element name (e.g., "defTextVector", "setNumberVector", "newSwitchVector")
    /// - Returns: The matching property type, or nil if no match is found
    public init?(elementName: String) {
        let lowercased = elementName.lowercased()
        
        // Iterate over all cases, checking if element name contains the raw value
        // Since .toggle has rawValue "switch", it will match "switch" automatically
        for propertyType in Self.allCases where lowercased.contains(propertyType.rawValue.lowercased()) {
            self = propertyType
            return
        }
        
        return nil
    }
}

import Foundation

/// Shared helper functions for parsing INDI property attributes from XML.
///
/// These helpers are used across multiple INDICommand implementations to extract
/// and parse common attributes like operation type, property type, permissions, state, etc.
internal enum INDIParsingHelpers {
    
    /// Extract the operation type from an XML element name.
    ///
    /// - Parameter elementName: The XML element name (e.g., "defTextVector", "setNumberVector")
    /// - Returns: The matching operation, or `.update` as default if not found
    static func extractOperation(from elementName: String) -> INDIOperation? {
        INDIOperation(elementName: elementName) ?? .update
    }
    
    /// Extract the property type from an XML element name.
    ///
    /// - Parameter elementName: The XML element name (e.g., "defTextVector", "setNumberVector")
    /// - Returns: The matching property type, or `.text` as default if not found
    static func extractPropertyType(from elementName: String) -> INDIPropertyType? {
        INDIPropertyType(elementName: elementName) ?? .text
    }
    
    /// Extract a property name from a string.
    ///
    /// - Parameter name: The property name string
    /// - Returns: An INDIPropertyName enum value
    static func extractProperty(from name: String) -> INDIPropertyName {
        INDIPropertyName(indiName: name)
    }
    
    /// Extract permissions from a permission string.
    ///
    /// - Parameter permString: The permission string (e.g., "ro", "wo", "rw")
    /// - Returns: An INDIPropertyPermissions enum value
    static func extractPermissions(from permString: String) -> INDIPropertyPermissions {
        INDIPropertyPermissions(indiValue: permString)
    }
    
    /// Extract state from a state string.
    ///
    /// - Parameter stateString: The state string (e.g., "Idle", "Ok", "Busy", "Alert")
    /// - Returns: An INDIState enum value
    static func extractState(from stateString: String) -> INDIStatus {
        INDIStatus(indiValue: stateString)
    }
    
    /// Extract timeout value from a timeout string.
    ///
    /// - Parameter timeoutString: The timeout string (e.g., "60")
    /// - Returns: The timeout as a Double, or nil if parsing fails
    static func extractTimeout(from timeoutString: String?) -> Double? {
        guard let timeoutString, let timeoutValue = Double(timeoutString) else {
            return nil
        }
        return timeoutValue
    }
    
    /// Extract timestamp from a timestamp string.
    ///
    /// Supports ISO8601 format with or without fractional seconds, and unix timestamps.
    /// Handles timezone-less timestamps correctly by treating them as UTC.
    ///
    /// - Parameter timestampString: The timestamp string (e.g., "2026-01-22T08:41:00")
    /// - Returns: A Date object, or nil if parsing fails
    static func extractTimestamp(from timestampString: String?) -> Date? {
        guard let timestampString else {
            return nil
        }
        
        // First try ISO8601DateFormatter with timezone requirement (handles timestamps with timezone)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestampString) {
            return date
        }
        
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: timestampString) {
            return date
        }
        
        // If that fails, try parsing as ISO8601 without timezone requirement (treat as UTC)
        // This handles timezone-less timestamps like "2026-01-22T08:41:00"
        if let date = parseISO8601WithoutTimezone(timestampString) {
            return date
        }
        
        // Fallback: try as unix timestamp
        if let unixTimestamp = Double(timestampString) {
            return Date(timeIntervalSince1970: unixTimestamp)
        }
        
        return nil
    }
    
    /// Parse an ISO8601 timestamp string without timezone, treating it as UTC.
    ///
    /// Handles formats like "2026-01-22T08:41:00" or "2026-01-22T08:41:00.123"
    ///
    /// - Parameter timestampString: The timestamp string without timezone
    /// - Returns: A Date object parsed as UTC, or nil if parsing fails
    private static func parseISO8601WithoutTimezone(_ timestampString: String) -> Date? {
        // Use DateFormatter with ISO8601 format but without timezone requirement
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        // Try with fractional seconds first: "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = formatter.date(from: timestampString) {
            return date
        }
        
        // Try without fractional seconds: "yyyy-MM-dd'T'HH:mm:ss"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: timestampString) {
            return date
        }
        
        return nil
    }
}

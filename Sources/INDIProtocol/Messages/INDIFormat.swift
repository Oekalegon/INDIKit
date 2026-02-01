import Foundation

/// Typed representation of an INDI format string.
///
/// Supports both standard printf-style formats (e.g. `"%.2f"`, `"%d"`)
/// and INDI-specific sexagesimal formats (e.g. `"%010.6m"`).
/// 
/// Sexagesimal formats are used to represent values in sexagesimal format, 
/// e.g. 12ʰ32ᵐ53ˢ4984 for Right Ascension and +45°14'03"0000 for Declination.
///
/// General shape: `%[flags][width][.precision][type]`
/// Sexagesimal: `%[flags][width][.precision]m`
public struct INDIFormat: Sendable, Equatable {
    public enum Flag: Character, CaseIterable, Sendable {
        case leftAdjust = "-"   // '-'
        case alwaysSign = "+"   // '+'
        case spaceSign  = " "   // ' '
        case alternate  = "#"   // '#'
        case zeroPad    = "0"   // '0'
    }

    public enum Kind: Equatable, Sendable {
        /// A standard printf-style type (e.g. `%d`, `%f`, `%s`).
        case standard(StandardType)
        /// INDI-specific sexagesimal format (e.g. `%010.6m`).
        case sexagesimal
    }

    public enum StandardType: Character, Sendable {
        case decimalInt = "d"
        case float      = "f"
        case string     = "s"
        case hexLower   = "x"
        case hexUpper   = "X"
        // Extend with more standard printf types if needed.
    }

    /// The original format string, e.g. `"%.2f"` or `"%010.6m"`.
    public let raw: String

    /// Parsed flags in the order they appeared.
    public let flags: [Flag]

    /// Field width, if specified.
    public let width: Int?

    /// Precision, if specified after a `.`.
    public let precision: Int?

    /// Whether this is a standard printf-style type or INDI sexagesimal.
    public let kind: Kind

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public init?(raw: String) {
        self.raw = raw

        // Must start with '%' and contain at least a type character.
        guard raw.first == "%", raw.count > 1 else {
            return nil
        }

        var idx = raw.index(after: raw.startIndex)
        let end = raw.endIndex

        // Parse flags
        var parsedFlags: [Flag] = []
        flagLoop: while idx < end {
            let ch = raw[idx]
            if let flag = Flag.allCases.first(where: { $0.rawValue == ch }) {
                parsedFlags.append(flag)
                idx = raw.index(after: idx)
            } else {
                break flagLoop
            }
        }

        // Parse width
        var parsedWidth: Int?
        var widthBuffer = ""
        while idx < end, raw[idx].isNumber {
            widthBuffer.append(raw[idx])
            idx = raw.index(after: idx)
        }
        if !widthBuffer.isEmpty {
            parsedWidth = Int(widthBuffer)
        }

        // Parse precision
        var parsedPrecision: Int?
        if idx < end, raw[idx] == "." {
            idx = raw.index(after: idx)
            var precisionBuffer = ""
            while idx < end, raw[idx].isNumber {
                precisionBuffer.append(raw[idx])
                idx = raw.index(after: idx)
            }
            if !precisionBuffer.isEmpty {
                parsedPrecision = Int(precisionBuffer)
            }
        }

        // Type character must be the final character.
        guard idx == raw.index(before: end) else {
            return nil
        }
        let typeChar = raw[idx]

        if typeChar == "m" {
            self.kind = .sexagesimal
        } else if let std = StandardType(rawValue: typeChar) {
            self.kind = .standard(std)
        } else {
            // Unknown type character.
            return nil
        }

        self.flags = parsedFlags
        self.width = parsedWidth
        self.precision = parsedPrecision
    }

    /// Convenience: true if this is a sexagesimal format (e.g. `"%010.6m"`).
    public var isSexagesimal: Bool {
        if case .sexagesimal = kind { return true }
        return false
    }
}

// MARK: - Formatting

public extension INDIFormat {
    /// Style for displaying sexagesimal values.
    enum SexagesimalStyle: Sendable {
        /// Hours, minutes, seconds format for Right Ascension.
        /// Example: `12ʰ32ᵐ53ˢ4984`
        case hms

        /// Degrees, arcminutes, arcseconds format for Declination.
        /// Example: `+45°14'03"0000`
        case dms
    }

    /// Format a numeric value according to this format specification.
    ///
    /// - Parameters:
    ///   - value: The numeric value to format
    ///   - style: For sexagesimal formats, whether to use HMS or DMS notation
    /// - Returns: The formatted string
    func format(_ value: Double, style: SexagesimalStyle = .dms) -> String {
        switch kind {
        case .sexagesimal:
            return formatSexagesimal(value, style: style)
        case .standard:
            return formatStandard(value)
        }
    }

    /// Format a value using standard printf-style formatting.
    ///
    /// - Parameter value: The numeric value to format
    /// - Returns: The formatted string
    func formatStandard(_ value: Double) -> String {
        // Build format string from parsed components
        var formatString = "%"

        // Add flags
        for flag in flags {
            formatString.append(flag.rawValue)
        }

        // Add width if specified
        if let width = width {
            formatString.append("\(width)")
        }

        // Add precision if specified
        if let precision = precision {
            formatString.append(".\(precision)")
        }

        // Add type specifier
        switch kind {
        case .standard(let type):
            formatString.append(type.rawValue)
        case .sexagesimal:
            // Fallback to float for sexagesimal (shouldn't happen)
            formatString.append("f")
        }

        // Handle integer types specially
        if case .standard(let type) = kind, type == .decimalInt {
            return String(format: formatString, Int(value))
        }

        return String(format: formatString, value)
    }
    
    // swiftlint:disable:next orphaned_doc_comment
    /// Format a value for sexagesimal display.
    ///
    /// - Parameters:
    ///   - value: The value in decimal (hours for HMS, degrees for DMS)
    ///   - style: HMS or DMS style
    /// - Returns: The formatted sexagesimal string
    // swiftlint:disable:next function_body_length
    func formatSexagesimal(_ value: Double, style: SexagesimalStyle) -> String {
        let isNegative = value < 0
        let absValue = abs(value)

        // Split into primary units (hours/degrees), minutes, seconds
        let primaryUnits = Int(absValue)
        let remainingMinutes = (absValue - Double(primaryUnits)) * 60.0
        let minutes = Int(remainingMinutes)
        let remainingSeconds = (remainingMinutes - Double(minutes)) * 60.0
        let seconds = Int(remainingSeconds)

        // Calculate fractional seconds based on precision
        let fractionalPart = remainingSeconds - Double(seconds)
        let fractionalDigits: String
        if let precision = precision, precision > 0 {
            let multiplier = pow(10.0, Double(precision))
            let fractionalValue = Int((fractionalPart * multiplier).rounded())
            fractionalDigits = String(format: "%0\(precision)d", fractionalValue)
        } else {
            fractionalDigits = ""
        }

        // Determine padding for primary unit
        let primaryWidth = determinePrimaryWidth(style: style)
        let primaryStr: String
        if flags.contains(.zeroPad) {
            primaryStr = String(format: "%0\(primaryWidth)d", primaryUnits)
        } else {
            primaryStr = String(format: "%\(primaryWidth)d", primaryUnits)
        }

        // Build output string
        var result = ""

        // Handle sign
        switch style {
        case .hms:
            // HMS (Right Ascension) is always positive (0-24h), no sign
            if isNegative {
                result.append("-")
            }
        case .dms:
            // DMS always shows sign
            result.append(isNegative ? "-" : "+")
        }

        // Format based on style
        switch style {
        case .hms:
            result.append(primaryStr)
            result.append("ʰ")  // U+02B0 superscript h
            result.append(String(format: "%02d", minutes))
            result.append("ᵐ")  // U+1D50 superscript m
            result.append(String(format: "%02d", seconds))
            result.append("ˢ")  // U+02E2 superscript s
            result.append(fractionalDigits)

        case .dms:
            result.append(primaryStr)
            result.append("°")  // degree symbol
            result.append(String(format: "%02d", minutes))
            result.append("'")  // arcminute
            result.append(String(format: "%02d", seconds))
            result.append("\"") // arcsecond
            result.append(fractionalDigits)
        }

        return result
    }

    /// Determine the width for the primary unit (hours or degrees).
    private func determinePrimaryWidth(style: SexagesimalStyle) -> Int {
        // If width is specified, calculate primary unit width
        // Width typically includes the entire formatted string
        // For HMS: HHhMMmSSsFFFFF (precision digits after s)
        // For DMS: +DD°MM'SS"FFFFF
        if let totalWidth = width {
            // Estimate fixed parts: separators and minutes/seconds (each 2 digits)
            // HMS: h(1) + MM(2) + m(1) + SS(2) + s(1) + fractional = 7 + precision
            // DMS: sign(1) + °(1) + MM(2) + '(1) + SS(2) + "(1) + fractional = 8 + precision (for DMS)
            let fixedParts: Int
            switch style {
            case .hms:
                fixedParts = 7 + (precision ?? 0)
            case .dms:
                fixedParts = 9 + (precision ?? 0) // includes sign
            }
            return max(2, totalWidth - fixedParts)
        }

        // Default widths
        switch style {
        case .hms:
            return 2  // Hours: 00-23
        case .dms:
            return 2  // Degrees: typically -90 to +90 or 0-360
        }
    }
}

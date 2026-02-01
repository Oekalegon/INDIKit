import INDIProtocol
import INDIState
import SwiftUI

/// A SwiftUI view that displays a NumberValue with proper formatting.
///
/// This view automatically formats the number according to its format specification:
/// - Standard formats (e.g., `%.2f`, `%d`) display with appropriate decimal places
/// - Sexagesimal formats (e.g., `%010.6m`) display in HMS or DMS notation
///
/// For sexagesimal values, the style (HMS vs DMS) is automatically inferred from
/// the value name, or can be explicitly specified.
///
/// ## Example Usage
/// ```swift
/// // Display a Right Ascension value (will use HMS format)
/// FormattedNumberView(numberValue: raValue)
///
/// // Display a Declination value (will use DMS format)
/// FormattedNumberView(numberValue: decValue)
///
/// // Explicitly specify the sexagesimal style
/// FormattedNumberView(numberValue: value, sexagesimalStyle: .hms)
/// ```
public struct FormattedNumberView: View {
    /// The number value to display.
    public let numberValue: NumberValue

    /// The sexagesimal style to use if not inferred from the value name.
    public let sexagesimalStyle: INDIFormat.SexagesimalStyle

    /// Creates a new formatted number view.
    ///
    /// - Parameters:
    ///   - numberValue: The number value to display
    ///   - sexagesimalStyle: The default sexagesimal style to use if not inferred
    ///                       from the value name. Defaults to `.dms`.
    public init(
        numberValue: NumberValue,
        sexagesimalStyle: INDIFormat.SexagesimalStyle = .dms
    ) {
        self.numberValue = numberValue
        self.sexagesimalStyle = sexagesimalStyle
    }

    public var body: some View {
        Text(formattedString)
            .monospacedDigit()
    }

    /// The formatted string representation of the number value.
    private var formattedString: String {
        guard let format = numberValue.parsedFormat else {
            // No format specified, use default formatting
            return String(format: "%.2f", numberValue.numberValue)
        }

        return format.format(numberValue.numberValue, style: inferredStyle)
    }

    /// Infer the sexagesimal style from the value name, or use the provided default.
    private var inferredStyle: INDIFormat.SexagesimalStyle {
        switch numberValue.name {
        // HMS (hours) - Right Ascension related values
        case .rightAscension,
             .parkRightAscension,
             .trackRateRightAscension,
             .localSideralTime:
            return .hms

        // DMS (degrees) - Declination, position, and angle values
        case .declination,
             .parkDeclination,
             .trackRateDeclination,
             .latitude,
             .longitude,
             .azimuth,
             .altitude:
            return .dms

        default:
            return sexagesimalStyle
        }
    }
}

// MARK: - Convenience Initializers

public extension FormattedNumberView {
    /// Creates a formatted number view from a raw double value and format string.
    ///
    /// - Parameters:
    ///   - value: The numeric value to display
    ///   - format: The format string (e.g., "%.2f", "%010.6m")
    ///   - style: The sexagesimal style to use for sexagesimal formats
    init(
        value: Double,
        format: String,
        style: INDIFormat.SexagesimalStyle = .dms
    ) {
        // Create a temporary NumberValue with the provided format
        let numberValue = NumberValue(
            name: .other("VALUE"),
            label: nil,
            format: format,
            min: nil,
            max: nil,
            step: nil,
            unit: nil,
            numberValue: value
        )
        self.init(numberValue: numberValue, sexagesimalStyle: style)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Standard Formats") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Standard Formats").font(.headline)

        Group {
            HStack {
                Text("%.2f:")
                FormattedNumberView(value: 12.3456, format: "%.2f")
            }
            HStack {
                Text("%08.2f:")
                FormattedNumberView(value: 12.34, format: "%08.2f")
            }
            HStack {
                Text("%d:")
                FormattedNumberView(value: 42, format: "%d")
            }
            HStack {
                Text("%+.1f:")
                FormattedNumberView(value: 12.34, format: "%+.1f")
            }
        }
    }
    .padding()
}

#Preview("Sexagesimal HMS") {
    VStack(alignment: .leading, spacing: 16) {
        Text("HMS Format (Right Ascension)").font(.headline)

        Group {
            HStack {
                Text("12.548194h:")
                FormattedNumberView(value: 12.548194, format: "%.4m", style: .hms)
            }
            HStack {
                Text("0.0h:")
                FormattedNumberView(value: 0.0, format: "%.4m", style: .hms)
            }
            HStack {
                Text("23.999h:")
                FormattedNumberView(value: 23.999, format: "%.4m", style: .hms)
            }
        }
    }
    .padding()
}

#Preview("Sexagesimal DMS") {
    VStack(alignment: .leading, spacing: 16) {
        Text("DMS Format (Declination)").font(.headline)

        Group {
            HStack {
                Text("+45.233611°:")
                FormattedNumberView(value: 45.233611, format: "%.4m", style: .dms)
            }
            HStack {
                Text("-45.233611°:")
                FormattedNumberView(value: -45.233611, format: "%.4m", style: .dms)
            }
            HStack {
                Text("0.0°:")
                FormattedNumberView(value: 0.0, format: "%.4m", style: .dms)
            }
            HStack {
                Text("+90.0°:")
                FormattedNumberView(value: 90.0, format: "%.4m", style: .dms)
            }
        }
    }
    .padding()
}
#endif

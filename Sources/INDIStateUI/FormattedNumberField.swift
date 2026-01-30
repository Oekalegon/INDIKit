import SwiftUI
import INDIProtocol
import INDIState

/// A SwiftUI view that allows editing a NumberValue with proper formatting.
///
/// This view provides segmented editing for sexagesimal values (HMS/DMS),
/// with each component (hours/degrees, minutes, seconds, fractional) editable separately.
///
/// For standard formats (e.g., `%.2f`, `%d`), a regular TextField is used.
///
/// ## Behavior
/// - Segmented Editing: Click on a segment to select it
/// - Replacement Mode: Typing replaces digits from left to right
/// - Auto-advance: After typing the last digit of a segment, focus moves to next segment
/// - Separators (ʰ, ᵐ, ˢ, °, ', ") are NOT editable
///
/// ## Example Usage
/// ```swift
/// @State var value: Double = 12.5
///
/// // Edit a Right Ascension value (will use HMS format)
/// FormattedNumberField(
///     value: $value,
///     format: "%010.4m",
///     style: .hms
/// )
/// ```
public struct FormattedNumberField: View {
    /// Binding to the numeric value being edited.
    @Binding public var value: Double

    /// The format specification for the value.
    public let format: INDIFormat?

    /// The sexagesimal style to use (HMS or DMS).
    public let sexagesimalStyle: INDIFormat.SexagesimalStyle

    /// Optional callback when editing ends.
    public var onEditingEnded: (() -> Void)?

    /// Creates a new formatted number field.
    ///
    /// - Parameters:
    ///   - value: Binding to the numeric value
    ///   - format: The format specification
    ///   - style: The sexagesimal style (HMS or DMS), defaults to `.dms`
    ///   - onEditingEnded: Optional callback when editing ends
    public init(
        value: Binding<Double>,
        format: INDIFormat?,
        style: INDIFormat.SexagesimalStyle = .dms,
        onEditingEnded: (() -> Void)? = nil
    ) {
        self._value = value
        self.format = format
        self.sexagesimalStyle = style
        self.onEditingEnded = onEditingEnded
    }

    /// Creates a new formatted number field from a format string.
    ///
    /// - Parameters:
    ///   - value: Binding to the numeric value
    ///   - formatString: The format string (e.g., "%.4m", "%.2f")
    ///   - style: The sexagesimal style (HMS or DMS), defaults to `.dms`
    ///   - onEditingEnded: Optional callback when editing ends
    public init(
        value: Binding<Double>,
        formatString: String,
        style: INDIFormat.SexagesimalStyle = .dms,
        onEditingEnded: (() -> Void)? = nil
    ) {
        self._value = value
        self.format = INDIFormat(raw: formatString)
        self.sexagesimalStyle = style
        self.onEditingEnded = onEditingEnded
    }

    public var body: some View {
        if let format = format, format.isSexagesimal {
            SexagesimalField(
                value: $value,
                format: format,
                style: sexagesimalStyle,
                onEditingEnded: onEditingEnded
            )
        } else {
            StandardField(
                value: $value,
                format: format,
                onEditingEnded: onEditingEnded
            )
        }
    }
}

// MARK: - Standard Field

/// A standard text field for non-sexagesimal number formats.
///
/// Enforces formatting constraints while editing:
/// - Limits decimal places to the format's precision
/// - Disallows decimal point for integer formats (%d)
/// - Applies proper formatting (zero-padding, etc.) when editing ends
private struct StandardField: View {
    @Binding var value: Double
    let format: INDIFormat?
    var onEditingEnded: (() -> Void)?

    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool

    /// The maximum number of decimal places allowed.
    private var maxDecimalPlaces: Int? {
        guard let format = format else { return nil }

        switch format.kind {
        case .standard(let type):
            switch type {
            case .decimalInt:
                return 0  // No decimal places for integers
            case .float:
                return format.precision  // Use precision if specified
            default:
                return nil
            }
        case .sexagesimal:
            return nil  // Shouldn't happen, but allow any
        }
    }

    /// Whether this is an integer format.
    private var isIntegerFormat: Bool {
        guard let format = format else { return false }
        if case .standard(let type) = format.kind, type == .decimalInt {
            return true
        }
        return false
    }

    var body: some View {
        TextField("", text: $textValue)
            .textFieldStyle(.plain)
            .monospacedDigit()
            .focused($isFocused)
            .onAppear {
                textValue = formatValue()
            }
            .onChange(of: value) { _, newValue in
                if !isFocused {
                    textValue = formatValue()
                }
            }
            .onChange(of: textValue) { oldValue, newValue in
                // Only validate while focused (user is typing)
                guard isFocused else { return }

                let validated = validateInput(newValue, previous: oldValue)
                if validated != newValue {
                    textValue = validated
                }
            }
            .onChange(of: isFocused) { _, focused in
                if !focused {
                    // Parse and commit the value when focus is lost
                    commitValue()
                    // Apply proper formatting
                    textValue = formatValue()
                    onEditingEnded?()
                }
            }
            .onSubmit {
                commitValue()
                // Apply proper formatting
                textValue = formatValue()
                onEditingEnded?()
            }
    }

    /// Validate input and enforce digit limits.
    private func validateInput(_ input: String, previous: String) -> String {
        var result = input

        // For integer format, reject any decimal point
        if isIntegerFormat && result.contains(".") {
            return previous
        }

        // Allow empty or just minus sign during editing
        // Allow decimal point alone only for non-integer formats
        if result.isEmpty || result == "-" {
            return result
        }
        if !isIntegerFormat && (result == "." || result == "-.") {
            return result
        }

        // Check if this is a valid number pattern (allowing partial input)
        let numberPattern = #"^-?\d*\.?\d*$"#
        guard result.range(of: numberPattern, options: .regularExpression) != nil else {
            return previous
        }

        // Enforce decimal place limit
        if let maxDecimals = maxDecimalPlaces, maxDecimals > 0 {
            if let dotIndex = result.firstIndex(of: ".") {
                let afterDot = result[result.index(after: dotIndex)...]
                if afterDot.count > maxDecimals {
                    // Truncate to max decimal places
                    let endIndex = result.index(dotIndex, offsetBy: maxDecimals + 1)
                    result = String(result[..<endIndex])
                }
            }
        }

        return result
    }

    /// Parse and commit the current text value.
    private func commitValue() {
        if let parsedValue = Double(textValue) {
            value = parsedValue
        }
        // If parsing fails, keep the old value (formatValue will restore display)
    }

    /// Format the current value according to the format specification.
    private func formatValue() -> String {
        if let format = format {
            return format.formatStandard(value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

// MARK: - Sexagesimal Field

/// The segments of a sexagesimal value.
enum SexagesimalSegment: Int, CaseIterable, Hashable {
    case sign = 0
    case primaryUnit = 1
    case minutes = 2
    case seconds = 3
    case fractional = 4

    var next: SexagesimalSegment? {
        SexagesimalSegment(rawValue: rawValue + 1)
    }

    var previous: SexagesimalSegment? {
        SexagesimalSegment(rawValue: rawValue - 1)
    }
}

/// A segmented text field for sexagesimal (HMS/DMS) number formats.
private struct SexagesimalField: View {
    @Binding var value: Double
    let format: INDIFormat
    let style: INDIFormat.SexagesimalStyle
    var onEditingEnded: (() -> Void)?

    @State private var state: SexagesimalFieldState
    @FocusState private var focusedSegment: SexagesimalSegment?

    init(
        value: Binding<Double>,
        format: INDIFormat,
        style: INDIFormat.SexagesimalStyle,
        onEditingEnded: (() -> Void)?
    ) {
        self._value = value
        self.format = format
        self.style = style
        self.onEditingEnded = onEditingEnded
        self._state = State(initialValue: SexagesimalFieldState(
            value: value.wrappedValue,
            precision: format.precision ?? 0,
            style: style
        ))
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sign segment (DMS only)
            if style == .dms {
                signSegment
            }

            // Primary unit segment
            primaryUnitSegment

            // Primary separator
            Text(style == .hms ? "ʰ" : "°")
                .foregroundStyle(.secondary)

            // Minutes segment
            minutesSegment

            // Minutes separator
            Text(style == .hms ? "ᵐ" : "'")
                .foregroundStyle(.secondary)

            // Seconds segment
            secondsSegment

            // Seconds separator
            Text(style == .hms ? "ˢ" : "\"")
                .foregroundStyle(.secondary)

            // Fractional segment (if precision > 0)
            if format.precision ?? 0 > 0 {
                fractionalSegment
            }
        }
        .monospacedDigit()
        .onAppear {
            state.updateFromValue(value, precision: format.precision ?? 0, style: style)
        }
        .onChange(of: value) { _, newValue in
            if focusedSegment == nil {
                state.updateFromValue(newValue, precision: format.precision ?? 0, style: style)
            }
        }
        .onChange(of: focusedSegment) { oldSegment, newSegment in
            if newSegment == nil && oldSegment != nil {
                // Focus left the field entirely, commit the value
                value = state.doubleValue
                onEditingEnded?()
            }
        }
    }

    // MARK: - Sign Segment

    @ViewBuilder
    private var signSegment: some View {
        Text(state.isNegative ? "-" : "+")
            .foregroundStyle(focusedSegment == .sign ? Color.accentColor : .primary)
            .padding(.horizontal, 2)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(focusedSegment == .sign ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .onTapGesture {
                focusedSegment = .sign
                state.isNegative.toggle()
            }
            .focusable()
            .focused($focusedSegment, equals: .sign)
            .onKeyPress { press in
                handleSignKeyPress(press)
            }
    }

    private func handleSignKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .init("+"), .init("="):
            state.isNegative = false
            return .handled
        case .init("-"), .init("_"):
            state.isNegative = true
            return .handled
        case .space:
            state.isNegative.toggle()
            return .handled
        case .tab:
            if press.modifiers.contains(.shift) {
                // Would go before sign, nothing there
                return .ignored
            } else {
                focusedSegment = .primaryUnit
                return .handled
            }
        case .rightArrow:
            focusedSegment = .primaryUnit
            return .handled
        case .return:
            value = state.doubleValue
            focusedSegment = nil
            return .handled
        default:
            return .ignored
        }
    }

    // MARK: - Primary Unit Segment

    @ViewBuilder
    private var primaryUnitSegment: some View {
        SegmentTextField(
            text: $state.primaryUnit,
            maxDigits: 2,
            minValue: 0,
            maxValue: style == .hms ? 23 : 90,
            focused: focusedSegment == .primaryUnit,
            onTap: { focusedSegment = .primaryUnit },
            onAdvance: { focusedSegment = .minutes },
            onRetreat: {
                if style == .dms {
                    focusedSegment = .sign
                }
            },
            onCommit: {
                value = state.doubleValue
                focusedSegment = nil
            }
        )
        .focused($focusedSegment, equals: .primaryUnit)
    }

    // MARK: - Minutes Segment

    @ViewBuilder
    private var minutesSegment: some View {
        SegmentTextField(
            text: $state.minutes,
            maxDigits: 2,
            minValue: 0,
            maxValue: 59,
            focused: focusedSegment == .minutes,
            onTap: { focusedSegment = .minutes },
            onAdvance: { focusedSegment = .seconds },
            onRetreat: { focusedSegment = .primaryUnit },
            onCommit: {
                value = state.doubleValue
                focusedSegment = nil
            }
        )
        .focused($focusedSegment, equals: .minutes)
    }

    // MARK: - Seconds Segment

    @ViewBuilder
    private var secondsSegment: some View {
        SegmentTextField(
            text: $state.seconds,
            maxDigits: 2,
            minValue: 0,
            maxValue: 59,
            focused: focusedSegment == .seconds,
            onTap: { focusedSegment = .seconds },
            onAdvance: {
                if format.precision ?? 0 > 0 {
                    focusedSegment = .fractional
                } else {
                    value = state.doubleValue
                    focusedSegment = nil
                }
            },
            onRetreat: { focusedSegment = .minutes },
            onCommit: {
                value = state.doubleValue
                focusedSegment = nil
            }
        )
        .focused($focusedSegment, equals: .seconds)
    }

    // MARK: - Fractional Segment

    @ViewBuilder
    private var fractionalSegment: some View {
        SegmentTextField(
            text: $state.fractional,
            maxDigits: format.precision ?? 4,
            minValue: nil,
            maxValue: nil,
            focused: focusedSegment == .fractional,
            onTap: { focusedSegment = .fractional },
            onAdvance: {
                value = state.doubleValue
                focusedSegment = nil
            },
            onRetreat: { focusedSegment = .seconds },
            onCommit: {
                value = state.doubleValue
                focusedSegment = nil
            }
        )
        .focused($focusedSegment, equals: .fractional)
    }
}

// MARK: - Segment TextField

/// A single segment of a sexagesimal input field.
private struct SegmentTextField: View {
    @Binding var text: String
    let maxDigits: Int
    let minValue: Int?
    let maxValue: Int?
    let focused: Bool
    let onTap: () -> Void
    let onAdvance: () -> Void
    let onRetreat: () -> Void
    let onCommit: () -> Void

    @State private var cursorPosition: Int = 0

    var body: some View {
        Text(paddedText)
            .foregroundStyle(focused ? Color.accentColor : .primary)
            .padding(.horizontal, 2)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(focused ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                cursorPosition = 0
                onTap()
            }
            .focusable()
            .onKeyPress { press in
                handleKeyPress(press)
            }
    }

    /// The text padded to the expected width.
    private var paddedText: String {
        let current = text.filter { $0.isNumber }
        if current.count >= maxDigits {
            return String(current.prefix(maxDigits))
        }
        return String(repeating: "0", count: maxDigits - current.count) + current
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Handle digit input
        if let char = press.characters.first, char.isNumber {
            insertDigit(char)
            return .handled
        }

        // Handle navigation
        switch press.key {
        case .tab:
            if press.modifiers.contains(.shift) {
                onRetreat()
            } else {
                onAdvance()
            }
            return .handled
        case .leftArrow:
            if cursorPosition > 0 {
                cursorPosition -= 1
            } else {
                onRetreat()
            }
            return .handled
        case .rightArrow:
            if cursorPosition < maxDigits - 1 {
                cursorPosition += 1
            } else {
                onAdvance()
            }
            return .handled
        case .delete: // Backspace
            handleBackspace()
            return .handled
        case .return:
            onCommit()
            return .handled
        default:
            return .ignored
        }
    }

    private func insertDigit(_ digit: Character) {
        var digits = Array(paddedText)

        // Replace digit at cursor position
        if cursorPosition < digits.count {
            digits[cursorPosition] = digit
        }

        // Update the text
        let newText = String(digits)

        // Validate range if applicable
        if let intValue = Int(newText) {
            if let maxValue = maxValue, intValue > maxValue {
                // Don't allow values above max
                return
            }
        }

        text = newText

        // Advance cursor or move to next segment
        if cursorPosition < maxDigits - 1 {
            cursorPosition += 1
        } else {
            onAdvance()
        }
    }

    private func handleBackspace() {
        var digits = Array(paddedText)

        if cursorPosition > 0 {
            // Move cursor back and replace with 0
            cursorPosition -= 1
            digits[cursorPosition] = "0"
            text = String(digits)
        } else {
            // At start of segment, go to previous segment
            onRetreat()
        }
    }
}

// MARK: - Sexagesimal Field State

/// State model for the sexagesimal field.
@Observable
final class SexagesimalFieldState {
    var primaryUnit: String = "00"
    var minutes: String = "00"
    var seconds: String = "00"
    var fractional: String = ""
    var isNegative: Bool = false

    init(value: Double, precision: Int, style: INDIFormat.SexagesimalStyle) {
        updateFromValue(value, precision: precision, style: style)
    }

    /// Update all segments from a double value.
    func updateFromValue(_ value: Double, precision: Int, style: INDIFormat.SexagesimalStyle) {
        isNegative = value < 0
        let absValue = abs(value)

        // Split into primary units (hours/degrees), minutes, seconds
        let primaryUnits = Int(absValue)
        let remainingMinutes = (absValue - Double(primaryUnits)) * 60.0
        let mins = Int(remainingMinutes)
        let remainingSeconds = (remainingMinutes - Double(mins)) * 60.0
        let secs = Int(remainingSeconds)

        // Calculate fractional seconds
        let fractionalPart = remainingSeconds - Double(secs)
        if precision > 0 {
            let multiplier = pow(10.0, Double(precision))
            let fractionalValue = Int((fractionalPart * multiplier).rounded())
            fractional = String(format: "%0\(precision)d", fractionalValue)
        } else {
            fractional = ""
        }

        primaryUnit = String(format: "%02d", primaryUnits)
        minutes = String(format: "%02d", mins)
        seconds = String(format: "%02d", secs)
    }

    /// Compute the double value from segments.
    var doubleValue: Double {
        let primary = Double(Int(primaryUnit) ?? 0)
        let mins = Double(Int(minutes) ?? 0)
        let secs = Double(Int(seconds) ?? 0)

        // Calculate fractional seconds
        let fractionalValue: Double
        if !fractional.isEmpty, let fractInt = Int(fractional) {
            let precision = fractional.count
            fractionalValue = Double(fractInt) / pow(10.0, Double(precision))
        } else {
            fractionalValue = 0.0
        }

        let totalSeconds = secs + fractionalValue
        let value = primary + mins / 60.0 + totalSeconds / 3600.0

        return isNegative ? -value : value
    }
}

// MARK: - NumberValue Extension

public extension FormattedNumberField {
    /// Creates a formatted number field for a NumberValue.
    ///
    /// - Parameters:
    ///   - numberValue: The number value to edit
    ///   - style: The default sexagesimal style to use if not inferred
    ///   - onEditingEnded: Optional callback when editing ends
    init(
        numberValue: Binding<NumberValue>,
        style: INDIFormat.SexagesimalStyle = .dms,
        onEditingEnded: (() -> Void)? = nil
    ) {
        let valueBinding = Binding<Double>(
            get: { numberValue.wrappedValue.numberValue },
            set: { numberValue.wrappedValue.numberValue = $0 }
        )

        let format = numberValue.wrappedValue.parsedFormat
        let inferredStyle = Self.inferStyle(from: numberValue.wrappedValue.name, default: style)

        self.init(
            value: valueBinding,
            format: format,
            style: inferredStyle,
            onEditingEnded: onEditingEnded
        )
    }

    /// Infer the sexagesimal style from the value name.
    private static func inferStyle(
        from name: INDIPropertyValueName,
        default defaultStyle: INDIFormat.SexagesimalStyle
    ) -> INDIFormat.SexagesimalStyle {
        switch name {
        case .rightAscension,
             .parkRightAscension,
             .trackRateRightAscension,
             .localSideralTime:
            return .hms
        case .declination,
             .parkDeclination,
             .trackRateDeclination,
             .latitude,
             .longitude,
             .azimuth,
             .altitude:
            return .dms
        default:
            return defaultStyle
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Standard Field") {
    struct PreviewWrapper: View {
        @State private var value: Double = 12.34

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Standard Formats").font(.headline)

                HStack {
                    Text("%.2f:")
                    FormattedNumberField(value: $value, formatString: "%.2f")
                }

                Text("Value: \(value)")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Sexagesimal HMS Field") {
    struct PreviewWrapper: View {
        @State private var value: Double = 12.548194

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("HMS Format (Right Ascension)").font(.headline)

                HStack {
                    Text("RA:")
                    FormattedNumberField(
                        value: $value,
                        formatString: "%.4m",
                        style: .hms
                    )
                }

                Text("Value: \(value) hours")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Sexagesimal DMS Field") {
    struct PreviewWrapper: View {
        @State private var value: Double = -45.233611

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("DMS Format (Declination)").font(.headline)

                HStack {
                    Text("Dec:")
                    FormattedNumberField(
                        value: $value,
                        formatString: "%.4m",
                        style: .dms
                    )
                }

                Text("Value: \(value) degrees")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Comparison View") {
    struct PreviewWrapper: View {
        @State private var ra: Double = 12.548194
        @State private var dec: Double = -45.233611

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Editable vs Read-only Comparison").font(.headline)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Editable").font(.caption)
                        FormattedNumberField(value: $ra, formatString: "%.4m", style: .hms)
                    }
                    VStack(alignment: .leading) {
                        Text("Read-only").font(.caption)
                        FormattedNumberView(value: ra, format: "%.4m", style: .hms)
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("Editable").font(.caption)
                        FormattedNumberField(value: $dec, formatString: "%.4m", style: .dms)
                    }
                    VStack(alignment: .leading) {
                        Text("Read-only").font(.caption)
                        FormattedNumberView(value: dec, format: "%.4m", style: .dms)
                    }
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
#endif

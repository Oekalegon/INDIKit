import Testing
import Foundation
@testable import INDIProtocol

// MARK: - Standard Field Input Validation Tests

@Suite("Standard Field Input Validation Tests")
struct StandardFieldInputValidationTests {

    // MARK: - Integer Format Tests

    @Test("Integer format rejects decimal point")
    func testIntegerFormatRejectsDecimal() {
        let validator = TestStandardFieldValidator(formatString: "%d")

        // Typing a decimal point should revert to previous value
        #expect(validator.validate("123.", previous: "123") == "123")
        #expect(validator.validate("123.45", previous: "123") == "123")
        #expect(validator.validate(".", previous: "") == "")
    }

    @Test("Integer format allows whole numbers")
    func testIntegerFormatAllowsWholeNumbers() {
        let validator = TestStandardFieldValidator(formatString: "%d")

        #expect(validator.validate("123", previous: "") == "123")
        #expect(validator.validate("-456", previous: "") == "-456")
        #expect(validator.validate("0", previous: "") == "0")
    }

    // MARK: - Float Format Precision Tests

    @Test("Float format with precision 2 limits decimal places")
    func testFloatPrecisionTwoLimits() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("12.345", previous: "12.34") == "12.34")
        #expect(validator.validate("12.34", previous: "") == "12.34")
        #expect(validator.validate("12.3", previous: "") == "12.3")
    }

    @Test("Float format with precision 1 limits decimal places")
    func testFloatPrecisionOneLimits() {
        let validator = TestStandardFieldValidator(formatString: "%.1f")

        #expect(validator.validate("12.34", previous: "12.3") == "12.3")
        #expect(validator.validate("12.3", previous: "") == "12.3")
    }

    @Test("Float format with precision 4 limits decimal places")
    func testFloatPrecisionFourLimits() {
        let validator = TestStandardFieldValidator(formatString: "%.4f")

        #expect(validator.validate("12.34567", previous: "12.3456") == "12.3456")
        #expect(validator.validate("12.3456", previous: "") == "12.3456")
    }

    // MARK: - Partial Input Tests

    @Test("Allows empty string during editing")
    func testAllowsEmptyString() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("", previous: "12.34") == "")
    }

    @Test("Allows minus sign alone during editing")
    func testAllowsMinusSignAlone() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("-", previous: "") == "-")
    }

    @Test("Allows decimal point alone during editing")
    func testAllowsDecimalPointAlone() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate(".", previous: "") == ".")
    }

    @Test("Allows minus and decimal point during editing")
    func testAllowsMinusAndDecimalPoint() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("-.", previous: "-") == "-.")
    }

    // MARK: - Invalid Input Tests

    @Test("Rejects non-numeric characters")
    func testRejectsNonNumeric() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("12.3a", previous: "12.3") == "12.3")
        #expect(validator.validate("abc", previous: "12.3") == "12.3")
        #expect(validator.validate("12e3", previous: "12") == "12")
    }

    @Test("Rejects multiple decimal points")
    func testRejectsMultipleDecimalPoints() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("12.3.4", previous: "12.3") == "12.3")
    }

    @Test("Rejects multiple minus signs")
    func testRejectsMultipleMinusSigns() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("--12", previous: "-12") == "-12")
        #expect(validator.validate("-12-", previous: "-12") == "-12")
    }

    // MARK: - No Format Tests

    @Test("No format allows any decimal places")
    func testNoFormatAllowsAnyDecimals() {
        let validator = TestStandardFieldValidator(formatString: nil)

        #expect(validator.validate("12.3456789", previous: "") == "12.3456789")
    }

    // MARK: - Negative Number Tests

    @Test("Allows negative numbers with precision")
    func testAllowsNegativeWithPrecision() {
        let validator = TestStandardFieldValidator(formatString: "%.2f")

        #expect(validator.validate("-12.34", previous: "") == "-12.34")
        #expect(validator.validate("-12.345", previous: "-12.34") == "-12.34")
    }
}

// MARK: - Test Helper for Standard Field Validation

/// A testable version of the StandardField validation logic.
struct TestStandardFieldValidator {
    let format: INDIFormat?

    init(formatString: String?) {
        if let formatString = formatString {
            self.format = INDIFormat(raw: formatString)
        } else {
            self.format = nil
        }
    }

    var maxDecimalPlaces: Int? {
        guard let format = format else { return nil }

        switch format.kind {
        case .standard(let type):
            switch type {
            case .decimalInt:
                return 0
            case .float:
                return format.precision
            default:
                return nil
            }
        case .sexagesimal:
            return nil
        }
    }

    var isIntegerFormat: Bool {
        guard let format = format else { return false }
        if case .standard(let type) = format.kind, type == .decimalInt {
            return true
        }
        return false
    }

    func validate(_ input: String, previous: String) -> String {
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
}

// MARK: - Sexagesimal Field State Tests

@Suite("Formatted Number Field State Tests")
struct FormattedNumberFieldStateTests {

    // MARK: - Value to Segments Conversion

    @Test("Convert positive HMS value to segments")
    func testPositiveHMSToSegments() {
        // 12h 32m 53.4984s = 12 + 32/60 + 53.4984/3600 = 12.548194 hours
        let value = 12.548194
        let state = TestSexagesimalFieldState(value: value, precision: 4, style: .hms)

        #expect(state.isNegative == false)
        #expect(state.primaryUnit == "12")
        #expect(state.minutes == "32")
        #expect(state.seconds == "53")
        // Fractional should be approximately 4984
        #expect(state.fractional.count == 4)
    }

    @Test("Convert negative DMS value to segments")
    func testNegativeDMSToSegments() {
        // -45° 14' 01.0000"
        let value = -45.233611
        let state = TestSexagesimalFieldState(value: value, precision: 4, style: .dms)

        #expect(state.isNegative == true)
        #expect(state.primaryUnit == "45")
        #expect(state.minutes == "14")
        // Seconds should be close to 01
        #expect(Int(state.seconds) ?? 0 >= 0)
        #expect(Int(state.seconds) ?? 0 <= 2)
    }

    @Test("Convert zero value to segments")
    func testZeroToSegments() {
        let state = TestSexagesimalFieldState(value: 0.0, precision: 4, style: .dms)

        #expect(state.isNegative == false)
        #expect(state.primaryUnit == "00")
        #expect(state.minutes == "00")
        #expect(state.seconds == "00")
        #expect(state.fractional == "0000")
    }

    @Test("Convert 24 hours to segments")
    func testTwentyFourHoursToSegments() {
        let state = TestSexagesimalFieldState(value: 24.0, precision: 0, style: .hms)

        #expect(state.isNegative == false)
        #expect(state.primaryUnit == "24")
        #expect(state.minutes == "00")
        #expect(state.seconds == "00")
    }

    @Test("Convert 90 degrees to segments")
    func testNinetyDegreesToSegments() {
        let state = TestSexagesimalFieldState(value: 90.0, precision: 0, style: .dms)

        #expect(state.isNegative == false)
        #expect(state.primaryUnit == "90")
        #expect(state.minutes == "00")
        #expect(state.seconds == "00")
    }

    @Test("Convert -90 degrees to segments")
    func testMinusNinetyDegreesToSegments() {
        let state = TestSexagesimalFieldState(value: -90.0, precision: 0, style: .dms)

        #expect(state.isNegative == true)
        #expect(state.primaryUnit == "90")
        #expect(state.minutes == "00")
        #expect(state.seconds == "00")
    }

    // MARK: - Segments to Value Conversion

    @Test("Convert HMS segments to double value")
    func testHMSSegmentsToDouble() {
        let state = TestSexagesimalFieldState(value: 0, precision: 4, style: .hms)
        state.primaryUnit = "12"
        state.minutes = "30"
        state.seconds = "00"
        state.fractional = "0000"
        state.isNegative = false

        // 12h 30m 0s = 12.5 hours
        let result = state.doubleValue
        #expect(abs(result - 12.5) < 0.0001)
    }

    @Test("Convert DMS segments to double value")
    func testDMSSegmentsToDouble() {
        let state = TestSexagesimalFieldState(value: 0, precision: 4, style: .dms)
        state.primaryUnit = "45"
        state.minutes = "30"
        state.seconds = "00"
        state.fractional = "0000"
        state.isNegative = false

        // +45° 30' 0" = 45.5 degrees
        let result = state.doubleValue
        #expect(abs(result - 45.5) < 0.0001)
    }

    @Test("Convert negative DMS segments to double value")
    func testNegativeDMSSegmentsToDouble() {
        let state = TestSexagesimalFieldState(value: 0, precision: 4, style: .dms)
        state.primaryUnit = "45"
        state.minutes = "30"
        state.seconds = "00"
        state.fractional = "0000"
        state.isNegative = true

        // -45° 30' 0" = -45.5 degrees
        let result = state.doubleValue
        #expect(abs(result - (-45.5)) < 0.0001)
    }

    @Test("Convert segments with fractional seconds to double")
    func testSegmentsWithFractionalToDouble() {
        let state = TestSexagesimalFieldState(value: 0, precision: 4, style: .hms)
        state.primaryUnit = "12"
        state.minutes = "32"
        state.seconds = "53"
        state.fractional = "5000"
        state.isNegative = false

        // 12h 32m 53.5s = 12 + 32/60 + 53.5/3600
        let expected = 12.0 + 32.0 / 60.0 + 53.5 / 3600.0
        let result = state.doubleValue
        #expect(abs(result - expected) < 0.0001)
    }

    // MARK: - Round-trip Tests

    @Test("Round-trip positive HMS value")
    func testRoundTripPositiveHMS() {
        let original = 12.548194
        let state = TestSexagesimalFieldState(value: original, precision: 4, style: .hms)
        let result = state.doubleValue

        // Should be very close to original
        #expect(abs(result - original) < 0.0001)
    }

    @Test("Round-trip negative DMS value")
    func testRoundTripNegativeDMS() {
        let original = -45.233611
        let state = TestSexagesimalFieldState(value: original, precision: 4, style: .dms)
        let result = state.doubleValue

        // Should be very close to original
        #expect(abs(result - original) < 0.0001)
    }

    @Test("Round-trip zero value")
    func testRoundTripZero() {
        let original = 0.0
        let state = TestSexagesimalFieldState(value: original, precision: 4, style: .dms)
        let result = state.doubleValue

        #expect(result == 0.0)
    }

    @Test("Round-trip with different precisions")
    func testRoundTripDifferentPrecisions() {
        let original = 12.548194

        // Lower precision should still round-trip reasonably
        for precision in [0, 2, 4, 6] {
            let state = TestSexagesimalFieldState(value: original, precision: precision, style: .hms)
            let result = state.doubleValue

            // Precision of 0 will lose fractional seconds
            if precision == 0 {
                #expect(abs(result - 12.5481) < 0.01)
            } else {
                #expect(abs(result - original) < 0.001)
            }
        }
    }

    // MARK: - Edge Cases

    @Test("Handle very small positive value")
    func testVerySmallPositiveValue() {
        let value = 0.001 // About 3.6 arcseconds
        let state = TestSexagesimalFieldState(value: value, precision: 4, style: .dms)

        #expect(state.isNegative == false)
        #expect(state.primaryUnit == "00")
        #expect(state.minutes == "00")
        // Seconds should be about 3-4
        #expect(Int(state.seconds) ?? 0 >= 0)
    }

    @Test("Handle very small negative value")
    func testVerySmallNegativeValue() {
        let value = -0.001
        let state = TestSexagesimalFieldState(value: value, precision: 4, style: .dms)

        #expect(state.isNegative == true)
        #expect(state.primaryUnit == "00")
    }

    @Test("Handle 59 minutes 59 seconds")
    func testFiftyNineMinutesFiftyNineSeconds() {
        // 23h 59m 59.9999s
        let value = 23.0 + 59.0 / 60.0 + 59.9999 / 3600.0
        let state = TestSexagesimalFieldState(value: value, precision: 4, style: .hms)

        #expect(state.primaryUnit == "23")
        #expect(state.minutes == "59")
        #expect(state.seconds == "59")
    }

    // MARK: - Precision Tests

    @Test("Zero precision produces no fractional digits")
    func testZeroPrecisionNoFractional() {
        let state = TestSexagesimalFieldState(value: 12.5, precision: 0, style: .hms)
        #expect(state.fractional.isEmpty)
    }

    @Test("Precision 4 produces 4 fractional digits")
    func testPrecisionFourDigits() {
        let state = TestSexagesimalFieldState(value: 12.5, precision: 4, style: .hms)
        #expect(state.fractional.count == 4)
    }

    @Test("Precision 6 produces 6 fractional digits")
    func testPrecisionSixDigits() {
        let state = TestSexagesimalFieldState(value: 12.5, precision: 6, style: .hms)
        #expect(state.fractional.count == 6)
    }
}

// MARK: - Test Helper

/// A testable version of the SexagesimalFieldState that doesn't require @Observable.
/// This mirrors the logic from the actual SexagesimalFieldState class.
final class TestSexagesimalFieldState {
    var primaryUnit: String = "00"
    var minutes: String = "00"
    var seconds: String = "00"
    var fractional: String = ""
    var isNegative: Bool = false

    enum Style {
        case hms
        case dms
    }

    init(value: Double, precision: Int, style: Style) {
        updateFromValue(value, precision: precision, style: style)
    }

    func updateFromValue(_ value: Double, precision: Int, style: Style) {
        isNegative = value < 0
        let absValue = abs(value)

        let primaryUnits = Int(absValue)
        let remainingMinutes = (absValue - Double(primaryUnits)) * 60.0
        let mins = Int(remainingMinutes)
        let remainingSeconds = (remainingMinutes - Double(mins)) * 60.0
        let secs = Int(remainingSeconds)

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

    var doubleValue: Double {
        let primary = Double(Int(primaryUnit) ?? 0)
        let mins = Double(Int(minutes) ?? 0)
        let secs = Double(Int(seconds) ?? 0)

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

import Testing
import Foundation
@testable import INDIProtocol

@Suite("INDI Format Formatting Tests")
struct INDIFormatFormattingTests {

    // MARK: - Standard Format Tests

    @Test("Format integer with %d")
    func testFormatInteger() {
        let format = INDIFormat(raw: "%d")!
        #expect(format.format(42) == "42")
        #expect(format.format(0) == "0")
        #expect(format.format(-5) == "-5")
    }

    @Test("Format float with %.2f")
    func testFormatFloatTwoDecimals() {
        let format = INDIFormat(raw: "%.2f")!
        #expect(format.format(12.3456) == "12.35")
        #expect(format.format(12.0) == "12.00")
        #expect(format.format(-3.14159) == "-3.14")
    }

    @Test("Format float with %.1f")
    func testFormatFloatOneDecimal() {
        let format = INDIFormat(raw: "%.1f")!
        #expect(format.format(12.34) == "12.3")
        #expect(format.format(12.0) == "12.0")
    }

    @Test("Format float with width and precision %08.2f")
    func testFormatFloatWithWidthAndPrecision() {
        let format = INDIFormat(raw: "%08.2f")!
        #expect(format.format(12.34) == "00012.34")
        #expect(format.format(1.5) == "00001.50")
    }

    @Test("Format with always sign flag %+.1f")
    func testFormatWithAlwaysSign() {
        let format = INDIFormat(raw: "%+.1f")!
        #expect(format.format(12.3) == "+12.3")
        #expect(format.format(-12.3) == "-12.3")
    }

    // MARK: - Sexagesimal HMS Tests

    @Test("Format sexagesimal HMS basic")
    func testFormatSexagesimalHMSBasic() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(12.5, style: .hms)

        // 12.5 hours = 12h 30m 00s
        #expect(result.contains("12"))
        #expect(result.contains("ʰ"))
        #expect(result.contains("30"))
        #expect(result.contains("ᵐ"))
        #expect(result.contains("00"))
        #expect(result.contains("ˢ"))
    }

    @Test("Format sexagesimal HMS with fractional seconds")
    func testFormatSexagesimalHMSFractional() {
        let format = INDIFormat(raw: "%.4m")!
        // 12h 32m 53.4984s = 12 + 32/60 + 53.4984/3600 = 12.548194 hours
        let result = format.format(12.548194, style: .hms)

        #expect(result.contains("12"))
        #expect(result.contains("ʰ"))
        #expect(result.contains("32"))
        #expect(result.contains("ᵐ"))
        #expect(result.contains("53"))
        #expect(result.contains("ˢ"))
    }

    @Test("Format sexagesimal HMS has no sign for positive values")
    func testFormatSexagesimalHMSNoSignPositive() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(12.5, style: .hms)

        // HMS should not have a + sign for positive values
        #expect(!result.hasPrefix("+"))
    }

    @Test("Format sexagesimal HMS uses superscript characters")
    func testFormatSexagesimalHMSSuperscript() {
        let format = INDIFormat(raw: "%.0m")!
        let result = format.format(12.5, style: .hms)

        // Check for superscript Unicode characters
        #expect(result.contains("\u{02B0}")) // ʰ
        #expect(result.contains("\u{1D50}")) // ᵐ
        #expect(result.contains("\u{02E2}")) // ˢ
    }

    // MARK: - Sexagesimal DMS Tests

    @Test("Format sexagesimal DMS positive")
    func testFormatSexagesimalDMSPositive() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(45.5, style: .dms)

        // 45.5 degrees = +45° 30' 00"
        #expect(result.hasPrefix("+"))
        #expect(result.contains("45"))
        #expect(result.contains("°"))
        #expect(result.contains("30"))
        #expect(result.contains("'"))
        #expect(result.contains("00"))
        #expect(result.contains("\""))
    }

    @Test("Format sexagesimal DMS negative")
    func testFormatSexagesimalDMSNegative() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(-45.5, style: .dms)

        // -45.5 degrees = -45° 30' 00"
        #expect(result.hasPrefix("-"))
        #expect(result.contains("45"))
        #expect(result.contains("°"))
    }

    @Test("Format sexagesimal DMS zero shows positive sign")
    func testFormatSexagesimalDMSZero() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(0.0, style: .dms)

        // Zero should show + sign in DMS
        #expect(result.hasPrefix("+"))
        #expect(result.contains("0"))
        #expect(result.contains("°"))
    }

    @Test("Format sexagesimal DMS with fractional arcseconds")
    func testFormatSexagesimalDMSFractional() {
        let format = INDIFormat(raw: "%.4m")!
        // 45° 14' 01.2000" = 45 + 14/60 + 1.2/3600 = 45.233667 degrees
        let result = format.format(45.233667, style: .dms)

        #expect(result.contains("45"))
        #expect(result.contains("°"))
        #expect(result.contains("14"))
        #expect(result.contains("'"))
        #expect(result.contains("01") || result.contains("1"))
        #expect(result.contains("\""))
    }

    // MARK: - Precision Tests

    @Test("Format sexagesimal with 0 precision")
    func testFormatSexagesimalZeroPrecision() {
        let format = INDIFormat(raw: "%.0m")!
        let result = format.format(12.5, style: .hms)

        // With 0 precision, should end with s and no digits after
        #expect(result.hasSuffix("ˢ"))
    }

    @Test("Format sexagesimal with 6 precision")
    func testFormatSexagesimalSixPrecision() {
        let format = INDIFormat(raw: "%.6m")!
        let result = format.format(12.548194, style: .hms)

        // Should have 6 digits after the seconds separator
        // Find the position of ˢ and check digits after it
        if let sIndex = result.firstIndex(of: "ˢ") {
            let afterS = result[result.index(after: sIndex)...]
            #expect(afterS.count == 6)
            #expect(afterS.allSatisfy { $0.isNumber })
        }
    }

    // MARK: - Edge Cases

    @Test("Format sexagesimal at 24 hours")
    func testFormatSexagesimalAt24Hours() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(24.0, style: .hms)

        // 24 hours = 24h 00m 00s
        #expect(result.contains("24"))
        #expect(result.contains("ʰ"))
    }

    @Test("Format sexagesimal at 90 degrees")
    func testFormatSexagesimalAt90Degrees() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(90.0, style: .dms)

        // +90° 00' 00"
        #expect(result.hasPrefix("+"))
        #expect(result.contains("90"))
        #expect(result.contains("°"))
    }

    @Test("Format sexagesimal at -90 degrees")
    func testFormatSexagesimalAtMinus90Degrees() {
        let format = INDIFormat(raw: "%.4m")!
        let result = format.format(-90.0, style: .dms)

        // -90° 00' 00"
        #expect(result.hasPrefix("-"))
        #expect(result.contains("90"))
        #expect(result.contains("°"))
    }

    // MARK: - isSexagesimal Tests

    @Test("isSexagesimal returns true for sexagesimal format")
    func testIsSexagesimalTrue() {
        let format = INDIFormat(raw: "%010.6m")!
        #expect(format.isSexagesimal == true)
    }

    @Test("isSexagesimal returns false for standard format")
    func testIsSexagesimalFalse() {
        let format = INDIFormat(raw: "%.2f")!
        #expect(format.isSexagesimal == false)
    }

    // MARK: - Integration Tests

    @Test("Format method uses correct style based on kind")
    func testFormatMethodDispatchesCorrectly() {
        let standardFormat = INDIFormat(raw: "%.2f")!
        let sexagesimalFormat = INDIFormat(raw: "%.4m")!

        // Standard format should produce decimal output
        let standardResult = standardFormat.format(12.5)
        #expect(standardResult == "12.50")

        // Sexagesimal format should produce sexagesimal output
        let sexagesimalResult = sexagesimalFormat.format(12.5, style: .hms)
        #expect(sexagesimalResult.contains("ʰ"))
    }
}

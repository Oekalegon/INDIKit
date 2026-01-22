import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Property Programmatic Validation Tests")
struct INDIPropertyProgrammaticValidationTests {
    
    // MARK: - Property Validation Tests
    
    @Test("Property with unknown property name generates note")
    func testPropertyUnknownName() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            propertyType: .text
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("UNKNOWN_PROPERTY"),
            values: [value]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasNote(property.diagnostics, containing: "The property name 'UNKNOWN_PROPERTY' is unknown"))
    }
    
    @Test("Light property with permissions generates warning")
    func testLightPropertyWithPermissions() {
        let value = INDIValue(
            name: .other("OK"),
            value: .state(.ok),
            propertyType: .light
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .light,
            device: "Test Device",
            name: .other("STATUS"),
            permissions: .readWrite,
            values: [value]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Permissions are ignored for light properties"))
    }
    
    @Test("Light property with timeout generates warning")
    func testLightPropertyWithTimeout() {
        let value = INDIValue(
            name: .other("OK"),
            value: .state(.ok),
            propertyType: .light
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .light,
            device: "Test Device",
            name: .other("STATUS"),
            timeout: 60.0,
            values: [value]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Timeout is ignored for light properties"))
    }
    
    @Test("Non-switch property with rule generates warning")
    func testNonSwitchPropertyWithRule() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            propertyType: .text
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("TEST_PROP"),
            rule: .oneOfMany,
            values: [value]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Rule is ignored for non-switch properties"))
    }
    
    @Test("Non-blob property with format generates warning")
    func testNonBlobPropertyWithFormat() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .number(42.0),
            propertyType: .number
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .number,
            device: "Test Device",
            name: .other("TEST_PROP"),
            format: ".fits",
            values: [value]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Format is ignored for non-blob properties"))
    }
    
    @Test("Property with no values generates error")
    func testPropertyWithNoValues() {
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("TEST_PROP"),
            values: []
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "The property must have at least one value"))
    }
    
    @Test("Switch property with OneOfMany rule violation generates error")
    func testSwitchOneOfManyRuleViolation() {
        let value1 = INDIValue(
            name: .connect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let value2 = INDIValue(
            name: .disconnect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .toggle,
            device: "Test Device",
            name: .connection,
            rule: .oneOfMany,
            values: [value1, value2]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "OneOfMany", "requires exactly one switch to be On", "2 switch(es) are On"))
    }
    
    @Test("Switch property with AtMostOne rule violation generates error")
    func testSwitchAtMostOneRuleViolation() {
        let value1 = INDIValue(
            name: .connect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let value2 = INDIValue(
            name: .disconnect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let value3 = INDIValue(
            name: .other("OPTION3"),
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .toggle,
            device: "Test Device",
            name: .other("TEST_SWITCH"),
            rule: .atMostOne,
            values: [value1, value2, value3]
        ))
        
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "AtMostOne", "allows at most one switch to be On", "3 switch(es) are On"))
    }
    
    @Test("Valid property generates no errors")
    func testValidPropertyNoErrors() {
        let value = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Test Driver"),
            propertyType: .text
        )
        
        let property = INDIProperty.defineProperty(INDIDefineProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("DRIVER_INFO"),
            group: "General Info",
            label: "Driver Info",
            permissions: .readOnly,
            state: .idle,
            timeout: 60.0,
            values: [value]
        ))
        
        #expect(!INDIDiagnosticsTestHelpers.hasAnyError(property.diagnostics))
    }
    
    // MARK: - Value Validation Tests
    
    @Test("Number value with min greater than max generates error")
    func testNumberValueMinGreaterThanMax() {
        let value = INDIValue(
            name: .other("TEMPERATURE"),
            value: .number(25.0),
            min: 50.0,
            max: 0.0,
            propertyType: .number
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasError(value.diagnostics, containing: "Minimum value 50.0 is greater than maximum value 0.0"))
    }
    
    @Test("Format on non-number non-blob value generates warning")
    func testFormatOnNonNumberNonBlob() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            format: "%g",
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Format is ignored for non-number, non-blob property types"))
    }
    
    @Test("Min on non-number value generates warning")
    func testMinOnNonNumber() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            min: 0.0,
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Min is ignored for non-number property types"))
    }
    
    @Test("Max on non-number value generates warning")
    func testMaxOnNonNumber() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            max: 100.0,
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Max is ignored for non-number property types"))
    }
    
    @Test("Step on non-number value generates warning")
    func testStepOnNonNumber() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            step: 1.0,
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Step is ignored for non-number property types"))
    }
    
    @Test("Unit on non-number value generates warning")
    func testUnitOnNonNumber() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            unit: "mm",
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Unit is ignored for non-number property types"))
    }
    
    @Test("Size on non-blob value generates warning")
    func testSizeOnNonBlob() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            size: 1024,
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Size is ignored for non-blob property types"))
    }
    
    @Test("Compressed on non-blob value generates warning")
    func testCompressedOnNonBlob() {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            compressed: true,
            propertyType: .text
        )
        
        #expect(INDIDiagnosticsTestHelpers.hasWarning(value.diagnostics, containing: "Compressed is ignored for non-blob property types"))
    }
    
    @Test("Valid number value generates no errors")
    func testValidNumberValue() {
        let value = INDIValue(
            name: .other("TEMPERATURE"),
            value: .number(25.5),
            min: -50.0,
            max: 50.0,
            step: 0.1,
            unit: "°C",
            propertyType: .number
        )
        
        #expect(!INDIDiagnosticsTestHelpers.hasAnyError(value.diagnostics))
    }
    
    @Test("Valid blob value generates no errors")
    func testValidBlobValue() {
        let blobData = Data("test data".utf8)
        let value = INDIValue(
            name: .other("IMAGE"),
            value: .blob(blobData),
            format: ".fits",
            size: blobData.count,
            compressed: false,
            propertyType: .blob
        )
        
        #expect(!INDIDiagnosticsTestHelpers.hasAnyError(value.diagnostics))
    }
}


import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Property Validation Tests")
struct INDIPropertyValidationTests {
    
    // MARK: - Helper Functions
    
    /// Create an AsyncThrowingStream from XML string
    private func createDataStream(from xml: String) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(Data(xml.utf8))
            continuation.finish()
        }
    }
    
    /// Parse XML and collect all properties
    private func parseXML(_ xml: String) async throws -> [INDIProperty] {
        let parser = INDIXMLParser()
        let dataStream = createDataStream(from: xml)
        let propertyStream = await parser.parse(dataStream)
        
        var properties: [INDIProperty] = []
        for try await property in propertyStream {
            properties.append(property)
        }
        return properties
    }
    
    
    // MARK: - Validation Tests
    
    @Test("Property with missing device generates error")
    func testPropertyMissingDevice() async throws {
        let xml = """
        <defTextVector name="TEST_PROPERTY">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have error diagnostic for missing device
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "Device is required but not found"))
        #expect(property.device == "UNKNOWN")
    }
    
    @Test("Property with missing name generates error")
    func testPropertyMissingName() async throws {
        let xml = """
        <defTextVector device="Test Device">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have error diagnostic for missing name
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "The property name is required but not found"))
        #expect(property.name?.indiName == "UNKNOWN")
    }
    
    @Test("Property with unknown property name generates note")
    func testPropertyUnknownName() async throws {
        let xml = """
        <defTextVector device="Test Device" name="UNKNOWN_PROPERTY_NAME">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have note diagnostic for unknown property name
        #expect(INDIDiagnosticsTestHelpers.hasNote(property.diagnostics, containing: "The property name 'UNKNOWN_PROPERTY_NAME' is unknown"))
        
        if case .other(let name) = property.name {
            #expect(name == "UNKNOWN_PROPERTY_NAME")
        } else {
            Issue.record("Expected unknown property name")
        }
    }
    
    @Test("Property with unknown attribute generates warning")
    func testPropertyUnknownAttribute() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST_PROPERTY" unknownAttr="value">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have warning diagnostic for unknown attribute
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Unknown attribute 'unknownAttr'"))
    }
    
    @Test("Light property with permissions generates warning")
    func testLightPropertyWithPermissions() async throws {
        let xml = """
        <defLightVector device="Test Device" name="STATUS" perm="rw">
            <defLight name="OK">Ok</defLight>
        </defLightVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.propertyType == .light)
        #expect(property.permissions != nil)
        
        // Should have warning diagnostic for permissions on light property
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Permissions are ignored for light properties"))
    }
    
    @Test("Light property with timeout generates warning")
    func testLightPropertyWithTimeout() async throws {
        let xml = """
        <defLightVector device="Test Device" name="STATUS" timeout="60">
            <defLight name="OK">Ok</defLight>
        </defLightVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.propertyType == .light)
        #expect(property.timeout != nil)
        
        // Should have warning diagnostic for timeout on light property
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Timeout is ignored for light properties"))
    }
    
    @Test("Non-switch property with rule generates warning")
    func testNonSwitchPropertyWithRule() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST_PROPERTY" rule="OneOfMany">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.propertyType == .text)
        #expect(property.rule != nil)
        
        // Should have warning diagnostic for rule on non-switch property
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Rule is ignored for non-switch properties"))
    }
    
    @Test("Non-blob property with format generates warning")
    func testNonBlobPropertyWithFormat() async throws {
        let xml = """
        <defNumberVector device="Test Device" name="TEST_PROPERTY" format=".fits">
            <defNumber name="VALUE">42</defNumber>
        </defNumberVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.propertyType == .number)
        #expect(property.format != nil)
        
        // Should have warning diagnostic for format on non-blob property
        #expect(INDIDiagnosticsTestHelpers.hasWarning(property.diagnostics, containing: "Format is ignored for non-blob properties"))
    }
    
    @Test("Set operation with extra attributes generates error")
    func testSetOperationWithExtraAttributes() async throws {
        let xml = """
        <newSwitchVector device="Test Device" name="TEST_SWITCH" state="Ok" timeout="60">
            <oneSwitch name="OPTION1">On</oneSwitch>
        </newSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .set)
        
        // Should have error diagnostic for extra attributes on set operation
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "Set (new) operations only support name and device", 
                        "other attributes"))
    }
    
    @Test("Property with no values generates error")
    func testPropertyWithNoValues() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST_PROPERTY">
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.values.isEmpty)
        
        // Should have error diagnostic for missing values
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "The property must have at least one value"))
    }
    
    @Test("Valid property generates no errors")
    func testValidPropertyNoErrors() async throws {
        let xml = """
        <defTextVector device="Test Device" name="DRIVER_INFO" label="Driver Info" 
                       group="General Info" state="Idle" perm="ro" timeout="60">
            <defText name="DRIVER_NAME">Test Driver</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should NOT have any error diagnostics
        #expect(!INDIDiagnosticsTestHelpers.hasAnyError(property.diagnostics))
    }
    
    // MARK: - getProperties Validation Tests
    
    @Test("getProperties with unexpected attribute generates warning")
    func testGetPropertiesUnexpectedAttribute() async throws {
        let xml = "<getProperties version='1.7' device='Test' group='Main Control'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have warning about unexpected attribute
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "unexpected attribute",
            "group"
        ))
    }
    
    @Test("getProperties with multiple unexpected attributes generates warnings")
    func testGetPropertiesMultipleUnexpectedAttributes() async throws {
        let xml = "<getProperties version='1.7' device='Test' group='Main' label='Test Label' state='Ok'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have warnings for each unexpected attribute
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "group"
        ))
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "label"
        ))
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "state"
        ))
    }
    
    @Test("getProperties with child elements generates warning")
    func testGetPropertiesWithChildElements() async throws {
        let xml = """
        <getProperties version='1.7' device='Test'>
            <defText name="VALUE">Test</defText>
        </getProperties>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have warning about child elements
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "child element",
            "getProperties should not have any child elements"
        ))
    }
    
    @Test("getProperties with multiple child elements generates warning")
    func testGetPropertiesWithMultipleChildElements() async throws {
        let xml = """
        <getProperties version='1.7' device='Test'>
            <defText name="VALUE1">Test1</defText>
            <defText name="VALUE2">Test2</defText>
        </getProperties>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have warning about child elements
        #expect(INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "2 child element(s)"
        ))
    }
    
    @Test("getProperties with valid attributes only has no warnings")
    func testGetPropertiesValidAttributes() async throws {
        let xml = "<getProperties version='1.7' device='Test' name='CONNECTION'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should NOT have any warnings
        #expect(!INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "unexpected attribute"
        ))
        #expect(!INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "child element"
        ))
    }
    
    @Test("getProperties with only version has no warnings")
    func testGetPropertiesOnlyVersion() async throws {
        let xml = "<getProperties version='1.7'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should NOT have any warnings
        #expect(!INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "unexpected attribute"
        ))
        #expect(!INDIDiagnosticsTestHelpers.hasWarning(
            property.diagnostics,
            containing: "child element"
        ))
    }
    
    // MARK: - enableBLOB Validation Tests
    
    @Test("enableBLOB with valid attributes has no warnings")
    func testEnableBLOBValidAttributes() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='Also'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should NOT have any warnings
        #expect(!INDIDiagnosticsTestHelpers.hasAnyError(property.diagnostics))
    }
    
    @Test("enableBLOB with missing device generates error")
    func testEnableBLOBMissingDevice() async throws {
        let xml = "<enableBLOB name='CCD1' state='Also'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have error diagnostic for missing device
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "Device is required but not found"))
        #expect(property.device == "UNKNOWN")
    }
    
    @Test("enableBLOB with missing name generates error")
    func testEnableBLOBMissingName() async throws {
        let xml = "<enableBLOB device='CCD Simulator' state='Also'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        
        // Should have error diagnostic for missing name
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "The property name is required but not found"))
        #expect(property.name?.indiName == "UNKNOWN")
    }
}


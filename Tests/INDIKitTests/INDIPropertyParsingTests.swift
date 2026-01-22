import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Property Parsing Tests")
struct INDIPropertyParsingTests {
    
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
    
    
    // MARK: - defTextVector Tests
    
    @Test("Parse defTextVector property")
    func testParseDefTextVector() async throws {
        let xml = """
        <defTextVector device="CCD Simulator" name="DRIVER_INFO" label="Driver Info" 
                       group="General Info" state="Idle" perm="ro" timeout="60" 
                       timestamp="2026-01-22T15:32:57">
            <defText name="DRIVER_NAME" label="Name">CCD Simulator</defText>
            <defText name="DRIVER_EXEC" label="Exec">indi_simulator_ccd</defText>
            <defText name="DRIVER_VERSION" label="Version">1.0</defText>
            <defText name="DRIVER_INTERFACE" label="Interface">22</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .define)
        #expect(property.propertyType == .text)
        #expect(property.device == "CCD Simulator")
        #expect(property.name?.indiName == "DRIVER_INFO")
        #expect(property.label == "Driver Info")
        #expect(property.group == "General Info")
        #expect(property.permissions == .readOnly)
        #expect(property.state == .idle)
        #expect(property.timeout == 60.0)
        #expect(property.values.count == 4)
        
        let firstValue = property.values[0]
        #expect(firstValue.name.indiName == "DRIVER_NAME")
        if case .text(let text) = firstValue.value {
            #expect(text == "CCD Simulator")
        } else {
            Issue.record("Expected text value")
        }
    }
    
    @Test("Parse defTextVector with minimal attributes")
    func testParseDefTextVectorMinimal() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST_PROPERTY">
            <defText name="VALUE1">Test Value</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .define)
        #expect(property.propertyType == .text)
        #expect(property.device == "Test Device")
        #expect(property.name?.indiName == "TEST_PROPERTY")
        #expect(property.label == nil)
        #expect(property.group == nil)
        #expect(property.permissions == nil)
        #expect(property.state == nil)
        #expect(property.timeout == nil)
    }
    
    // MARK: - setNumberVector Tests
    
    @Test("Parse setNumberVector property")
    func testParseSetNumberVector() async throws {
        let xml = """
        <setNumberVector device="Telescope Simulator" name="EQUATORIAL_EOD_COORD" 
                         state="Idle" timeout="60" timestamp="2026-01-22T15:39:47">
            <oneNumber name="RA">23.796781518652824872</oneNumber>
            <oneNumber name="DEC">90</oneNumber>
        </setNumberVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .update)
        #expect(property.propertyType == .number)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "EQUATORIAL_EOD_COORD")
        #expect(property.state == .idle)
        #expect(property.values.count == 2)
        
        let raValue = property.values.first { $0.name.indiName == "RA" }
        #expect(raValue != nil)
        if let ra = raValue, case .number(let num) = ra.value {
            #expect(num == 23.796781518652824872)
        } else {
            Issue.record("Expected number value for RA")
        }
        
        let decValue = property.values.first { $0.name.indiName == "DEC" }
        #expect(decValue != nil)
        if let dec = decValue, case .number(let num) = dec.value {
            #expect(num == 90.0)
        } else {
            Issue.record("Expected number value for DEC")
        }
    }
    
    @Test("Parse defNumberVector with min/max/step/unit")
    func testParseDefNumberVectorWithMetadata() async throws {
        let xml = """
        <defNumberVector device="Test Device" name="TEST_NUMBER" label="Test Number" 
                         group="Test Group" state="Ok" perm="rw" timeout="30">
            <defNumber name="VALUE" label="Value" format="%.2f" min="0" max="100" 
                       step="1" unit="percent">50</defNumber>
        </defNumberVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .define)
        #expect(property.propertyType == .number)
        
        #expect(property.values.count == 1)
        let value = property.values[0]
        #expect(value.min == 0.0)
        #expect(value.max == 100.0)
        #expect(value.step == 1.0)
        #expect(value.unit == "percent")
        #expect(value.format == "%.2f")
        
        if case .number(let num) = value.value {
            #expect(num == 50.0)
        } else {
            Issue.record("Expected number value")
        }
    }
    
    // MARK: - defSwitchVector Tests
    
    @Test("Parse defSwitchVector property")
    func testParseDefSwitchVector() async throws {
        let xml = """
        <defSwitchVector device="Telescope Simulator" name="CONNECTION" 
                         label="Connection" group="Main Control" state="Ok" 
                         perm="rw" rule="OneOfMany" timeout="60" 
                         timestamp="2026-01-22T15:32:57">
            <defSwitch name="CONNECT" label="Connect">On</defSwitch>
            <defSwitch name="DISCONNECT" label="Disconnect">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .define)
        #expect(property.propertyType == .toggle)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "CONNECTION")
        #expect(property.rule == .oneOfMany)
        #expect(property.values.count == 2)
        
        let connectValue = property.values.first { $0.name.indiName == "CONNECT" }
        #expect(connectValue != nil)
        if let connect = connectValue, case .boolean(let bool) = connect.value {
            #expect(bool == true)
        } else {
            Issue.record("Expected boolean value for CONNECT")
        }
        
        let disconnectValue = property.values.first { $0.name.indiName == "DISCONNECT" }
        #expect(disconnectValue != nil)
        if let disconnect = disconnectValue, case .boolean(let bool) = disconnect.value {
            #expect(bool == false)
        } else {
            Issue.record("Expected boolean value for DISCONNECT")
        }
    }
    
    @Test("Parse defSwitchVector with AnyOfMany rule")
    func testParseDefSwitchVectorAnyOfMany() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="AnyOfMany">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .anyOfMany)
    }
    
    // MARK: - newSwitchVector Tests
    
    @Test("Parse newSwitchVector property")
    func testParseNewSwitchVector() async throws {
        let xml = """
        <newSwitchVector device="Telescope Simulator" name="CONNECTION">
            <oneSwitch name="CONNECT">On</oneSwitch>
            <oneSwitch name="DISCONNECT">Off</oneSwitch>
        </newSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .set)
        #expect(property.propertyType == .toggle)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "CONNECTION")
        #expect(property.values.count == 2)
    }
    
    // MARK: - Light Property Tests
    
    @Test("Parse defLightVector property")
    func testParseDefLightVector() async throws {
        let xml = """
        <defLightVector device="Mount" name="TELESCOPE_STATUS">
            <defLight name="TRACKING">Ok</defLight>
            <defLight name="SLEWING">Idle</defLight>
            <defLight name="BUSY_STATE">Busy</defLight>
            <defLight name="ALERT_STATE">Alert</defLight>
        </defLightVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .define)
        #expect(property.propertyType == .light)
        #expect(property.values.count == 4)
        
        // "Ok" should be stored as INDIState.ok
        let trackingValue = property.values.first { $0.name.indiName == "TRACKING" }
        #expect(trackingValue != nil)
        if let tracking = trackingValue, case .state(let state) = tracking.value {
            #expect(state == .ok)
        } else {
            Issue.record("Expected state value for TRACKING")
        }
        
        // "Idle" should be stored as INDIState.idle
        let slewingValue = property.values.first { $0.name.indiName == "SLEWING" }
        #expect(slewingValue != nil)
        if let slewing = slewingValue, case .state(let state) = slewing.value {
            #expect(state == .idle)
        } else {
            Issue.record("Expected state value for SLEWING")
        }
        
        // "Busy" should be stored as INDIState.busy
        let busyValue = property.values.first { $0.name.indiName == "BUSY_STATE" }
        #expect(busyValue != nil)
        if let busy = busyValue, case .state(let state) = busy.value {
            #expect(state == .busy)
        } else {
            Issue.record("Expected state value for BUSY_STATE")
        }
        
        // "Alert" should be stored as INDIState.alert
        let alertValue = property.values.first { $0.name.indiName == "ALERT_STATE" }
        #expect(alertValue != nil)
        if let alert = alertValue, case .state(let state) = alert.value {
            #expect(state == .alert)
        } else {
            Issue.record("Expected state value for ALERT_STATE")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Parse property with missing optional attributes")
    func testParsePropertyWithMissingAttributes() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.label == nil)
        #expect(property.group == nil)
        #expect(property.permissions == nil)
        #expect(property.state == nil)
        #expect(property.timeout == nil)
        #expect(property.timeStamp == nil)
    }
    
    @Test("Parse property with unknown property name")
    func testParsePropertyWithUnknownName() async throws {
        let xml = """
        <defTextVector device="Test Device" name="UNKNOWN_PROPERTY_NAME">
            <defText name="VALUE">Test</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        if case .other(let name) = property.name {
            #expect(name == "UNKNOWN_PROPERTY_NAME")
        } else {
            Issue.record("Expected unknown property name")
        }
    }
    
    @Test("Parse property with invalid boolean value")
    func testParsePropertyWithInvalidBoolean() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST">
            <defSwitch name="VALUE1">On</defSwitch>
            <defSwitch name="VALUE2">Invalid</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.values.count == 2)
        
        // The invalid value should still be parsed (as false) but with a warning
        let invalidValue = property.values.first { $0.name.indiName == "VALUE2" }
        #expect(invalidValue != nil)
        // Should have diagnostics warning about invalid boolean
        if let value = invalidValue {
            let hasAnyWarning = value.diagnostics.contains { diagnostic in
                if case .warning = diagnostic {
                    return true
                }
                return false
            }
            #expect(hasAnyWarning)
        }
    }
    
    @Test("Parse multiple properties in sequence")
    func testParseMultipleProperties() async throws {
        let xml = """
        <defTextVector device="Device1" name="PROP1">
            <defText name="VALUE1">Value1</defText>
        </defTextVector>
        <setNumberVector device="Device2" name="PROP2">
            <oneNumber name="NUM">42</oneNumber>
        </setNumberVector>
        <defSwitchVector device="Device3" name="PROP3">
            <defSwitch name="SW">On</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 3)
        #expect(properties[0].operation == .define)
        #expect(properties[0].propertyType == .text)
        #expect(properties[1].operation == .update)
        #expect(properties[1].propertyType == .number)
        #expect(properties[2].operation == .define)
        #expect(properties[2].propertyType == .toggle)
    }
    
    // MARK: - Switch Rule Validation Tests
    
    @Test("OneOfMany rule violation - no switches On")
    func testOneOfManyRuleViolationNoSwitchesOn() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="OneOfMany">
            <defSwitch name="OPTION1">Off</defSwitch>
            <defSwitch name="OPTION2">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .oneOfMany)
        
        // Should have error diagnostic for rule violation
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "OneOfMany", "requires exactly one switch to be On"))
    }
    
    @Test("OneOfMany rule violation - multiple switches On")
    func testOneOfManyRuleViolationMultipleSwitchesOn() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="OneOfMany">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">On</defSwitch>
            <defSwitch name="OPTION3">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .oneOfMany)
        
        // Should have error diagnostic for rule violation
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "OneOfMany", 
                        "requires exactly one switch to be On", "2 switch(es) are On"))
    }
    
    @Test("OneOfMany rule valid - exactly one switch On")
    func testOneOfManyRuleValid() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="OneOfMany">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">Off</defSwitch>
            <defSwitch name="OPTION3">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .oneOfMany)
        
        // Should NOT have error diagnostic for rule violation
        #expect(!INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "OneOfMany"))
    }
    
    @Test("AtMostOne rule violation - multiple switches On")
    func testAtMostOneRuleViolationMultipleSwitchesOn() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="AtMostOne">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">On</defSwitch>
            <defSwitch name="OPTION3">On</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .atMostOne)
        
        // Should have error diagnostic for rule violation
        #expect(INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "AtMostOne", 
                        "allows at most one switch to be On", "3 switch(es) are On"))
    }
    
    @Test("AtMostOne rule valid - zero switches On")
    func testAtMostOneRuleValidZeroOn() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="AtMostOne">
            <defSwitch name="OPTION1">Off</defSwitch>
            <defSwitch name="OPTION2">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .atMostOne)
        
        // Should NOT have error diagnostic for rule violation
        #expect(!INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "AtMostOne"))
    }
    
    @Test("AtMostOne rule valid - one switch On")
    func testAtMostOneRuleValidOneOn() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="AtMostOne">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">Off</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .atMostOne)
        
        // Should NOT have error diagnostic for rule violation
        #expect(!INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "AtMostOne"))
    }
    
    @Test("AnyOfMany rule - no validation")
    func testAnyOfManyRuleNoValidation() async throws {
        let xml = """
        <defSwitchVector device="Test Device" name="TEST_SWITCH" rule="AnyOfMany">
            <defSwitch name="OPTION1">On</defSwitch>
            <defSwitch name="OPTION2">On</defSwitch>
            <defSwitch name="OPTION3">On</defSwitch>
        </defSwitchVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.rule == .anyOfMany)
        
        // Should NOT have error diagnostic for rule violation (AnyOfMany allows any combination)
        #expect(!INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "AnyOfMany"))
        #expect(!INDIDiagnosticsTestHelpers.hasError(property.diagnostics, containing: "switch rule"))
    }
    
    @Test("Parse property with trimmed text values")
    func testParsePropertyWithTrimmedText() async throws {
        let xml = """
        <defTextVector device="Test Device" name="TEST">
            <defText name="VALUE1">  Trimmed Value  </defText>
            <defText name="VALUE2">\n\nNewline Value\n\n</defText>
        </defTextVector>
        """
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.values.count == 2)
        
        let value1 = property.values.first { $0.name.indiName == "VALUE1" }
        if let v1 = value1, case .text(let text) = v1.value {
            #expect(text == "Trimmed Value")
        } else {
            Issue.record("Expected trimmed text value")
        }
        
        let value2 = property.values.first { $0.name.indiName == "VALUE2" }
        if let v2 = value2, case .text(let text) = v2.value {
            #expect(text == "Newline Value")
        } else {
            Issue.record("Expected trimmed text value")
        }
    }
    
    // MARK: - getProperties Tests
    
    @Test("Parse getProperties without attributes")
    func testParseGetPropertiesMinimal() async throws {
        let xml = "<getProperties version='1.7'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .get)
        #expect(property.propertyType == nil)
        #expect(property.device == nil)
        #expect(property.name == nil)
        #expect(property.values.isEmpty)
    }
    
    @Test("Parse getProperties with device attribute")
    func testParseGetPropertiesWithDevice() async throws {
        let xml = "<getProperties version='1.7' device='Telescope Simulator'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name == nil)
    }
    
    @Test("Parse getProperties with name attribute")
    func testParseGetPropertiesWithName() async throws {
        let xml = "<getProperties version='1.7' name='CONNECTION'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .get)
        #expect(property.device == nil)
        #expect(property.name?.indiName == "CONNECTION")
    }
    
    @Test("Parse getProperties with device and name attributes")
    func testParseGetPropertiesWithDeviceAndName() async throws {
        let xml = "<getProperties version='1.7' device='Telescope Simulator' name='CONNECTION'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "CONNECTION")
    }
    
    @Test("Parse getProperties with custom version")
    func testParseGetPropertiesWithCustomVersion() async throws {
        let xml = "<getProperties version='1.8'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == .get)
        // Check version via XML serialization
        do {
            let propertyXML = try property.toXML()
            #expect(propertyXML.contains("version='1.8'"))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    // MARK: - enableBLOB Tests
    
    @Test("Parse enableBLOB with Also state")
    func testParseEnableBLOBWithAlso() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='Also'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.propertyType == nil)
        #expect(property.device == "CCD Simulator")
        #expect(property.name?.indiName == "CCD1")
        #expect(property.blobSendingState == BLOBSendingState.also)
        #expect(property.values.isEmpty)
    }
    
    @Test("Parse enableBLOB with Raw state")
    func testParseEnableBLOBWithRaw() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='Raw'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.blobSendingState == BLOBSendingState.raw)
    }
    
    @Test("Parse enableBLOB with Off state")
    func testParseEnableBLOBWithOff() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='Off'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.blobSendingState == BLOBSendingState.off)
    }
    
    @Test("Parse enableBLOB with On state")
    func testParseEnableBLOBWithOn() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='On'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.blobSendingState == BLOBSendingState.on)
    }
    
    @Test("Parse enableBLOB without state attribute is nil")
    func testParseEnableBLOBWithoutState() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.blobSendingState == nil) // Optional, no default
    }
    
    @Test("Parse enableBLOB with invalid state is nil")
    func testParseEnableBLOBWithInvalidState() async throws {
        let xml = "<enableBLOB device='CCD Simulator' name='CCD1' state='Invalid'/>"
        
        let properties = try await parseXML(xml)
        
        #expect(properties.count == 1)
        let property = properties[0]
        #expect(property.operation == INDIPropertyOperation.enableBlob)
        #expect(property.blobSendingState == nil) // nil when invalid
    }
}


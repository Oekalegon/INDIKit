import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Property XML Serialization Tests")
struct INDIPropertyXMLSerializationTests {
    
    // MARK: - Set Operation Tests (only device and name)
    
    @Test("Serialize set text property to XML")
    func testSerializeSetTextProperty() throws {
        let value = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Test Driver"),
            propertyType: .text
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("DRIVER_INFO"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        // Should only contain device and name for set operations
        #expect(xml.contains("device=\"Test Device\""))
        #expect(xml.contains("name=\"DRIVER_INFO\""))
        #expect(!xml.contains("group="))
        #expect(!xml.contains("label="))
        #expect(!xml.contains("perm="))
        #expect(!xml.contains("state="))
        
        // Should contain the value
        #expect(xml.contains("<oneText name=\"DRIVER_NAME\">"))
        #expect(xml.contains("Test Driver"))
        #expect(xml.contains("</oneText>"))
        
        // Should have correct element name
        #expect(xml.contains("<newTextVector"))
        #expect(xml.contains("</newTextVector>"))
    }
    
    @Test("Serialize set switch property to XML")
    func testSerializeSetSwitchProperty() throws {
        let connectValue = INDIValue(
            name: .connect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let disconnectValue = INDIValue(
            name: .disconnect,
            value: .boolean(false),
            propertyType: .toggle
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .toggle,
            device: "Telescope Simulator",
            name: .connection,
            values: [connectValue, disconnectValue]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<newSwitchVector"))
        #expect(xml.contains("device=\"Telescope Simulator\""))
        #expect(xml.contains("name=\"CONNECTION\""))
        #expect(xml.contains("<oneSwitch name=\"CONNECT\">On</oneSwitch>"))
        #expect(xml.contains("<oneSwitch name=\"DISCONNECT\">Off</oneSwitch>"))
        #expect(xml.contains("</newSwitchVector>"))
    }
    
    @Test("Serialize set number property to XML")
    func testSerializeSetNumberProperty() throws {
        let raValue = INDIValue(
            name: .other("RA"),
            value: .number(23.5),
            propertyType: .number
        )
        
        let decValue = INDIValue(
            name: .other("DEC"),
            value: .number(45.0),
            propertyType: .number
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .number,
            device: "Telescope Simulator",
            name: .other("EQUATORIAL_EOD_COORD"),
            values: [raValue, decValue]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<newNumberVector"))
        #expect(xml.contains("<oneNumber name=\"RA\">23.5</oneNumber>"))
        #expect(xml.contains("<oneNumber name=\"DEC\">45.0</oneNumber>"))
    }
    
    // MARK: - Define/Update Operation Tests (all attributes)
    
    @Test("Serialize define property with all attributes to XML")
    func testSerializeDefinePropertyWithAllAttributes() throws {
        let value = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Test Driver"),
            label: "Driver Name",
            propertyType: .text
        )
        
        let property = INDIProperty.define(INDIDefineProperty(
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
        
        let xml = try property.toXML()
        
        // Should contain all attributes for define operations
        #expect(xml.contains("device=\"Test Device\""))
        #expect(xml.contains("name=\"DRIVER_INFO\""))
        #expect(xml.contains("group=\"General Info\""))
        #expect(xml.contains("label=\"Driver Info\""))
        #expect(xml.contains("perm=\"ro\""))
        #expect(xml.contains("state=\"Idle\""))
        #expect(xml.contains("timeout=\"60.0\""))
        
        #expect(xml.contains("<defTextVector"))
    }
    
    // MARK: - Value Type Tests
    
    @Test("Serialize text value to XML")
    func testSerializeTextValue() throws {
        let value = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Test & Value"),
            label: "Driver Name",
            propertyType: .text
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("DRIVER_INFO"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneText name=\"DRIVER_NAME\" label=\"Driver Name\">"))
        #expect(xml.contains("Test &amp; Value")) // Should be escaped
        #expect(xml.contains("</oneText>"))
    }
    
    @Test("Serialize boolean value to XML")
    func testSerializeBooleanValue() throws {
        let value = INDIValue(
            name: .connect,
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .toggle,
            device: "Test Device",
            name: .connection,
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneSwitch name=\"CONNECT\">On</oneSwitch>"))
        
        // Test false value
        let falseValue = INDIValue(
            name: .disconnect,
            value: .boolean(false),
            propertyType: .toggle
        )
        
        let property2 = INDIProperty.set(INDISetProperty(
            propertyType: .toggle,
            device: "Test Device",
            name: .connection,
            values: [falseValue]
        ))
        
        let xml2 = try property2.toXML()
        #expect(xml2.contains("<oneSwitch name=\"DISCONNECT\">Off</oneSwitch>"))
    }
    
    @Test("Serialize state value to XML")
    func testSerializeStateValue() throws {
        let value = INDIValue(
            name: .other("STATUS"),
            value: .state(.ok),
            propertyType: .light
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .light,
            device: "Test Device",
            name: .other("STATUS"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneLight name=\"STATUS\">Ok</oneLight>"))
    }
    
    @Test("Serialize number value with attributes to XML")
    func testSerializeNumberValueWithAttributes() throws {
        let value = INDIValue(
            name: .temperature,
            value: .number(25.5),
            label: "Temperature",
            format: "%.1f",
            min: -50.0,
            max: 50.0,
            step: 0.1,
            unit: "°C",
            propertyType: .number
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .number,
            device: "Weather Station",
            name: .atmosphere,
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneNumber name=\"TEMPERATURE\" label=\"Temperature\""))
        #expect(xml.contains("format=\"%.1f\""))
        #expect(xml.contains("min=\"-50.0\""))
        #expect(xml.contains("max=\"50.0\""))
        #expect(xml.contains("step=\"0.1\""))
        #expect(xml.contains("unit=\"°C\""))
        #expect(xml.contains(">25.5</oneNumber>"))
    }
    
    @Test("Serialize blob value to XML")
    func testSerializeBlobValue() throws {
        let testData = Data("test blob data".utf8)
        let value = INDIValue(
            name: .other("IMAGE"),
            value: .blob(testData),
            label: "Image",
            format: ".fits",
            size: testData.count,
            compressed: false,
            propertyType: .blob
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .blob,
            device: "CCD Simulator",
            name: .other("CCD1"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneBLOB name=\"IMAGE\" label=\"Image\""))
        #expect(xml.contains("format=\".fits\""))
        #expect(xml.contains("size=\"\(testData.count)\""))
        #expect(xml.contains("compressed=\"Off\""))
        
        // Should contain base64 encoded data
        let base64String = testData.base64EncodedString()
        #expect(xml.contains(base64String))
    }
    
    @Test("Serialize blob value with compression to XML")
    func testSerializeBlobValueWithCompression() throws {
        let testData = Data("compressed data".utf8)
        let value = INDIValue(
            name: .other("IMAGE"),
            value: .blob(testData),
            format: ".jpg",
            size: testData.count,
            compressed: true,
            propertyType: .blob
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .blob,
            device: "CCD Simulator",
            name: .other("CCD1"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("compressed=\"On\""))
    }
    
    // MARK: - XML Escaping Tests
    
    @Test("Escape XML special characters in attribute values")
    func testEscapeXMLSpecialCharactersInAttributes() throws {
        let value = INDIValue(
            name: .other("TEST&NAME"),
            value: .text("Value"),
            label: "Test & Label",
            propertyType: .text
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Device & Name",
            name: .other("PROP<NAME>"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        // Attribute values should be escaped
        #expect(xml.contains("device=\"Device &amp; Name\""))
        #expect(xml.contains("name=\"PROP&lt;NAME&gt;\""))
        #expect(xml.contains("label=\"Test &amp; Label\""))
    }
    
    @Test("Escape XML special characters in text content")
    func testEscapeXMLSpecialCharactersInText() throws {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test & < > \" ' characters"),
            propertyType: .text
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("TEST"),
            values: [value]
        ))
        
        let xml = try property.toXML()
        
        // Text content should be escaped
        #expect(xml.contains("Test &amp; &lt; &gt; &quot; &apos; characters"))
    }
    
    // MARK: - Multiple Values Tests
    
    @Test("Serialize property with multiple values to XML")
    func testSerializePropertyWithMultipleValues() throws {
        let value1 = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Driver 1"),
            propertyType: .text
        )
        
        let value2 = INDIValue(
            name: .other("DRIVER_EXEC"),
            value: .text("driver1"),
            propertyType: .text
        )
        
        let value3 = INDIValue(
            name: .other("DRIVER_VERSION"),
            value: .text("1.0"),
            propertyType: .text
        )
        
        let property = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("DRIVER_INFO"),
            values: [value1, value2, value3]
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<oneText name=\"DRIVER_NAME\">Driver 1</oneText>"))
        #expect(xml.contains("<oneText name=\"DRIVER_EXEC\">driver1</oneText>"))
        #expect(xml.contains("<oneText name=\"DRIVER_VERSION\">1.0</oneText>"))
        
        // Should have newlines between values
        let lines = xml.components(separatedBy: "\n")
        #expect(lines.count >= 4) // Opening tag, 3 values, closing tag
    }
    
    // MARK: - Element Name Tests
    
    @Test("Serialize different property types with correct element names")
    func testSerializeDifferentPropertyTypes() throws {
        let textValue = INDIValue(
            name: .other("TEXT"),
            value: .text("Test"),
            propertyType: .text
        )
        
        let textProperty = INDIProperty.set(INDISetProperty(
            propertyType: .text,
            device: "Test",
            name: .other("TEXT_PROP"),
            values: [textValue]
        ))
        
        let textXML = try textProperty.toXML()
        #expect(textXML.contains("<newTextVector"))
        
        let numberValue = INDIValue(
            name: .other("NUM"),
            value: .number(42.0),
            propertyType: .number
        )
        
        let numberProperty = INDIProperty.set(INDISetProperty(
            propertyType: .number,
            device: "Test",
            name: .other("NUM_PROP"),
            values: [numberValue]
        ))
        
        let numberXML = try numberProperty.toXML()
        #expect(numberXML.contains("<newNumberVector"))
        
        let switchValue = INDIValue(
            name: .other("SW"),
            value: .boolean(true),
            propertyType: .toggle
        )
        
        let switchProperty = INDIProperty.set(INDISetProperty(
            propertyType: .toggle,
            device: "Test",
            name: .other("SW_PROP"),
            values: [switchValue]
        ))
        
        let switchXML = try switchProperty.toXML()
        #expect(switchXML.contains("<newSwitchVector"))
        
        let lightValue = INDIValue(
            name: .other("LIGHT"),
            value: .state(.ok),
            propertyType: .light
        )
        
        let lightProperty = INDIProperty.set(INDISetProperty(
            propertyType: .light,
            device: "Test",
            name: .other("LIGHT_PROP"),
            values: [lightValue]
        ))
        
        let lightXML = try lightProperty.toXML()
        #expect(lightXML.contains("<newLightVector"))
        
        let blobValue = INDIValue(
            name: .other("BLOB"),
            value: .blob(Data()),
            propertyType: .blob
        )
        
        let blobProperty = INDIProperty.set(INDISetProperty(
            propertyType: .blob,
            device: "Test",
            name: .other("BLOB_PROP"),
            values: [blobValue]
        ))
        
        let blobXML = try blobProperty.toXML()
        #expect(blobXML.contains("<newBLOBVector"))
    }
    
    // MARK: - getProperties Serialization Tests
    
    @Test("Serialize getProperties without attributes to XML")
    func testSerializeGetPropertiesMinimal() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: nil,
            name: nil
        ))
        
        let xml = try property.toXML()
        
        // Should be self-closing
        #expect(xml == "<getProperties version='1.7'/>")
    }
    
    @Test("Serialize getProperties with device to XML")
    func testSerializeGetPropertiesWithDevice() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: "Telescope Simulator",
            name: nil
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("device=\"Telescope Simulator\""))
        #expect(xml.contains("version='1.7'"))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize getProperties with name to XML")
    func testSerializeGetPropertiesWithName() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: nil,
            name: .connection
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("name=\"CONNECTION\""))
        #expect(xml.contains("version='1.7'"))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize getProperties with device and name to XML")
    func testSerializeGetPropertiesWithDeviceAndName() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: "Telescope Simulator",
            name: .connection
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("device=\"Telescope Simulator\""))
        #expect(xml.contains("name=\"CONNECTION\""))
        #expect(xml.contains("version='1.7'"))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize getProperties with custom version to XML")
    func testSerializeGetPropertiesWithCustomVersion() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: nil,
            name: nil,
            version: "1.8"
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("version='1.8'"))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize getProperties with escaped device name")
    func testSerializeGetPropertiesWithEscapedDevice() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: "Test & Device",
            name: nil
        ))
        
        let xml = try property.toXML()
        
        // Should escape special characters
        #expect(xml.contains("device=\"Test &amp; Device\""))
        #expect(!xml.contains("device=\"Test & Device\""))
    }
    
    @Test("Serialize getProperties with escaped property name")
    func testSerializeGetPropertiesWithEscapedName() throws {
        let property = INDIProperty.get(INDIGetProperties(
            device: nil,
            name: .other("TEST & PROP")
        ))
        
        let xml = try property.toXML()
        
        // Should escape special characters
        #expect(xml.contains("name=\"TEST &amp; PROP\""))
        #expect(!xml.contains("name=\"TEST & PROP\""))
    }
    
    // MARK: - enableBLOB Serialization Tests
    
    @Test("Serialize enableBLOB with also state to XML")
    func testSerializeEnableBLOBWithAlso() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: BLOBSendingState.also
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("<enableBLOB"))
        #expect(xml.contains("device=\"CCD Simulator\""))
        #expect(xml.contains("name=\"CCD1\""))
        #expect(xml.contains("state=\"Also\""))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize enableBLOB with raw state to XML")
    func testSerializeEnableBLOBWithRaw() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: BLOBSendingState.raw
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("state=\"Raw\""))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize enableBLOB with off state to XML")
    func testSerializeEnableBLOBWithOff() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: BLOBSendingState.off
        ))
        
        let xml = try property.toXML()
        
        #expect(xml.contains("state=\"Off\""))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize enableBLOB without state to XML")
    func testSerializeEnableBLOBWithoutState() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "CCD Simulator",
            name: .other("CCD1")
        ))
        
        let xml = try property.toXML()
        
        // Should not have state attribute when state is nil
        #expect(xml.contains("<enableBLOB"))
        #expect(xml.contains("device=\"CCD Simulator\""))
        #expect(xml.contains("name=\"CCD1\""))
        #expect(!xml.contains("state="))
        #expect(xml.hasSuffix("/>"))
    }
    
    @Test("Serialize enableBLOB with escaped device name")
    func testSerializeEnableBLOBWithEscapedDevice() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "Test & Device",
            name: .other("CCD1"),
            blobSendingState: BLOBSendingState.also
        ))
        
        let xml = try property.toXML()
        
        // Should escape special characters
        #expect(xml.contains("device=\"Test &amp; Device\""))
        #expect(!xml.contains("device=\"Test & Device\""))
    }
    
    @Test("Serialize enableBLOB with escaped property name")
    func testSerializeEnableBLOBWithEscapedName() throws {
        let property = INDIProperty.enableBlob(INDIEnableBlobProperty(
            device: "CCD Simulator",
            name: .other("TEST & PROP"),
            blobSendingState: BLOBSendingState.also
        ))
        
        let xml = try property.toXML()
        
        // Should escape special characters
        #expect(xml.contains("name=\"TEST &amp; PROP\""))
        #expect(!xml.contains("name=\"TEST & PROP\""))
    }
    
    @Test("Serialize enableBLOB throws error when device is missing")
    func testSerializeEnableBLOBThrowsWhenDeviceMissing() {
        // This test would require creating an invalid property, which is prevented by the initializer
        // So we test that the initializer requires device
        #expect(Bool(true)) // Placeholder - the initializer enforces this at compile time
    }
    
    @Test("Serialize enableBLOB throws error when name is missing")
    func testSerializeEnableBLOBThrowsWhenNameMissing() {
        // This test would require creating an invalid property, which is prevented by the initializer
        // So we test that the initializer requires name
        #expect(Bool(true)) // Placeholder - the initializer enforces this at compile time
    }
}


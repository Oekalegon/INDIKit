import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Property Creation Tests")
struct INDIPropertyCreationTests {
    
    // MARK: - Property Creation Tests
    
    @Test("Create text property programmatically")
    func testCreateTextProperty() async throws {
        let value = INDIValue(
            name: .other("DRIVER_NAME"),
            value: .text("Test Driver"),
            label: "Driver Name",
            propertyType: .text
        )
        
        let property = INDIProperty(
            operation: .define,
            propertyType: .text,
            device: "Test Device",
            name: .other("DRIVER_INFO"),
            group: "General Info",
            label: "Driver Info",
            permissions: .readOnly,
            state: .idle,
            timeout: 60.0,
            values: [value]
        )
        
        #expect(property.operation == INDIPropertyOperation.define)
        #expect(property.propertyType == INDIPropertyType.text)
        #expect(property.device == "Test Device")
        if case .other(let name) = property.name {
            #expect(name == "DRIVER_INFO")
        } else {
            Issue.record("Expected other property name")
        }
        #expect(property.values.count == 1)
        #expect(property.group == "General Info")
        #expect(property.label == "Driver Info")
        #expect(property.permissions == INDIPropertyPermissions.readOnly)
        #expect(property.state == INDIState.idle)
        #expect(property.timeout == 60.0)
        
        // Check internal XML node representation
        // The xmlNode should have the correct element name
        let elementName = property.xmlNode.name
        #expect(elementName.contains("def"))
        #expect(elementName.contains("Text"))
        #expect(elementName.contains("Vector"))
        
        // Check attributes
        let attrs = property.xmlNode.attributes
        #expect(attrs["device"] == "Test Device")
        #expect(attrs["name"] == "DRIVER_INFO")
        #expect(attrs["group"] == "General Info")
        #expect(attrs["label"] == "Driver Info")
        #expect(attrs["perm"] == "ro")
        #expect(attrs["state"] == "Idle")
        #expect(attrs["timeout"] == "60.0")
    }
    
    @Test("Create number property programmatically")
    func testCreateNumberProperty() async throws {
        let value = INDIValue(
            name: .other("TEMPERATURE"),
            value: .number(25.5),
            label: "Temperature",
            min: -50.0,
            max: 50.0,
            step: 0.1,
            unit: "°C",
            propertyType: .number
        )
        
        let property = INDIProperty(
            operation: .update,
            propertyType: .number,
            device: "Weather Station",
            name: .atmosphere,
            label: "Atmosphere",
            state: .ok,
            values: [value]
        )
        
        #expect(property.operation == INDIPropertyOperation.update)
        #expect(property.propertyType == INDIPropertyType.number)
        #expect(property.values.count == 1)
        
        if let firstValue = property.values.first {
            if case .number(let num) = firstValue.value {
                #expect(num == 25.5)
            } else {
                Issue.record("Expected number value")
            }
            #expect(firstValue.min == -50.0)
            #expect(firstValue.max == 50.0)
            #expect(firstValue.step == 0.1)
            #expect(firstValue.unit == "°C")
        }
        
        // Check XML node
        let elementName = property.xmlNode.name
        #expect(elementName.contains("set"))
        #expect(elementName.contains("Number") || elementName.contains("number"))
    }
    
    @Test("Create switch property programmatically")
    func testCreateSwitchProperty() async throws {
        let connectValue = INDIValue(
            name: .connect,
            value: .boolean(true),
            label: "Connect",
            propertyType: .toggle
        )
        
        let disconnectValue = INDIValue(
            name: .disconnect,
            value: .boolean(false),
            label: "Disconnect",
            propertyType: .toggle
        )
        
        let property = INDIProperty(
            operation: .define,
            propertyType: .toggle,
            device: "Telescope Simulator",
            name: .connection,
            group: "Main Control",
            label: "Connection",
            permissions: .readWrite,
            state: .ok,
            timeout: 60.0,
            rule: .oneOfMany,
            values: [connectValue, disconnectValue]
        )
        
        #expect(property.operation == INDIPropertyOperation.define)
        #expect(property.propertyType == INDIPropertyType.toggle)
        #expect(property.values.count == 2)
        #expect(property.rule == INDISwitchRule.oneOfMany)
        
        // Check XML node
        let elementName = property.xmlNode.name
        #expect(elementName.contains("def"))
        #expect(elementName.contains("Switch"))
        
        let attrs = property.xmlNode.attributes
        #expect(attrs["rule"] == "OneOfMany")
    }
    
    @Test("Create light property programmatically")
    func testCreateLightProperty() async throws {
        let okValue = INDIValue(
            name: .other("OK"),
            value: .state(.ok),
            label: "OK",
            propertyType: .light
        )
        
        let property = INDIProperty(
            operation: .define,
            propertyType: .light,
            device: "Test Device",
            name: .other("STATUS"),
            label: "Status",
            values: [okValue]
        )
        
        #expect(property.propertyType == INDIPropertyType.light)
        #expect(property.values.count == 1)
        
        if let firstValue = property.values.first {
            if case .state(let state) = firstValue.value {
                #expect(state == .ok)
            } else {
                Issue.record("Expected state value")
            }
        }
        
        // Check XML node
        let elementName = property.xmlNode.name
        #expect(elementName.contains("def"))
        #expect(elementName.contains("Light"))
    }
    
    @Test("Create blob property programmatically")
    func testCreateBlobProperty() async throws {
        let blobData = Data("test blob data".utf8)
        let value = INDIValue(
            name: .other("IMAGE"),
            value: .blob(blobData),
            label: "Image",
            format: ".fits",
            size: blobData.count,
            propertyType: .blob
        )
        
        let property = INDIProperty(
            operation: .define,
            propertyType: .blob,
            device: "CCD Simulator",
            name: .other("IMAGE_DATA"),
            label: "Image Data",
            format: ".fits",
            values: [value]
        )
        
        #expect(property.propertyType == INDIPropertyType.blob)
        #expect(property.format == ".fits")
        #expect(property.values.count == 1)
        
        if let firstValue = property.values.first {
            if case .blob(let data) = firstValue.value {
                #expect(data == blobData)
            } else {
                Issue.record("Expected blob value")
            }
            #expect(firstValue.format == ".fits")
            #expect(firstValue.size == blobData.count)
        }
        
        // Check XML node
        let elementName = property.xmlNode.name
        #expect(elementName.contains("def"))
        #expect(elementName.contains("BLOB"))
        
        let attrs = property.xmlNode.attributes
        #expect(attrs["format"] == ".fits")
    }
    
    @Test("Create property with minimal parameters")
    func testCreatePropertyMinimal() async throws {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            propertyType: .text
        )
        
        let property = INDIProperty(
            operation: .set,
            propertyType: .text,
            device: "Test Device",
            name: .other("TEST_PROP"),
            values: [value]
        )
        
        #expect(property.operation == INDIPropertyOperation.set)
        #expect(property.device == "Test Device")
        #expect(property.values.count == 1)
        #expect(property.group == nil)
        #expect(property.label == nil)
        #expect(property.permissions == nil)
        #expect(property.state == nil)
        #expect(property.timeout == nil)
        
        // Check XML node has only required attributes
        let attrs = property.xmlNode.attributes
        #expect(attrs["device"] == "Test Device")
        #expect(attrs["name"] == "TEST_PROP")
        #expect(attrs["group"] == nil)
        #expect(attrs["label"] == nil)
    }
    
    // MARK: - getProperties Creation Tests
    
    @Test("Create getProperties programmatically without attributes")
    func testCreateGetPropertiesMinimal() {
        let property = INDIProperty(
            operation: .get,
            device: nil,
            name: nil
        )
        
        #expect(property.operation == .get)
        #expect(property.propertyType == nil)
        #expect(property.device == nil)
        #expect(property.name == nil)
        #expect(property.values.isEmpty)
        #expect(property.xmlNode.name == "getProperties")
        #expect(property.xmlNode.attributes["version"] == "1.7")
    }
    
    @Test("Create getProperties programmatically with device")
    func testCreateGetPropertiesWithDevice() {
        let property = INDIProperty(
            operation: .get,
            device: "Telescope Simulator",
            name: nil
        )
        
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name == nil)
        #expect(property.xmlNode.attributes["device"] == "Telescope Simulator")
    }
    
    @Test("Create getProperties programmatically with name")
    func testCreateGetPropertiesWithName() {
        let property = INDIProperty(
            operation: .get,
            device: nil,
            name: .connection
        )
        
        #expect(property.operation == .get)
        #expect(property.device == nil)
        #expect(property.name?.indiName == "CONNECTION")
        #expect(property.xmlNode.attributes["name"] == "CONNECTION")
    }
    
    @Test("Create getProperties programmatically with device and name")
    func testCreateGetPropertiesWithDeviceAndName() {
        let property = INDIProperty(
            operation: .get,
            device: "Telescope Simulator",
            name: .connection
        )
        
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "CONNECTION")
        #expect(property.xmlNode.attributes["device"] == "Telescope Simulator")
        #expect(property.xmlNode.attributes["name"] == "CONNECTION")
    }
    
    @Test("Create getProperties programmatically with custom version")
    func testCreateGetPropertiesWithCustomVersion() {
        let property = INDIProperty(
            operation: .get,
            device: nil,
            name: nil,
            version: "1.8"
        )
        
        #expect(property.xmlNode.attributes["version"] == "1.8")
    }
}


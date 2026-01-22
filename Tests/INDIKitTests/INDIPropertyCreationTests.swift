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
        
        let property = INDIMessage.defineProperty(INDIDefineProperty(
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
        
        #expect(property.operation == INDIOperation.define)
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
        
        // Check XML serialization
        let xml = try property.toXML()
        #expect(xml.contains("<defTextVector"))
        #expect(xml.contains("device=\"Test Device\""))
        #expect(xml.contains("name=\"DRIVER_INFO\""))
        #expect(xml.contains("group=\"General Info\""))
        #expect(xml.contains("label=\"Driver Info\""))
        #expect(xml.contains("perm=\"ro\""))
        #expect(xml.contains("state=\"Idle\""))
        #expect(xml.contains("timeout=\"60.0\""))
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
        
        let property = INDIMessage.updateProperty(INDIUpdateProperty(
            propertyType: .number,
            device: "Weather Station",
            name: .atmosphere,
            label: "Atmosphere",
            state: .ok,
            values: [value]
        ))
        
        #expect(property.operation == INDIOperation.update)
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
        
        // Check XML serialization
        let xml = try property.toXML()
        #expect(xml.contains("<setNumberVector"))
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
        
        let property = INDIMessage.defineProperty(INDIDefineProperty(
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
        ))
        
        #expect(property.operation == INDIOperation.define)
        #expect(property.propertyType == INDIPropertyType.toggle)
        #expect(property.values.count == 2)
        #expect(property.rule == INDISwitchRule.oneOfMany)
        
        // Check XML serialization
        let xml = try property.toXML()
        #expect(xml.contains("<defSwitchVector"))
        #expect(xml.contains("rule=\"OneOfMany\""))
    }
    
    @Test("Create light property programmatically")
    func testCreateLightProperty() async throws {
        let okValue = INDIValue(
            name: .other("OK"),
            value: .state(.ok),
            label: "OK",
            propertyType: .light
        )
        
        let property = INDIMessage.defineProperty(INDIDefineProperty(
            propertyType: .light,
            device: "Test Device",
            name: .other("STATUS"),
            label: "Status",
            values: [okValue]
        ))
        
        #expect(property.propertyType == INDIPropertyType.light)
        #expect(property.values.count == 1)
        
        if let firstValue = property.values.first {
            if case .state(let state) = firstValue.value {
                #expect(state == .ok)
            } else {
                Issue.record("Expected state value")
            }
        }
        
        // Check XML serialization
        let xml = try property.toXML()
        #expect(xml.contains("<defLightVector"))
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
        
        let property = INDIMessage.defineProperty(INDIDefineProperty(
            propertyType: .blob,
            device: "CCD Simulator",
            name: .other("IMAGE_DATA"),
            label: "Image Data",
            format: ".fits",
            values: [value]
        ))
        
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
        
        // Check XML serialization
        let xml = try property.toXML()
        #expect(xml.contains("<defBLOBVector"))
        #expect(xml.contains("format=\".fits\""))
    }
    
    @Test("Create property with minimal parameters")
    func testCreatePropertyMinimal() async throws {
        let value = INDIValue(
            name: .other("VALUE"),
            value: .text("Test"),
            propertyType: .text
        )
        
        let property = INDIMessage.setProperty(INDISetProperty(
            propertyType: .text,
            device: "Test Device",
            name: .other("TEST_PROP"),
            values: [value]
        ))
        
        #expect(property.operation == INDIOperation.set)
        #expect(property.device == "Test Device")
        #expect(property.values.count == 1)
        #expect(property.group == nil)
        #expect(property.label == nil)
        #expect(property.permissions == nil)
        #expect(property.state == nil)
        #expect(property.timeout == nil)
        
        // Check XML serialization has only required attributes
        let xml = try property.toXML()
        #expect(xml.contains("device=\"Test Device\""))
        #expect(xml.contains("name=\"TEST_PROP\""))
        #expect(!xml.contains("group="))
        #expect(!xml.contains("label="))
    }
    
    // MARK: - getProperties Creation Tests
    
    @Test("Create getProperties programmatically without attributes")
    func testCreateGetPropertiesMinimal() {
        let property = INDIMessage.getProperties(INDIGetProperties(
            device: nil,
            name: nil
        ))
        
        #expect(property.operation == .get)
        #expect(property.propertyType == nil)
        #expect(property.device == nil)
        #expect(property.name == nil)
        #expect(property.values.isEmpty)
        do {
            let xml = try property.toXML()
            #expect(xml.contains("<getProperties"))
            #expect(xml.contains("version='1.7'"))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    @Test("Create getProperties programmatically with device")
    func testCreateGetPropertiesWithDevice() {
        let property = INDIMessage.getProperties(INDIGetProperties(
            device: "Telescope Simulator",
            name: nil
        ))
        
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name == nil)
        do {
            let xml = try property.toXML()
            #expect(xml.contains("device=\"Telescope Simulator\""))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    @Test("Create getProperties programmatically with name")
    func testCreateGetPropertiesWithName() {
        let property = INDIMessage.getProperties(INDIGetProperties(
            device: nil,
            name: .connection
        ))
        
        #expect(property.operation == .get)
        #expect(property.device == nil)
        #expect(property.name?.indiName == "CONNECTION")
        do {
            let xml = try property.toXML()
            #expect(xml.contains("name=\"CONNECTION\""))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    @Test("Create getProperties programmatically with device and name")
    func testCreateGetPropertiesWithDeviceAndName() {
        let property = INDIMessage.getProperties(INDIGetProperties(
            device: "Telescope Simulator",
            name: .connection
        ))
        
        #expect(property.operation == .get)
        #expect(property.device == "Telescope Simulator")
        #expect(property.name?.indiName == "CONNECTION")
        do {
            let xml = try property.toXML()
            #expect(xml.contains("device=\"Telescope Simulator\""))
            #expect(xml.contains("name=\"CONNECTION\""))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    @Test("Create getProperties programmatically with custom version")
    func testCreateGetPropertiesWithCustomVersion() {
        let property = INDIMessage.getProperties(INDIGetProperties(
            device: nil,
            name: nil,
            version: "1.8"
        ))
        
        do {
            let xml = try property.toXML()
            #expect(xml.contains("version='1.8'"))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    // MARK: - enableBLOB Creation Tests
    
    @Test("Create enableBLOB programmatically with also state")
    func testCreateEnableBLOBWithAlso() {
        let property = INDIMessage.enableBlob(INDIEnableBlob(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: .also
        ))
        
        #expect(property.operation == .enableBlob)
        #expect(property.propertyType == nil)
        #expect(property.device == "CCD Simulator")
        #expect(property.name?.indiName == "CCD1")
        #expect(property.blobSendingState == .also)
        #expect(property.values.isEmpty)
        do {
            let xml = try property.toXML()
            #expect(xml.contains("<enableBLOB"))
            #expect(xml.contains("device=\"CCD Simulator\""))
            #expect(xml.contains("name=\"CCD1\""))
        } catch {
            Issue.record("Failed to serialize property: \(error)")
        }
    }
    
    @Test("Create enableBLOB programmatically with raw state")
    func testCreateEnableBLOBWithRaw() {
        let property = INDIMessage.enableBlob(INDIEnableBlob(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: .raw
        ))
        
        #expect(property.operation == INDIOperation.enableBlob)
        #expect(property.blobSendingState == BLOBSendingState.raw)
    }
    
    @Test("Create enableBLOB programmatically with off state")
    func testCreateEnableBLOBWithOff() {
        let property = INDIMessage.enableBlob(INDIEnableBlob(
            device: "CCD Simulator",
            name: .other("CCD1"),
            blobSendingState: .off
        ))
        
        #expect(property.operation == INDIOperation.enableBlob)
        #expect(property.blobSendingState == BLOBSendingState.off)
    }
    
    @Test("Create enableBLOB programmatically without state is nil")
    func testCreateEnableBLOBWithoutState() {
        let property = INDIMessage.enableBlob(INDIEnableBlob(
            device: "CCD Simulator",
            name: .other("CCD1")
        ))
        
        #expect(property.operation == INDIOperation.enableBlob)
        #expect(property.blobSendingState == nil) // Optional, no default
    }
}


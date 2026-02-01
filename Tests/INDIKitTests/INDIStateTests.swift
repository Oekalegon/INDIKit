import Testing
import Foundation
@testable import INDIProtocol
@testable import INDIState

@Suite("INDI State Tests")
struct INDIStateTests {

    // MARK: - NumberValue Attribute Merging Tests

    @Test("NumberValue merging preserves format from existing value")
    func testNumberValueMergingPreservesFormat() {
        let existingValue = NumberValue(
            name: .rightAscension,
            label: "Right Ascension",
            format: "%010.6m",
            min: 0.0,
            max: 24.0,
            step: 0.001,
            unit: "hours",
            numberValue: 12.5
        )

        // New value from update message - only has name and value, no format
        let newValue = NumberValue(
            name: .rightAscension,
            label: nil,
            format: nil,
            min: nil,
            max: nil,
            step: nil,
            unit: nil,
            numberValue: 15.75
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.numberValue == 15.75) // New value
        #expect(mergedValue.format == "%010.6m") // Preserved from existing
        #expect(mergedValue.label == "Right Ascension") // Preserved from existing
        #expect(mergedValue.min == 0.0) // Preserved from existing
        #expect(mergedValue.max == 24.0) // Preserved from existing
        #expect(mergedValue.step == 0.001) // Preserved from existing
        #expect(mergedValue.unit == "hours") // Preserved from existing
    }

    @Test("NumberValue merging uses new attributes when provided")
    func testNumberValueMergingUsesNewAttributes() {
        let existingValue = NumberValue(
            name: .temperature,
            label: "Temperature",
            format: "%.1f",
            min: -20.0,
            max: 40.0,
            step: 0.1,
            unit: "C",
            numberValue: 20.0
        )

        // New value with some attributes provided
        let newValue = NumberValue(
            name: .temperature,
            label: "New Temperature Label",
            format: "%.2f",
            min: nil,
            max: nil,
            step: nil,
            unit: nil,
            numberValue: 25.5
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.numberValue == 25.5) // New value
        #expect(mergedValue.format == "%.2f") // New format used
        #expect(mergedValue.label == "New Temperature Label") // New label used
        #expect(mergedValue.min == -20.0) // Preserved from existing
        #expect(mergedValue.max == 40.0) // Preserved from existing
        #expect(mergedValue.step == 0.1) // Preserved from existing
        #expect(mergedValue.unit == "C") // Preserved from existing
    }

    @Test("NumberValue parsedFormat returns correct INDIFormat")
    func testNumberValueParsedFormat() {
        let value = NumberValue(
            name: .rightAscension,
            label: "Right Ascension",
            format: "%010.6m",
            min: nil,
            max: nil,
            step: nil,
            unit: nil,
            numberValue: 12.5
        )

        #expect(value.parsedFormat != nil)
        #expect(value.parsedFormat?.isSexagesimal == true)
    }

    // MARK: - TextValue Attribute Merging Tests

    @Test("TextValue merging preserves label from existing value")
    func testTextValueMergingPreservesLabel() {
        let existingValue = TextValue(
            name: .other("DRIVER_NAME"),
            label: "Driver Name",
            textValue: "Old Driver"
        )

        let newValue = TextValue(
            name: .other("DRIVER_NAME"),
            label: nil,
            textValue: "New Driver"
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.textValue == "New Driver") // New value
        #expect(mergedValue.label == "Driver Name") // Preserved from existing
    }

    @Test("TextValue merging uses new label when provided")
    func testTextValueMergingUsesNewLabel() {
        let existingValue = TextValue(
            name: .other("DRIVER_NAME"),
            label: "Old Label",
            textValue: "Old Driver"
        )

        let newValue = TextValue(
            name: .other("DRIVER_NAME"),
            label: "New Label",
            textValue: "New Driver"
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.textValue == "New Driver")
        #expect(mergedValue.label == "New Label") // New label used
    }

    // MARK: - SwitchValue Attribute Merging Tests

    @Test("SwitchValue merging preserves label from existing value")
    func testSwitchValueMergingPreservesLabel() {
        let existingValue = SwitchValue(
            name: .connect,
            label: "Connect",
            switchValue: false
        )

        let newValue = SwitchValue(
            name: .connect,
            label: nil,
            switchValue: true
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.switchValue == true) // New value
        #expect(mergedValue.label == "Connect") // Preserved from existing
    }

    // MARK: - LightValue Attribute Merging Tests

    @Test("LightValue merging preserves label from existing value")
    func testLightValueMergingPreservesLabel() {
        let existingValue = LightValue(
            name: .other("GPS_STATUS"),
            label: "GPS Status",
            lightValue: .idle
        )

        let newValue = LightValue(
            name: .other("GPS_STATUS"),
            label: nil,
            lightValue: .ok
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.lightValue == .ok) // New value
        #expect(mergedValue.label == "GPS Status") // Preserved from existing
    }

    // MARK: - BLOBValue Attribute Merging Tests

    @Test("BLOBValue merging preserves attributes from existing value")
    func testBLOBValueMergingPreservesAttributes() {
        let existingValue = BLOBValue(
            name: .other("CCD1"),
            label: "Primary CCD",
            format: ".fits",
            size: 1024,
            compressed: false,
            blobValue: Data("old data".utf8)
        )

        let newValue = BLOBValue(
            name: .other("CCD1"),
            label: nil,
            format: nil,
            size: nil,
            compressed: nil,
            blobValue: Data("new data".utf8)
        )

        let mergedValue = newValue.mergingAttributes(from: existingValue)

        #expect(mergedValue.blobValue == Data("new data".utf8)) // New value
        #expect(mergedValue.label == "Primary CCD") // Preserved from existing
        #expect(mergedValue.format == ".fits") // Preserved from existing
        #expect(mergedValue.size == 1024) // Preserved from existing
        #expect(mergedValue.compressed == false) // Preserved from existing
    }

    // MARK: - INDIDevice Property Update Tests

    @Test("INDIDevice updates property values while preserving attributes")
    func testDevicePropertyUpdatePreservesAttributes() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        // Create initial property with full attributes (simulating define message)
        let initialProperty = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: "Main Control",
            label: "Equatorial Coordinates",
            permissions: .readWrite,
            state: .idle,
            timeout: 60.0,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: "Right Ascension",
                    format: "%010.6m",
                    min: 0.0,
                    max: 24.0,
                    step: 0.001,
                    unit: "hours",
                    numberValue: 12.0
                ),
                NumberValue(
                    name: .declination,
                    label: "Declination",
                    format: "%010.6m",
                    min: -90.0,
                    max: 90.0,
                    step: 0.001,
                    unit: "degrees",
                    numberValue: 45.0
                )
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: initialProperty)

        // Verify initial property was added
        guard let storedProperty = device.getProperty(name: .equatorialCoordinatesJ2000) as? NumberProperty else {
            Issue.record("Property not found after initial update")
            return
        }
        #expect(storedProperty.numberValues.count == 2)
        #expect(storedProperty.numberValues[0].format == "%010.6m")

        // Create update property with only values (simulating update message)
        let updateProperty = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: nil,
            label: nil,
            permissions: nil,
            state: .busy,
            timeout: nil,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: nil,
                    format: nil,
                    min: nil,
                    max: nil,
                    step: nil,
                    unit: nil,
                    numberValue: 14.5
                ),
                NumberValue(
                    name: .declination,
                    label: nil,
                    format: nil,
                    min: nil,
                    max: nil,
                    step: nil,
                    unit: nil,
                    numberValue: 30.0
                )
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: updateProperty)

        // Verify attributes were preserved after update
        guard let updatedProperty = device.getProperty(name: .equatorialCoordinatesJ2000) as? NumberProperty else {
            Issue.record("Property not found after update")
            return
        }

        let raValue = updatedProperty.numberValues.first(where: { $0.name == .rightAscension })
        let decValue = updatedProperty.numberValues.first(where: { $0.name == .declination })

        #expect(raValue != nil)
        #expect(decValue != nil)

        // Check that values were updated
        #expect(raValue?.numberValue == 14.5)
        #expect(decValue?.numberValue == 30.0)

        // Check that attributes were preserved
        #expect(raValue?.format == "%010.6m")
        #expect(raValue?.label == "Right Ascension")
        #expect(raValue?.min == 0.0)
        #expect(raValue?.max == 24.0)
        #expect(raValue?.unit == "hours")

        #expect(decValue?.format == "%010.6m")
        #expect(decValue?.label == "Declination")
        #expect(decValue?.min == -90.0)
        #expect(decValue?.max == 90.0)
        #expect(decValue?.unit == "degrees")
    }

    @Test("INDIDevice creates new property when not existing")
    func testDeviceCreatesNewProperty() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        #expect(device.properties.isEmpty)

        let property = TextProperty(
            name: .other("DRIVER_INFO"),
            group: "General Info",
            label: "Driver Info",
            permissions: .readOnly,
            state: .idle,
            timeout: nil,
            values: [
                TextValue(name: .other("DRIVER_NAME"), label: "Driver Name", textValue: "Test Driver")
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: property)

        #expect(device.properties.count == 1)
        #expect(device.getProperty(name: .other("DRIVER_INFO")) != nil)
    }

    @Test("INDIDevice deletes property by name")
    func testDeviceDeletesProperty() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        let property = TextProperty(
            name: .other("DRIVER_INFO"),
            group: "General Info",
            label: "Driver Info",
            permissions: .readOnly,
            state: .idle,
            timeout: nil,
            values: [
                TextValue(name: .other("DRIVER_NAME"), label: "Driver Name", textValue: "Test Driver")
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: property)
        #expect(device.properties.count == 1)

        device.deleteProperty(name: .other("DRIVER_INFO"))
        #expect(device.properties.isEmpty)
    }

    // MARK: - INDIDevice Connection Status Tests

    @Test("INDIDevice connection status is disconnected without CONNECTION property")
    func testDeviceConnectionStatusWithoutProperty() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        let device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        #expect(device.connectionStatus == .disconnected)
    }

    @Test("INDIDevice connection status reflects CONNECTION property")
    func testDeviceConnectionStatusReflectsProperty() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        // Add CONNECTION property with CONNECT = true
        let connectionProperty = SwitchProperty(
            name: .connection,
            group: "Main Control",
            label: "Connection",
            permissions: .readWrite,
            state: .ok,
            timeout: 60.0,
            rule: .oneOfMany,
            values: [
                SwitchValue(name: .connect, label: "Connect", switchValue: true),
                SwitchValue(name: .disconnect, label: "Disconnect", switchValue: false)
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: connectionProperty)

        #expect(device.connectionStatus == .connected)
    }

    @Test("INDIDevice connection status shows connecting when target differs from current")
    func testDeviceConnectionStatusConnecting() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        // First add CONNECTION property with CONNECT = false (disconnected)
        let connectionProperty = SwitchProperty(
            name: .connection,
            group: "Main Control",
            label: "Connection",
            permissions: .readWrite,
            state: .busy,
            timeout: 60.0,
            rule: .oneOfMany,
            values: [
                SwitchValue(name: .connect, label: "Connect", switchValue: false),
                SwitchValue(name: .disconnect, label: "Disconnect", switchValue: true)
            ],
            timeStamp: Date()
        )

        // Add the property with current values (not target)
        device.updateProperty(property: connectionProperty, isTarget: false)

        // Now create a target update with CONNECT = true
        let targetProperty = SwitchProperty(
            name: .connection,
            group: nil,
            label: nil,
            permissions: nil,
            state: nil,
            timeout: nil,
            rule: nil,
            values: [
                SwitchValue(name: .connect, label: "Connect", switchValue: true),
                SwitchValue(name: .disconnect, label: "Disconnect", switchValue: false)
            ],
            timeStamp: Date()
        )

        // Update with target values
        device.updateProperty(property: targetProperty, isTarget: true)

        // Current is false, target is true -> connecting
        #expect(device.connectionStatus == .connecting)
    }

    // MARK: - INDIDevice Target Value Tests

    @Test("INDIDevice updates target values correctly")
    func testDeviceUpdatesTargetValues() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: "Test Telescope")

        // Create initial property
        let initialProperty = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: "Main Control",
            label: "Equatorial Coordinates",
            permissions: .readWrite,
            state: .idle,
            timeout: 60.0,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: "Right Ascension",
                    format: "%010.6m",
                    min: 0.0,
                    max: 24.0,
                    step: 0.001,
                    unit: "hours",
                    numberValue: 12.0
                )
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: initialProperty)

        // Create target update
        let targetProperty = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: nil,
            label: nil,
            permissions: nil,
            state: nil,
            timeout: nil,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: nil,
                    format: nil,
                    min: nil,
                    max: nil,
                    step: nil,
                    unit: nil,
                    numberValue: 18.0
                )
            ],
            timeStamp: Date()
        )

        device.updateProperty(property: targetProperty, isTarget: true)

        guard let updatedProperty = device.getProperty(name: .equatorialCoordinatesJ2000) as? NumberProperty else {
            Issue.record("Property not found")
            return
        }

        // Current values should be unchanged
        #expect(updatedProperty.numberValues.first?.numberValue == 12.0)

        // Target values should be set with preserved attributes
        #expect(updatedProperty.targetNumberValues != nil)
        #expect(updatedProperty.targetNumberValues?.first?.numberValue == 18.0)
        #expect(updatedProperty.targetNumberValues?.first?.format == "%010.6m") // Preserved
        #expect(updatedProperty.targetNumberValues?.first?.label == "Right Ascension") // Preserved
    }

    // MARK: - SwitchProperty Rule Tests

    @Test("SwitchProperty setTargetSwitchValue respects OneOfMany rule")
    func testSwitchPropertyOneOfManyRule() throws {
        var property = SwitchProperty(
            name: .connection,
            group: "Main Control",
            label: "Connection",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            rule: .oneOfMany,
            values: [
                SwitchValue(name: .connect, label: "Connect", switchValue: false),
                SwitchValue(name: .disconnect, label: "Disconnect", switchValue: true)
            ],
            timeStamp: Date()
        )

        // Setting CONNECT to true should set DISCONNECT to false
        try property.setTargetSwitchValue(name: .connect, true)

        let targetConnect = property.targetSwitchValue(name: .connect)
        let targetDisconnect = property.targetSwitchValue(name: .disconnect)

        #expect(targetConnect == true)
        #expect(targetDisconnect == false)
    }

    @Test("SwitchProperty setTargetSwitchValue throws for OneOfMany when setting false with multiple values")
    func testSwitchPropertyOneOfManyThrowsOnFalse() throws {
        var property = SwitchProperty(
            name: .other("OPTIONS"),
            group: "Options",
            label: "Options",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            rule: .oneOfMany,
            values: [
                SwitchValue(name: .other("OPT1"), label: "Option 1", switchValue: true),
                SwitchValue(name: .other("OPT2"), label: "Option 2", switchValue: false),
                SwitchValue(name: .other("OPT3"), label: "Option 3", switchValue: false)
            ],
            timeStamp: Date()
        )

        // Setting OPT1 to false should throw because we can't determine which other value should be true
        #expect(throws: INDISwitchRuleErrors.self) {
            try property.setTargetSwitchValue(name: .other("OPT1"), false)
        }
    }

    @Test("SwitchProperty setTargetSwitchValue allows false with two values for OneOfMany")
    func testSwitchPropertyOneOfManyAllowsFalseWithTwoValues() throws {
        var property = SwitchProperty(
            name: .connection,
            group: "Main Control",
            label: "Connection",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            rule: .oneOfMany,
            values: [
                SwitchValue(name: .connect, label: "Connect", switchValue: true),
                SwitchValue(name: .disconnect, label: "Disconnect", switchValue: false)
            ],
            timeStamp: Date()
        )

        // With only two values, setting one to false should set the other to true
        try property.setTargetSwitchValue(name: .connect, false)

        let targetConnect = property.targetSwitchValue(name: .connect)
        let targetDisconnect = property.targetSwitchValue(name: .disconnect)

        #expect(targetConnect == false)
        #expect(targetDisconnect == true)
    }

    @Test("SwitchProperty setTargetSwitchValues throws for AtMostOne with multiple true values")
    func testSwitchPropertyAtMostOneThrowsOnMultipleTrue() throws {
        var property = SwitchProperty(
            name: .other("OPTIONS"),
            group: "Options",
            label: "Options",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            rule: .atMostOne,
            values: [
                SwitchValue(name: .other("OPT1"), label: "Option 1", switchValue: false),
                SwitchValue(name: .other("OPT2"), label: "Option 2", switchValue: false)
            ],
            timeStamp: Date()
        )

        #expect(throws: INDISwitchRuleErrors.self) {
            try property.setTargetSwitchValues([
                (name: .other("OPT1"), booleanValue: true),
                (name: .other("OPT2"), booleanValue: true)
            ])
        }
    }

    // MARK: - NumberProperty Target Value Tests

    @Test("NumberProperty setTargetNumberValues updates target values")
    func testNumberPropertySetTargetValues() throws {
        var property = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: "Main Control",
            label: "Equatorial Coordinates",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: "Right Ascension",
                    format: "%010.6m",
                    min: 0.0,
                    max: 24.0,
                    step: 0.001,
                    unit: "hours",
                    numberValue: 12.0
                ),
                NumberValue(
                    name: .declination,
                    label: "Declination",
                    format: "%010.6m",
                    min: -90.0,
                    max: 90.0,
                    step: 0.001,
                    unit: "degrees",
                    numberValue: 45.0
                )
            ],
            timeStamp: Date()
        )

        try property.setTargetNumberValues([
            (name: .rightAscension, numberValue: 18.5),
            (name: .declination, numberValue: -30.0)
        ])

        #expect(property.targetNumberValues != nil)

        let targetRA = property.targetNumberValues?.first(where: { $0.name == .rightAscension })
        let targetDec = property.targetNumberValues?.first(where: { $0.name == .declination })

        #expect(targetRA?.numberValue == 18.5)
        #expect(targetDec?.numberValue == -30.0)

        // Original values should be unchanged
        #expect(property.numberValues.first(where: { $0.name == .rightAscension })?.numberValue == 12.0)
        #expect(property.numberValues.first(where: { $0.name == .declination })?.numberValue == 45.0)
    }

    @Test("NumberProperty setTargetNumberValue throws for non-existent value")
    func testNumberPropertySetTargetValueThrowsForNonExistent() throws {
        var property = NumberProperty(
            name: .equatorialCoordinatesJ2000,
            group: "Main Control",
            label: "Equatorial Coordinates",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            values: [
                NumberValue(
                    name: .rightAscension,
                    label: "Right Ascension",
                    format: nil,
                    min: nil,
                    max: nil,
                    step: nil,
                    unit: nil,
                    numberValue: 12.0
                )
            ],
            timeStamp: Date()
        )

        #expect(throws: INDIPropertyErrors.self) {
            try property.setTargetNumberValue(name: .other("NON_EXISTENT"), 10.0)
        }
    }

    // MARK: - TextProperty Target Value Tests

    @Test("TextProperty setTargetTextValues updates target values")
    func testTextPropertySetTargetValues() throws {
        var property = TextProperty(
            name: .devicePort,
            group: "Options",
            label: "Device Port",
            permissions: .readWrite,
            state: .idle,
            timeout: nil,
            values: [
                TextValue(name: .port, label: "Port", textValue: "/dev/ttyUSB0")
            ],
            timeStamp: Date()
        )

        try property.setTargetTextValue(name: .port, "/dev/ttyUSB1")

        #expect(property.targetTextValues != nil)
        #expect(property.targetTextValues?.first?.textValue == "/dev/ttyUSB1")

        // Original value should be unchanged
        #expect(property.textValues.first?.textValue == "/dev/ttyUSB0")
    }
}

@Suite("INDI State Registry Tests")
struct INDIStateRegistryTests {

    @Test("INDIStateRegistry processes defineProperty message")
    func testRegistryProcessesDefineProperty() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        let defineProperty = INDIDefineProperty(
            propertyType: .text,
            device: "Telescope Simulator",
            name: .other("DRIVER_INFO"),
            group: "General Info",
            label: "Driver Info",
            permissions: .readOnly,
            state: .idle,
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("Telescope Simulator"),
                    label: "Driver Name",
                    propertyType: .text
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty))

        let devices = await registry.devices
        #expect(devices.count == 1)
        #expect(devices["Telescope Simulator"] != nil)

        let device = devices["Telescope Simulator"]
        #expect(device?.properties.count == 1)

        let property = device?.getProperty(name: .other("DRIVER_INFO"))
        #expect(property != nil)
        #expect(property?.type == .text)
    }

    @Test("INDIStateRegistry processes updateProperty message preserving attributes")
    func testRegistryProcessesUpdatePropertyPreservingAttributes() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        // First, define a property with full attributes
        let defineProperty = INDIDefineProperty(
            propertyType: .number,
            device: "Telescope Simulator",
            name: .equatorialCoordinatesJ2000,
            group: "Main Control",
            label: "Equatorial Coordinates",
            permissions: .readWrite,
            state: .idle,
            timeout: 60.0,
            values: [
                INDIValue(
                    name: .rightAscension,
                    value: .number(12.0),
                    label: "Right Ascension",
                    format: "%010.6m",
                    min: 0.0,
                    max: 24.0,
                    step: 0.001,
                    unit: "hours",
                    propertyType: .number
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty))

        // Now send an update with only the value
        let updateProperty = INDIUpdateProperty(
            propertyType: .number,
            device: "Telescope Simulator",
            name: .equatorialCoordinatesJ2000,
            state: .busy,
            values: [
                INDIValue(
                    name: .rightAscension,
                    value: .number(15.5),
                    propertyType: .number
                )
            ]
        )

        await registry.processMessage(.updateProperty(updateProperty))

        let devices = await registry.devices
        let device = devices["Telescope Simulator"]
        guard let property = device?.getProperty(name: .equatorialCoordinatesJ2000) as? NumberProperty else {
            Issue.record("Property not found")
            return
        }

        let raValue = property.numberValues.first(where: { $0.name == .rightAscension })

        // Value should be updated
        #expect(raValue?.numberValue == 15.5)

        // Attributes should be preserved from define message
        #expect(raValue?.format == "%010.6m")
        #expect(raValue?.label == "Right Ascension")
        #expect(raValue?.min == 0.0)
        #expect(raValue?.max == 24.0)
        #expect(raValue?.step == 0.001)
        #expect(raValue?.unit == "hours")
    }

    @Test("INDIStateRegistry invokes device update callback")
    func testRegistryInvokesDeviceUpdateCallback() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        final class CallbackState: @unchecked Sendable {
            var invoked = false
            var deviceName: String?
        }
        let state = CallbackState()

        await registry.setOnDeviceUpdate { deviceName, _ in
            state.invoked = true
            state.deviceName = deviceName
        }

        let defineProperty = INDIDefineProperty(
            propertyType: .text,
            device: "Telescope Simulator",
            name: .other("DRIVER_INFO"),
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("Telescope"),
                    propertyType: .text
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty))

        #expect(state.invoked == true)
        #expect(state.deviceName == "Telescope Simulator")
    }

    @Test("INDIStateRegistry invokes property update callback")
    func testRegistryInvokesPropertyUpdateCallback() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        final class CallbackState: @unchecked Sendable {
            var invoked = false
            var deviceName: String?
            var propertyName: INDIPropertyName?
        }
        let state = CallbackState()

        await registry.setOnPropertyUpdate { deviceName, property in
            state.invoked = true
            state.deviceName = deviceName
            state.propertyName = property.name
        }

        let defineProperty = INDIDefineProperty(
            propertyType: .text,
            device: "Telescope Simulator",
            name: .other("DRIVER_INFO"),
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("Telescope"),
                    propertyType: .text
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty))

        #expect(state.invoked == true)
        #expect(state.deviceName == "Telescope Simulator")
        #expect(state.propertyName == .other("DRIVER_INFO"))
    }

    @Test("INDIStateRegistry handles multiple devices")
    func testRegistryHandlesMultipleDevices() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        let defineProperty1 = INDIDefineProperty(
            propertyType: .text,
            device: "Telescope Simulator",
            name: .other("DRIVER_INFO"),
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("Telescope"),
                    propertyType: .text
                )
            ]
        )

        let defineProperty2 = INDIDefineProperty(
            propertyType: .text,
            device: "CCD Simulator",
            name: .other("DRIVER_INFO"),
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("CCD"),
                    propertyType: .text
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty1))
        await registry.processMessage(.defineProperty(defineProperty2))

        let devices = await registry.devices
        #expect(devices.count == 2)
        #expect(devices["Telescope Simulator"] != nil)
        #expect(devices["CCD Simulator"] != nil)
    }

    @Test("INDIStateRegistry updates existing device properties")
    func testRegistryUpdatesExistingDeviceProperties() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)

        // Define first property
        let defineProperty1 = INDIDefineProperty(
            propertyType: .text,
            device: "Telescope Simulator",
            name: .other("DRIVER_INFO"),
            values: [
                INDIValue(
                    name: .other("DRIVER_NAME"),
                    value: .text("Telescope"),
                    propertyType: .text
                )
            ]
        )

        // Define second property for same device
        let defineProperty2 = INDIDefineProperty(
            propertyType: .toggle,
            device: "Telescope Simulator",
            name: .connection,
            values: [
                INDIValue(
                    name: .connect,
                    value: .boolean(false),
                    propertyType: .toggle
                ),
                INDIValue(
                    name: .disconnect,
                    value: .boolean(true),
                    propertyType: .toggle
                )
            ]
        )

        await registry.processMessage(.defineProperty(defineProperty1))
        await registry.processMessage(.defineProperty(defineProperty2))

        let devices = await registry.devices
        #expect(devices.count == 1)

        let device = devices["Telescope Simulator"]
        #expect(device?.properties.count == 2)
        #expect(device?.getProperty(name: .other("DRIVER_INFO")) != nil)
        #expect(device?.getProperty(name: .connection) != nil)
    }
}

import Testing
import Foundation
@testable import INDIProtocol
@testable import INDIState

@Suite("INDI Device Type Detection Tests")
struct INDIDeviceTypeDetectionTests {
    
    // MARK: - Helper Functions
    
    /// Create a test device with the given properties
    private func createTestDevice(
        name: String,
        properties: [any INDIProperty]
    ) -> INDIDevice {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let registry = INDIStateRegistry(endpoint: endpoint)
        var device = INDIDevice(stateRegistry: registry, name: name, properties: [])
        for property in properties {
            device.updateProperty(property: property, isTarget: false)
        }
        return device
    }
    
    /// Get an appropriate value name for a property (for testing purposes)
    private func getValueName(for propertyName: INDIPropertyName) -> INDIPropertyValueName {
        // Use expected value names if available, otherwise use a generic one
        if let expectedNames = INDIPropertyValueName.other("").expectedValueNames(for: propertyName),
           let firstValue = expectedNames.first {
            return firstValue
        }
        
        // Fallback to property-specific value names
        switch propertyName {
        case .filterSlot:
            return .filterSlot
        case .filterName:
            return .filterName
        case .equatorialCoordinatesJ2000, .equatorialCoordinatesEpoch, .targetEquatorialCoordinatesEpoch:
            return .rightAscension
        case .horizontalCoordinates:
            return .azimuth
        case .focusSpeed:
            return .other("FOCUS_SPEED_VALUE")
        case .absoluteFocusPosition:
            return .other("FOCUS_ABSOLUTE_POSITION")
        case .domeSpeed:
            return .other("DOME_SPEED_VALUE")
        case .ccdExposureTime:
            return .other("CCD_EXPOSURE_VALUE")
        case .ccdTemperature:
            return .other("CCD_TEMPERATURE_VALUE")
        case .ccdFrame:
            return .other("X")
        default:
            return .other("VALUE")
        }
    }
    
    /// Create a number property for testing
    private func createNumberProperty(
        name: INDIPropertyName,
        value: Double = 0.0
    ) -> NumberProperty {
        let valueName = getValueName(for: name)
        let indiValue = INDIValue(
            name: valueName,
            value: .number(value),
            propertyType: .number
        )
        let defineProperty = INDIDefineProperty(
            propertyType: .number,
            device: "Test Device",
            name: name,
            values: [indiValue]
        )
        return NumberProperty(
            name: name,
            group: defineProperty.group,
            label: defineProperty.label,
            permissions: defineProperty.permissions,
            state: defineProperty.state,
            timeout: defineProperty.timeout,
            values: [NumberValue(
                name: valueName,
                label: nil,
                format: nil,
                min: nil,
                max: nil,
                step: nil,
                unit: nil,
                numberValue: value
            )],
            targetValues: nil,
            timeStamp: Date(),
            targetTimeStamp: nil
        )
    }
    
    /// Get an appropriate switch value name for a property (for testing purposes)
    private func getSwitchValueName(for propertyName: INDIPropertyName) -> INDIPropertyValueName {
        // Use expected value names if available
        if let expectedNames = INDIPropertyValueName.other("").expectedValueNames(for: propertyName),
           let firstValue = expectedNames.first {
            return firstValue
        }
        
        // Fallback to property-specific value names
        switch propertyName {
        case .connection:
            return .connect
        case .telescopePark, .domePark:
            return .park
        case .focusMotion:
            return .other("FOCUS_INWARD")
        case .domeShutter:
            return .other("SHUTTER_OPEN")
        default:
            return .other("ON")
        }
    }
    
    /// Create a switch property for testing
    private func createSwitchProperty(
        name: INDIPropertyName,
        value: Bool = false
    ) -> SwitchProperty {
        let valueName = getSwitchValueName(for: name)
        let indiValue = INDIValue(
            name: valueName,
            value: .boolean(value),
            propertyType: .toggle
        )
        let defineProperty = INDIDefineProperty(
            propertyType: .toggle,
            device: "Test Device",
            name: name,
            values: [indiValue]
        )
        return SwitchProperty(
            name: name,
            group: defineProperty.group,
            label: defineProperty.label,
            permissions: defineProperty.permissions,
            state: defineProperty.state,
            timeout: defineProperty.timeout,
            rule: defineProperty.rule,
            values: [SwitchValue(
                name: valueName,
                label: nil,
                switchValue: value
            )],
            targetValues: nil,
            timeStamp: Date(),
            targetTimeStamp: nil
        )
    }
    
    // MARK: - Property Name to Device Type Mapping Tests
    
    @Test("Telescope properties map to telescope device type")
    func testTelescopePropertiesMapping() {
        #expect(INDIPropertyName.equatorialCoordinatesJ2000.associatedDeviceTypes() == [INDIDeviceType.telescope])
        #expect(INDIPropertyName.telescopePark.associatedDeviceTypes() == [INDIDeviceType.telescope])
        #expect(INDIPropertyName.telescopeTrackRate.associatedDeviceTypes() == [INDIDeviceType.telescope])
        #expect(INDIPropertyName.horizontalCoordinates.associatedDeviceTypes() == [INDIDeviceType.telescope])
    }
    
    @Test("Camera properties map to camera device type")
    func testCameraPropertiesMapping() {
        #expect(INDIPropertyName.ccdExposureTime.associatedDeviceTypes() == [INDIDeviceType.camera])
        #expect(INDIPropertyName.ccdTemperature.associatedDeviceTypes() == [INDIDeviceType.camera])
        #expect(INDIPropertyName.ccdFrame.associatedDeviceTypes() == [INDIDeviceType.camera])
        #expect(INDIPropertyName.ccdVideoStream.associatedDeviceTypes() == [INDIDeviceType.camera])
    }
    
    @Test("Focuser properties map to focuser device type")
    func testFocuserPropertiesMapping() {
        #expect(INDIPropertyName.focusSpeed.associatedDeviceTypes() == [INDIDeviceType.focuser])
        #expect(INDIPropertyName.focusMotion.associatedDeviceTypes() == [INDIDeviceType.focuser])
        #expect(INDIPropertyName.absoluteFocusPosition.associatedDeviceTypes() == [INDIDeviceType.focuser])
    }
    
    @Test("Filter wheel properties map to filterWheel device type")
    func testFilterWheelPropertiesMapping() {
        #expect(INDIPropertyName.filterSlot.associatedDeviceTypes() == [INDIDeviceType.filterWheel])
        #expect(INDIPropertyName.filterName.associatedDeviceTypes() == [INDIDeviceType.filterWheel])
    }
    
    @Test("Dome properties map to dome device type")
    func testDomePropertiesMapping() {
        #expect(INDIPropertyName.domeSpeed.associatedDeviceTypes() == [INDIDeviceType.dome])
        #expect(INDIPropertyName.domeShutter.associatedDeviceTypes() == [INDIDeviceType.dome])
        #expect(INDIPropertyName.domePark.associatedDeviceTypes() == [INDIDeviceType.dome])
    }
    
    @Test("General properties map to all device types")
    func testGeneralPropertiesMapping() {
        let allTypes = INDIDeviceType.allCases.filter { $0 != .unknown }
        let connectionTypes = INDIPropertyName.connection.associatedDeviceTypes()
        #expect(Set(connectionTypes) == Set(allTypes))
        
        let devicePortTypes = INDIPropertyName.devicePort.associatedDeviceTypes()
        #expect(Set(devicePortTypes) == Set(allTypes))
    }
    
    @Test("Unknown properties return empty array")
    func testUnknownPropertiesMapping() {
        let unknownProperty = INDIPropertyName.other("UNKNOWN_PROPERTY")
        #expect(unknownProperty.associatedDeviceTypes().isEmpty)
    }
    
    // MARK: - Device Type Prediction Tests
    
    @Test("Device with telescope properties predicts telescope type")
    func testTelescopeDevicePrediction() {
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .equatorialCoordinatesJ2000),
            createNumberProperty(name: .telescopeTrackRate),
            createSwitchProperty(name: .telescopePark)
        ]
        
        let device = createTestDevice(name: "Telescope", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.telescope)
    }
    
    @Test("Device with camera properties predicts camera type")
    func testCameraDevicePrediction() {
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .ccdExposureTime),
            createNumberProperty(name: .ccdTemperature),
            createNumberProperty(name: .ccdFrame)
        ]
        
        let device = createTestDevice(name: "Camera", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.camera)
    }
    
    @Test("Device with focuser properties predicts focuser type")
    func testFocuserDevicePrediction() {
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .focusSpeed),
            createNumberProperty(name: .absoluteFocusPosition),
            createSwitchProperty(name: .focusMotion)
        ]
        
        let device = createTestDevice(name: "Focuser", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.focuser)
    }
    
    @Test("Device with filter wheel properties predicts filterWheel type")
    func testFilterWheelDevicePrediction() {
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .filterSlot),
            createNumberProperty(name: .filterName)
        ]
        
        let device = createTestDevice(name: "Filter Wheel", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.filterWheel)
    }
    
    @Test("Device with dome properties predicts dome type")
    func testDomeDevicePrediction() {
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .domeSpeed),
            createSwitchProperty(name: .domeShutter),
            createSwitchProperty(name: .domePark)
        ]
        
        let device = createTestDevice(name: "Dome", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.dome)
    }
    
    @Test("Device with only general properties predicts unknown type")
    func testUnknownDevicePrediction() {
        let properties: [any INDIProperty] = [
            createSwitchProperty(name: .connection),
            createNumberProperty(name: .devicePort)
        ]
        
        let device = createTestDevice(name: "Generic Device", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.unknown)
    }
    
    @Test("Device with no properties predicts unknown type")
    func testEmptyDevicePrediction() {
        let device = createTestDevice(name: "Empty Device", properties: [])
        #expect(device.predictedDeviceType() == INDIDeviceType.unknown)
    }
    
    @Test("Device with mixed properties predicts dominant type")
    func testMixedPropertiesPrediction() {
        // More camera properties than telescope
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .ccdExposureTime),
            createNumberProperty(name: .ccdTemperature),
            createNumberProperty(name: .ccdFrame),
            createNumberProperty(name: .equatorialCoordinatesJ2000) // One telescope property
        ]
        
        let device = createTestDevice(name: "Mixed Device", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.camera)
    }
    
    @Test("Device with tied counts uses priority order")
    func testTiedCountsPriority() {
        // Equal number of telescope and camera properties
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .equatorialCoordinatesJ2000), // Telescope
            createNumberProperty(name: .ccdExposureTime) // Camera
        ]
        
        let device = createTestDevice(name: "Tied Device", properties: properties)
        // Telescope should win due to priority order
        #expect(device.predictedDeviceType() == INDIDeviceType.telescope)
    }
    
    @Test("Device with multiple property types counts correctly")
    func testMultiplePropertyTypesCount() {
        // 3 telescope, 2 camera, 1 focuser
        let properties: [any INDIProperty] = [
            createNumberProperty(name: .equatorialCoordinatesJ2000),
            createNumberProperty(name: .telescopeTrackRate),
            createSwitchProperty(name: .telescopePark),
            createNumberProperty(name: .ccdExposureTime),
            createNumberProperty(name: .ccdTemperature),
            createNumberProperty(name: .focusSpeed)
        ]
        
        let device = createTestDevice(name: "Multi-Type Device", properties: properties)
        #expect(device.predictedDeviceType() == INDIDeviceType.telescope)
    }
    
    @Test("Device type display names are correct")
    func testDeviceTypeDisplayNames() {
        #expect(INDIDeviceType.telescope.displayName == "Telescope/Mount")
        #expect(INDIDeviceType.camera.displayName == "Camera/CCD")
        #expect(INDIDeviceType.focuser.displayName == "Focuser")
        #expect(INDIDeviceType.filterWheel.displayName == "Filter Wheel")
        #expect(INDIDeviceType.dome.displayName == "Dome")
        #expect(INDIDeviceType.unknown.displayName == "Unknown")
    }
}


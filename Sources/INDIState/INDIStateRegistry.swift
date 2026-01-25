import Foundation
import INDIProtocol

public actor INDIServerStateRegistry {

    private static let timerInterval: TimeInterval = 60

    public var server: INDIServer

    public private(set) var connected: Bool = false

    public var devices: [String: INDIDevice] = [:]

    private var pings: [String: (send: Date, recievedReply: Date?)] = [:]

    public var lastPing: (send: Date, recievedReply: Date?)? {
        return pings.values.max(by: { $0.send < $1.send })
    }

    private var timer: Timer?

    public init(endpoint: INDIServerEndpoint) {
        self.server = INDIServer(endpoint: endpoint)
    }

    public func connect() async throws {
        try await server.connect()
        connected = true
        startPingTimer(interval: Self.timerInterval)

        let messageStream = try await server.messages()
        do {
            for try await message in messageStream {
                handleMessage(message: message)
            }
            // Stream finished normally (connection closed)
            connected = false
        } catch {
            // Stream finished with error (connection lost)
            connected = false
            throw error
        }
    }

    public func disconnect() async {
        await server.disconnect()
        connected = false
        timer?.invalidate()
        timer = nil
    }

    public func startPingTimer(interval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task {
                guard let self = self else { return }
                let lastPing = await self.lastPing
                guard let lastPing = lastPing, lastPing.recievedReply == nil else {
                    // No reply to the last ping has been received yet - so we are probably not connected to the server
                    // anymore. We should disconnect.
                    await self.disconnect()
                    return
                }
                do {
                    try await self.ping()
                } catch {
                    print("Error pinging server: \(error)")
                }
            }
        }
    }

    public func ping() async throws {
        let pingMessage = INDIPing(uid: UUID().uuidString)
        try await server.send(.ping(pingMessage))
        pings[pingMessage.uid!] = (send: Date(), recievedReply: nil)
    }

    public func registerDevice(device: INDIDevice) {
        devices[device.name] = device
    }

    private func handleMessage(message: INDIMessage) {
        switch message {
        case .updateProperty(let updateProperty):
            handleStateProperty(updateProperty)
        case .defineProperty(let defineProperty):
            handleStateProperty(defineProperty)
        case .deleteProperty(let deleteProperty):
            handleDeleteProperty(deleteProperty)
        case .pingReply(let pingReply):
            handlePingReply(pingReply)
        default:
            // The others are messages sent (not received) by the client
            break
        }
    }

    private func createDevice(deviceName: String) -> INDIDevice {
        return INDIDevice(stateRegistry: self, name: deviceName)
    }

    private func handleStateProperty(_ stateProperty: INDIStateProperty) {
        var device = devices[stateProperty.device] 
        if device == nil {
            device = createDevice(deviceName: stateProperty.device)
        }
        guard var device = device else { return }
        let updatedProperty = createINDIProperty(stateProperty: stateProperty)
        device.updateProperty(property: updatedProperty)
        devices[stateProperty.device] = device
    }

    private func handleDeleteProperty(_ deleteProperty: INDIDeleteProperty) {
        if let deviceName = deleteProperty.device {
            // If the device name is present
            if let propertyName = deleteProperty.name {
                // If the property name is present
                if var device = devices[deviceName] {
                    device.deleteProperty(name: propertyName)
                    devices[deviceName] = device
                }
            } else {
                // If the property name is not present, we need to delete the device
                devices.removeValue(forKey: deviceName)
            }
        } else {
            // If the device name is not present, we need to delete all devices
            devices.removeAll()
        }
    }

    private func handlePingReply(_ pingReply: INDIPingReply) {
        guard let uid = pingReply.uid else {
            return
        }
        pings[uid]?.recievedReply = Date()
    }

    private func createINDIProperty(stateProperty: INDIStateProperty) -> INDIProperty {
        switch stateProperty.propertyType {
        case .text:
            return TextProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .text(let stringValue) = value.value else {
                        return nil
                    }
                    return TextValue(name: value.name, label: value.label, textValue: stringValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .number:
            return NumberProperty(
                name: stateProperty.name,
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .number(let numberValue) = value.value else {
                        return nil
                    }
                    return NumberValue(
                        name: value.name,
                        label: value.label,
                        format: value.format,
                        min: value.min,
                        max: value.max,
                        step: value.step,
                        unit: value.unit,
                        numberValue: numberValue
                    )
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .toggle:
            return SwitchProperty(
                name: stateProperty.name,
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                rule: stateProperty.rule, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .boolean(let booleanValue) = value.value else {
                        return nil
                    }
                    return SwitchValue(name: value.name, label: value.label, switchValue: booleanValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        case .light:
            return LightProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .state(let stateValue) = value.value else {
                        return nil
                    }
                    return LightValue(name: value.name, label: value.label, lightValue: stateValue)
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )   
        case .blob:
            return BLOBProperty(
                name: stateProperty.name, 
                group: stateProperty.group, 
                label: stateProperty.label, 
                permissions: stateProperty.permissions, 
                state: stateProperty.state, 
                timeout: stateProperty.timeout, 
                values: stateProperty.values.compactMap { (value: INDIValue) -> (any PropertyValue)? in
                    guard case .blob(let blobValue) = value.value else {
                        return nil
                    }
                    return BLOBValue(
                        name: value.name,
                        label: value.label,
                        format: value.format,
                        size: value.size,
                        compressed: value.compressed,
                        blobValue: blobValue
                    )
                }, 
                timeStamp: stateProperty.timeStamp ?? Date()
            )
        }
    }

    func createAndSendSetPropertyMessage(device: INDIDevice, property: INDIProperty) async throws {
        let setPropertyMessage = INDISetProperty(
            propertyType: property.type, 
            device: device.name, 
            name: property.name, 
            values: property.values.map { $0.toINDIValue(type: property.type) }
        )
        try await server.send(.setProperty(setPropertyMessage))
    }
}

private extension PropertyValue {
    func toINDIValue(type: INDIPropertyType) -> INDIValue {
        switch type {
        case .text:
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                propertyType: .text
            )
        case .number:
            let numberValue = self as? NumberValue
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                format: numberValue?.format,
                min: numberValue?.min,
                max: numberValue?.max,
                step: numberValue?.step,
                unit: numberValue?.unit,
                propertyType: .number
            )
        case .toggle:
            return INDIValue(
                name: name,
                value: self.value,
                label: label,
                propertyType: .toggle
            )
        case .light:
            return INDIValue(
                name: name,
                value: self.value, 
                label: label,
                propertyType: .light
            )
        case .blob:
            let blobValue = self as? BLOBValue
            return INDIValue(
                name: name, 
                value: self.value, 
                label: label, 
                format: blobValue?.format,
                size: blobValue?.size,
                compressed: blobValue?.compressed,
                propertyType: .blob
            )
        }
    }
}

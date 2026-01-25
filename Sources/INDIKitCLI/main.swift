import Foundation
import INDIProtocol
import INDIState

@main
struct INDIKitCLI {
    static func main() async {
        let arguments = CommandLine.arguments

        guard let (host, port, testState) = parseArguments(arguments) else {
            exit(1)
        }

        let endpoint = INDIServerEndpoint(host: host, port: port)
        let server = INDIServer(endpoint: endpoint)

        print("Connecting to INDI server at \(host):\(port)...")
        if testState {
            print("INDIState testing mode enabled - will log device and property updates")
        }

        do {
            _ = try await server.connect()
            print("Connected! Sending INDI handshake and listening for messages...")
            print("Type additional messages to send (or press Ctrl+C to disconnect):\n")

            sendHandshake(server: server)
            setupStdinReader(server: server)
            if !testState {
                setupRawDataPrinter(server: server)
            }
            
            // Set up INDIState registry if test mode is enabled
            if testState {
                await setupStateRegistry(endpoint: endpoint)
            }
            
            let propertyStream = try await server.messages()
            for try await property in propertyStream {
                // Only print protocol messages if not in test-state mode
                if !testState {
                    print("Parsed INDI Message:")
                    printMessage(property)
                }
            }

            print("\nConnection closed.")
        } catch {
            print("\nError connecting to INDI server: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    // MARK: - Setup Helpers
    
    private static func parseArguments(_ arguments: [String]) -> (host: String, port: UInt16, testState: Bool)? {
        var host: String?
        var port: UInt16?
        var testState = false
        
        var i = 1
        while i < arguments.count {
            let arg = arguments[i]
            if arg == "--test-state" || arg == "-t" {
                testState = true
                i += 1
            } else if host == nil {
                host = arg
                i += 1
            } else if port == nil {
                if let parsedPort = UInt16(arg) {
                    port = parsedPort
                    i += 1
                } else {
                    print("Error: Invalid port number '\(arg)'")
                    return nil
                }
            } else {
                print("Error: Unexpected argument '\(arg)'")
                return nil
            }
        }
        
        guard let host = host, let port = port else {
            print("Usage: \(arguments[0]) [--test-state|-t] <host> <port>")
            print("Example: \(arguments[0]) localhost 7624")
            print("Example: \(arguments[0]) --test-state localhost 7624")
            return nil
        }
        
        return (host, port, testState)
    }
    
    private static func setupStateRegistry(endpoint: INDIServerEndpoint) async {
        let registry = INDIStateRegistry(endpoint: endpoint)
        
        // Set up callbacks for device and property updates
        await registry.setOnDeviceUpdate { (deviceName: String, device: INDIDevice) in
            print("\n[INDIState] Device Updated: \(deviceName)")
            print("  Properties: \(device.properties.count)")
            for property in device.properties {
                print("    - \(property.name.displayName) (\(property.type))")
            }
        }
        
        await registry.setOnPropertyUpdate { (deviceName: String, property: any INDIProperty) in
            print("\n[INDIState] Property Updated: \(deviceName).\(property.name.displayName)")
            print("  Type: \(property.type)")
            if let group = property.group {
                print("  Group: \(group)")
            }
            print("  Values: \(property.values.count)")
            for value in property.values {
                print("    - \(value.name.indiName): ", terminator: "")
                printPropertyValue(value.value)
            }
            if let targetValues = property.targetValues {
                print("  Target Values: \(targetValues.count)")
                for value in targetValues {
                    print("    - \(value.name.indiName): ", terminator: "")
                    printPropertyValue(value.value)
                }
            }
        }
        
        // Start the state registry's own connection and message stream in a background task
        Task.detached(priority: .userInitiated) {
            do {
                try await registry.connect()
            } catch {
                print("[INDIState] Error in state registry connection: \(error.localizedDescription)")
            }
        }
    }
    
    private static func printPropertyValue(_ value: INDIValue.Value) {
        switch value {
        case .text(let text):
            print("\"\(text)\"")
        case .number(let num):
            print("\(num)")
        case .boolean(let bool):
            print(bool ? "ON" : "OFF")
        case .state(let state):
            print(state.indiValue)
        case .blob(let data):
            print("<\(data.count) bytes>")
        }
    }
    
    private static func sendHandshake(server: INDIServer) {
        Task.detached(priority: .userInitiated) {
            do {
                try await server.sendHandshake()
            } catch {
                print("(Error sending handshake: \(error.localizedDescription))")
            }
        }
    }
    
    private static func setupStdinReader(server: INDIServer) {
        Task.detached(priority: .userInitiated) {
            while let line = readLine() {
                let message = line + "\n"
                do {
                    try await server.send(Data(message.utf8))
                    print("(Sent: \(message.trimmingCharacters(in: .whitespacesAndNewlines)))")
                } catch {
                    print("(Error sending message: \(error.localizedDescription))")
                }
            }
        }
    }
    
    private static func setupRawDataPrinter(server: INDIServer) {
        Task.detached(priority: .userInitiated) {
            if let rawStream = await server.rawDataMessages() {
                do {
                    for try await data in rawStream {
                        if let string = String(data: data, encoding: .utf8) {
                            let escaped = string
                                .replacingOccurrences(of: "\n", with: "\\n")
                                .replacingOccurrences(of: "\r", with: "\\r")
                            print("(RAW: \(escaped))")
                        } else {
                            print("(RAW: <\(data.count) bytes of non-UTF8 data>)")
                        }
                    }
                } catch {
                    // Stream ended or error occurred
                }
            }
        }
    }
    
    // MARK: - Printing
    
    private static func printMessage(_ message: INDIMessage) {
        printBasicInfo(message)
        printOptionalAttributes(message)
        printValues(message)
        printDiagnostics(message)
        print("---")
    }
    
    private static func printBasicInfo(_ message: INDIMessage) {
        print("  Operation: \(message.operation)")
        if let propertyType = message.propertyType {
            print("  Property Type: \(propertyType)")
        }
        
        if let device = message.device, !device.isEmpty {
            print("  Device: \(device)")
        }
        if let group = message.group {
            print("  Group: \(group)")
        }
        if let label = message.label {
            print("  Label: \(label)")
        }
        if let name = message.name {
            print("  Name: \(name.displayName)")
        }
    }
    
    private static func printOptionalAttributes(_ message: INDIMessage) {
        if let permissions = message.permissions {
            print("  Permissions: \(permissions.indiValue)")
        }
        if let state = message.state {
            print("  State: \(state.indiValue)")
        }
        
        if let timeout = message.timeout, timeout > 0 {
            print("  Timeout: \(timeout)s")
        }
        
        if let timeStamp = message.timeStamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            print("  Timestamp: \(dateFormatter.string(from: timeStamp))")
        }
        
        if let rule = message.rule {
            print("  Rule: \(rule.rawValue)")
        }
        
        if let format = message.format {
            print("  Format: \(format)")
        }
    }
    
    private static func printValues(_ message: INDIMessage) {
        guard !message.values.isEmpty else { return }
        
        print("  Values: \(message.values.count) value(s)")
        for (index, value) in message.values.enumerated() {
            print("    [\(index)] \(value.name.indiName): ", terminator: "")
            printValue(value.value)
            
            // Print value diagnostics if any
            if !value.diagnostics.isEmpty {
                for diagnostic in value.diagnostics {
                    let (prefix, msg) = diagnosticPrefixAndMessage(diagnostic)
                    print("      [\(prefix)] \(msg)")
                }
            }
        }
    }
    
    private static func printValue(_ value: INDIValue.Value) {
        switch value {
        case .text(let text):
            print("\"\(text)\"")
        case .number(let num):
            print("\(num)")
        case .boolean(let bool):
            print(bool)
        case .state(let state):
            print("\"\(state.indiValue)\"")
        case .blob(let data):
            print("\(data.count) bytes")
        }
    }
    
    private static func printDiagnostics(_ message: INDIMessage) {
        guard !message.diagnostics.isEmpty else { return }
        
        print("  Diagnostics: \(message.diagnostics.count) message(s)")
        for diagnostic in message.diagnostics {
            let (prefix, msg) = diagnosticPrefixAndMessage(diagnostic)
            print("    [\(prefix)] \(msg)")
        }
    }
    
    private static func diagnosticPrefixAndMessage(_ diagnostic: INDIDiagnostics) -> (String, String) {
        switch diagnostic {
        case .debug(let msg):
            return ("DEBUG", msg)
        case .note(let msg):
            return ("NOTE", msg)
        case .info(let msg):
            return ("INFO", msg)
        case .warning(let msg):
            return ("WARNING", msg)
        case .error(let msg):
            return ("ERROR", msg)
        case .fatal(let msg):
            return ("FATAL", msg)
        }
    }
}

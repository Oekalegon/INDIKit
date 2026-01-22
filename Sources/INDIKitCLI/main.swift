import Foundation
import INDIKit

@main
struct INDIKitCLI {
    static func main() async {
        let arguments = CommandLine.arguments

        guard arguments.count == 3 else {
            print("Usage: \(arguments[0]) <host> <port>")
            print("Example: \(arguments[0]) localhost 7624")
            exit(1)
        }

        let host = arguments[1]
        guard let port = UInt16(arguments[2]) else {
            print("Error: Invalid port number '\(arguments[2])'")
            exit(1)
        }

        let endpoint = INDIServerEndpoint(host: host, port: port)
        let server = INDIServer(endpoint: endpoint)

        print("Connecting to INDI server at \(host):\(port)...")

        do {
            // Establish the connection (will throw if it fails)
            _ = try await server.connect()

            print("Connected! Sending INDI handshake and listening for messages...")
            print("Type additional messages to send (or press Ctrl+C to disconnect):\n")

            // Send INDI handshake to start receiving property updates
            do {
                try await server.sendHandshake()
            } catch {
                print("(Error sending handshake: \(error.localizedDescription))")
            }

            // Set up async task to read from stdin and send messages (non-blocking)
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

            // Parse and print INDI Properties
            let propertyStream = try await server.parseProperties()
            
            for try await property in propertyStream {
                print("Parsed INDI Property:")
                printMessage(property)
            }

            print("\nConnection closed.")
        } catch {
            print("\nError connecting to INDI server: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    // MARK: - Printing
    
    private static func printMessage(_ message: INDIProperty) {
        printBasicInfo(message)
        printOptionalAttributes(message)
        printValues(message)
        printDiagnostics(message)
        print("---")
    }
    
    private static func printBasicInfo(_ message: INDIProperty) {
        print("  Operation: \(message.operation)")
        print("  Property Type: \(message.propertyType)")
        
        if !message.device.isEmpty {
            print("  Device: \(message.device)")
        }
        if let group = message.group {
            print("  Group: \(group)")
        }
        if let label = message.label {
            print("  Label: \(label)")
        }
        print("  Name: \(message.name.displayName)")
    }
    
    private static func printOptionalAttributes(_ message: INDIProperty) {
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
    
    private static func printValues(_ message: INDIProperty) {
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
        case .light(let bool):
            print(bool)
        case .blob(let data):
            print("\(data.count) bytes")
        }
    }
    
    private static func printDiagnostics(_ message: INDIProperty) {
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

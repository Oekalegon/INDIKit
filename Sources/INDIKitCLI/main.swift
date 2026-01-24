import Foundation
import INDIProtocol

@main
struct INDIKitCLI {
    static func main() async {
        let arguments = CommandLine.arguments

        guard let (host, port) = parseArguments(arguments) else {
            exit(1)
        }

        let endpoint = INDIServerEndpoint(host: host, port: port)
        let server = INDIServer(endpoint: endpoint)

        print("Connecting to INDI server at \(host):\(port)...")

        do {
            _ = try await server.connect()
            print("Connected! Sending INDI handshake and listening for messages...")
            print("Type additional messages to send (or press Ctrl+C to disconnect):\n")

            sendHandshake(server: server)
            setupStdinReader(server: server)
            setupRawDataPrinter(server: server)
            
            let propertyStream = try await server.messages()
            for try await property in propertyStream {
                print("Parsed INDI Message:")
                printMessage(property)
            }

            print("\nConnection closed.")
        } catch {
            print("\nError connecting to INDI server: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    // MARK: - Setup Helpers
    
    private static func parseArguments(_ arguments: [String]) -> (host: String, port: UInt16)? {
        guard arguments.count == 3 else {
            print("Usage: \(arguments[0]) <host> <port>")
            print("Example: \(arguments[0]) localhost 7624")
            return nil
        }

        let host = arguments[1]
        guard let port = UInt16(arguments[2]) else {
            print("Error: Invalid port number '\(arguments[2])'")
            return nil
        }
        
        return (host, port)
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

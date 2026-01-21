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
            let stream = try await server.connect()

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

            for try await data in stream {
                print("Received \(data.count) bytes:")
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                } else {
                    print(data.map { String(format: "%02x", $0) }.joined(separator: " "))
                }
                print("---")
            }

            print("\nConnection closed.")
        } catch {
            print("\nError connecting to INDI server: \(error.localizedDescription)")
            exit(1)
        }
    }
}

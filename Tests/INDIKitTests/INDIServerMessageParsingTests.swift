import Testing
import Foundation
@testable import INDIProtocol

@Suite("INDI Server Message Parsing Tests")
struct INDIServerMessageParsingTests {
    
    // MARK: - Helper Functions
    
    /// Create an AsyncThrowingStream from XML string
    private func createDataStream(from xml: String) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(Data(xml.utf8))
            continuation.finish()
        }
    }
    
    /// Parse XML and collect all messages
    private func parseXML(_ xml: String) async throws -> [INDIMessage] {
        let parser = INDIXMLParser()
        let dataStream = createDataStream(from: xml)
        let messageStream = await parser.parse(dataStream)
        
        var messages: [INDIMessage] = []
        for try await message in messageStream {
            messages.append(message)
        }
        return messages
    }
    
    // MARK: - Basic Parsing Tests
    
    @Test("Parse server message with device and timestamp")
    func testParseServerMessageWithDeviceAndTimestamp() async throws {
        let xml = """
        <message device="Telescope Simulator" timestamp="2026-01-22T08:41:00">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .message)
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.device == "Telescope Simulator")
            #expect(serverMsg.message == "Slew complete")
            #expect(serverMsg.timeStamp != nil)
            
            if let timestamp = serverMsg.timeStamp {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let timestampString = formatter.string(from: timestamp)
                #expect(timestampString.contains("2026-01-22T08:41:00"))
            }
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message with device only")
    func testParseServerMessageWithDeviceOnly() async throws {
        let xml = """
        <message device="Telescope Simulator">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .message)
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.device == "Telescope Simulator")
            #expect(serverMsg.message == "Slew complete")
            #expect(serverMsg.timeStamp == nil)
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message with timestamp only")
    func testParseServerMessageWithTimestampOnly() async throws {
        let xml = """
        <message timestamp="2026-01-22T08:41:00">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .message)
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.device == nil)
            #expect(serverMsg.message == "Slew complete")
            #expect(serverMsg.timeStamp != nil)
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message without attributes")
    func testParseServerMessageWithoutAttributes() async throws {
        let xml = """
        <message>
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .message)
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.device == nil)
            #expect(serverMsg.message == "Slew complete")
            #expect(serverMsg.timeStamp == nil)
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message with empty text")
    func testParseServerMessageWithEmptyText() async throws {
        let xml = "<message device=\"Telescope Simulator\"></message>"
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.message == "")
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message trims whitespace")
    func testParseServerMessageTrimsWhitespace() async throws {
        let xml = """
        <message device="Telescope Simulator">
            \n  Slew complete  \n
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            #expect(serverMsg.message == "Slew complete")
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Parse server message with multiline text")
    func testParseServerMessageWithMultilineText() async throws {
        let xml = """
        <message device="Telescope Simulator">
            Slew complete
            Target reached
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            // Should preserve newlines in the message text
            #expect(serverMsg.message.contains("Slew complete"))
            #expect(serverMsg.message.contains("Target reached"))
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    // MARK: - Enum Wrapper Tests
    
    @Test("Server message accessible via enum wrapper")
    func testServerMessageViaEnumWrapper() async throws {
        let xml = """
        <message device="Telescope Simulator" timestamp="2026-01-22T08:41:00">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        // Test enum wrapper properties
        #expect(message.operation == .message)
        #expect(message.device == "Telescope Simulator")
        #expect(message.timeStamp != nil)
        #expect(message.messageText == "Slew complete")
        #expect(message.name == nil)
        #expect(message.propertyType == nil)
        #expect(message.values.isEmpty)
    }
    
    // MARK: - Validation Tests
    
    @Test("Server message with unexpected attribute generates warning")
    func testServerMessageWithUnexpectedAttribute() async throws {
        let xml = """
        <message device="Telescope Simulator" unexpected="value">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                serverMsg.diagnostics,
                containing: "unexpected attribute 'unexpected'"
            ))
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Server message with child elements generates warning")
    func testServerMessageWithChildElements() async throws {
        let xml = """
        <message device="Telescope Simulator">
            <child>Should not be here</child>
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                serverMsg.diagnostics,
                containing: "child element"
            ))
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    @Test("Server message with valid attributes has no warnings")
    func testServerMessageWithValidAttributes() async throws {
        let xml = """
        <message device="Telescope Simulator" timestamp="2026-01-22T08:41:00">
            Slew complete
        </message>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .serverMessage(let serverMsg) = message {
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(serverMsg.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(serverMsg.diagnostics))
        } else {
            Issue.record("Expected serverMessage case")
        }
    }
    
    // MARK: - XML Serialization Tests
    
    @Test("Serialize server message with device and timestamp to XML")
    func testSerializeServerMessageWithDeviceAndTimestamp() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestamp = formatter.date(from: "2026-01-22T08:41:00Z")!
        
        let serverMessage = INDIServerMessage(
            device: "Telescope Simulator",
            timeStamp: timestamp,
            message: "Slew complete"
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(xml.contains("device=\"Telescope Simulator\""))
        #expect(xml.contains("timestamp=\"2026-01-22T08:41:00"))
        #expect(xml.contains("Slew complete"))
        #expect(xml.contains("<message"))
        #expect(xml.contains("</message>"))
    }
    
    @Test("Serialize server message with device only to XML")
    func testSerializeServerMessageWithDeviceOnly() throws {
        let serverMessage = INDIServerMessage(
            device: "Telescope Simulator",
            timeStamp: nil,
            message: "Slew complete"
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(xml.contains("device=\"Telescope Simulator\""))
        #expect(!xml.contains("timestamp="))
        #expect(xml.contains("Slew complete"))
    }
    
    @Test("Serialize server message with timestamp only to XML")
    func testSerializeServerMessageWithTimestampOnly() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestamp = formatter.date(from: "2026-01-22T08:41:00Z")!
        
        let serverMessage = INDIServerMessage(
            device: nil,
            timeStamp: timestamp,
            message: "Slew complete"
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(!xml.contains("device="))
        // Serialization includes fractional seconds, so check for the timestamp pattern
        #expect(xml.contains("timestamp=\"2026-01-22T08:41:00"))
        #expect(xml.contains("Slew complete"))
    }
    
    @Test("Serialize server message without attributes to XML")
    func testSerializeServerMessageWithoutAttributes() throws {
        let serverMessage = INDIServerMessage(
            device: nil,
            timeStamp: nil,
            message: "Slew complete"
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(!xml.contains("device="))
        #expect(!xml.contains("timestamp="))
        #expect(xml.contains("Slew complete"))
        #expect(xml == "<message>Slew complete</message>")
    }
    
    @Test("Serialize server message with escaped characters")
    func testSerializeServerMessageWithEscapedCharacters() throws {
        let serverMessage = INDIServerMessage(
            device: "Device & Co.",
            timeStamp: nil,
            message: "Message with <tags> and \"quotes\""
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(xml.contains("device=\"Device &amp; Co.\""))
        #expect(xml.contains("&lt;tags&gt;"))
        #expect(xml.contains("&quot;quotes&quot;"))
        #expect(!xml.contains("<tags>"))
        #expect(!xml.contains("\"quotes\""))
    }
    
    @Test("Serialize server message with empty device attribute is omitted")
    func testSerializeServerMessageWithEmptyDevice() throws {
        let serverMessage = INDIServerMessage(
            device: "",
            timeStamp: nil,
            message: "Slew complete"
        )
        
        let message = INDIMessage.serverMessage(serverMessage)
        let xml = try message.toXML()
        
        #expect(!xml.contains("device="))
        #expect(xml.contains("Slew complete"))
    }
}


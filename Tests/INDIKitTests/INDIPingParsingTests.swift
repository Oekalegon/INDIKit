import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Ping and PingReply Parsing Tests")
struct INDIPingParsingTests {
    
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
    
    // MARK: - PingReply Parsing Tests
    
    @Test("Parse pingReply with uid")
    func testParsePingReplyWithUid() async throws {
        let xml = """
        <pingReply uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        #expect(message.operation == .pingReply)
        #expect(message.device == nil)
        #expect(message.name == nil)
        #expect(message.propertyType == nil)
        #expect(message.values.isEmpty)
        
        if case .pingReply(let pingReply) = message {
            #expect(pingReply.uid == "12345")
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(pingReply.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(pingReply.diagnostics))
        } else {
            Issue.record("Expected pingReply case")
        }
    }
    
    @Test("Parse pingReply without uid")
    func testParsePingReplyWithoutUid() async throws {
        let xml = """
        <pingReply/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        #expect(message.operation == .pingReply)
        #expect(message.device == nil)
        #expect(message.name == nil)
        
        if case .pingReply(let pingReply) = message {
            #expect(pingReply.uid == nil)
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(pingReply.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(pingReply.diagnostics))
        } else {
            Issue.record("Expected pingReply case")
        }
    }
    
    // MARK: - Validation Tests
    
    @Test("PingReply with unexpected attribute generates warning")
    func testPingReplyWithUnexpectedAttribute() async throws {
        let xml = """
        <pingReply uid="12345" unexpected="value"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .pingReply(let pingReply) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                pingReply.diagnostics,
                containing: "pingReply element contains unexpected attribute 'unexpected'"
            ))
        } else {
            Issue.record("Expected pingReply case")
        }
    }
    
    @Test("PingReply with child elements generates warning")
    func testPingReplyWithChildElements() async throws {
        let xml = """
        <pingReply uid="12345">
            <child>Should not be here</child>
        </pingReply>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .pingReply(let pingReply) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                pingReply.diagnostics,
                containing: "pingReply element contains 1 child element(s)"
            ))
        } else {
            Issue.record("Expected pingReply case")
        }
    }
    
    // MARK: - Enum Wrapper Property Tests
    
    @Test("INDIMessage enum wrapper properties for pingReply")
    func testINDIMessageEnumWrapperPropertiesForPingReply() async throws {
        let xml = """
        <pingReply uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        let message = messages[0]
        
        #expect(message.operation == .pingReply)
        #expect(message.device == nil)
        #expect(message.name == nil)
        #expect(message.propertyType == nil)
        #expect(message.values.isEmpty)
        #expect(message.group == nil)
        #expect(message.label == nil)
        #expect(message.permissions == nil)
        #expect(message.state == nil)
        #expect(message.timeout == nil)
        #expect(message.timeStamp == nil)
        #expect(message.rule == nil)
        #expect(message.format == nil)
        #expect(message.blobSendingState == nil)
        #expect(message.version == nil)
        #expect(message.messageText == nil)
    }
    
    // MARK: - Ping Creation and Serialization Tests
    
    @Test("Create ping programmatically without uid")
    func testCreatePingWithoutUid() {
        let ping = INDIPing(uid: nil)
        
        #expect(ping.operation == .ping)
        #expect(ping.uid == nil)
        #expect(ping.diagnostics.isEmpty)
        
        do {
            let xml = try ping.toXML()
            #expect(xml == "<ping/>")
        } catch {
            Issue.record("Failed to serialize ping: \(error)")
        }
    }
    
    @Test("Create ping programmatically with uid")
    func testCreatePingWithUid() {
        let ping = INDIPing(uid: "12345")
        
        #expect(ping.operation == .ping)
        #expect(ping.uid == "12345")
        #expect(ping.diagnostics.isEmpty)
        
        do {
            let xml = try ping.toXML()
            #expect(xml.contains("<ping"))
            #expect(xml.contains("uid=\"12345\""))
            #expect(xml.contains("/>"))
        } catch {
            Issue.record("Failed to serialize ping: \(error)")
        }
    }
    
    @Test("Create ping programmatically with empty uid")
    func testCreatePingWithEmptyUid() {
        let ping = INDIPing(uid: "")
        
        #expect(ping.operation == .ping)
        #expect(ping.uid == "")
        
        do {
            let xml = try ping.toXML()
            // Empty uid should not be included in XML
            #expect(xml == "<ping/>")
        } catch {
            Issue.record("Failed to serialize ping: \(error)")
        }
    }
    
    @Test("Serialize ping with escaped uid to XML")
    func testSerializePingWithEscapedUid() {
        let ping = INDIPing(uid: "test&uid<value>")
        
        do {
            let xml = try ping.toXML()
            #expect(xml.contains("uid=\"test&amp;uid&lt;value&gt;\""))
        } catch {
            Issue.record("Failed to serialize ping: \(error)")
        }
    }
    
    @Test("INDIMessage enum wrapper for ping")
    func testINDIMessageEnumWrapperForPing() {
        let ping = INDIPing(uid: "12345")
        let message = INDIMessage.ping(ping)
        
        #expect(message.operation == .ping)
        #expect(message.device == nil)
        #expect(message.name == nil)
        #expect(message.propertyType == nil)
        #expect(message.values.isEmpty)
        #expect(message.group == nil)
        #expect(message.label == nil)
        #expect(message.permissions == nil)
        #expect(message.state == nil)
        #expect(message.timeout == nil)
        #expect(message.timeStamp == nil)
        #expect(message.rule == nil)
        #expect(message.format == nil)
        #expect(message.blobSendingState == nil)
        #expect(message.version == nil)
        #expect(message.messageText == nil)
        
        do {
            let xml = try message.toXML()
            #expect(xml.contains("<ping"))
            #expect(xml.contains("uid=\"12345\""))
        } catch {
            Issue.record("Failed to serialize message: \(error)")
        }
    }
    
    @Test("PingReply cannot be serialized")
    func testPingReplyCannotBeSerialized() async throws {
        let xml = """
        <pingReply uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        let message = messages[0]
        
        #expect(message.operation == .pingReply)
        
        do {
            _ = try message.toXML()
            Issue.record("Expected toXML() to throw an error for pingReply")
        } catch {
            // Expected - pingReply is receive-only and cannot be serialized
            #expect(error.localizedDescription.contains("pingReply") || 
                    error.localizedDescription.contains("cannot be serialized"))
        }
    }
}


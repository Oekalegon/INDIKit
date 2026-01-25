import Testing
import Foundation
@testable import INDIProtocol

@Suite("INDI PingRequest and PingReply Parsing Tests")
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
    
    // MARK: - PingRequest Parsing Tests
    
    @Test("Parse pingRequest with uid")
    func testParsePingRequestWithUid() async throws {
        let xml = """
        <pingRequest uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        #expect(message.operation == .pingRequest)
        #expect(message.device == nil)
        #expect(message.name == nil)
        #expect(message.propertyType == nil)
        #expect(message.values.isEmpty)
        
        if case .pingRequest(let pingRequest) = message {
            #expect(pingRequest.uid == "12345")
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(pingRequest.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(pingRequest.diagnostics))
        } else {
            Issue.record("Expected pingRequest case")
        }
    }
    
    @Test("Parse pingRequest without uid")
    func testParsePingRequestWithoutUid() async throws {
        let xml = """
        <pingRequest/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        #expect(message.operation == .pingRequest)
        #expect(message.device == nil)
        #expect(message.name == nil)
        
        if case .pingRequest(let pingRequest) = message {
            #expect(pingRequest.uid == nil)
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(pingRequest.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(pingRequest.diagnostics))
        } else {
            Issue.record("Expected pingRequest case")
        }
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
    
    @Test("PingRequest with unexpected attribute generates warning")
    func testPingRequestWithUnexpectedAttribute() async throws {
        let xml = """
        <pingRequest uid="12345" unexpected="value"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .pingRequest(let pingRequest) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                pingRequest.diagnostics,
                containing: "pingRequest element contains unexpected attribute 'unexpected'"
            ))
        } else {
            Issue.record("Expected pingRequest case")
        }
    }
    
    @Test("PingRequest with child elements generates warning")
    func testPingRequestWithChildElements() async throws {
        let xml = """
        <pingRequest uid="12345">
            <child>Should not be here</child>
        </pingRequest>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .pingRequest(let pingRequest) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                pingRequest.diagnostics,
                containing: "pingRequest element contains 1 child element(s)"
            ))
        } else {
            Issue.record("Expected pingRequest case")
        }
    }
    
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
    
    @Test("INDIMessage enum wrapper properties for pingRequest")
    func testINDIMessageEnumWrapperPropertiesForPingRequest() async throws {
        let xml = """
        <pingRequest uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        let message = messages[0]
        
        #expect(message.operation == .pingRequest)
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
    
    // MARK: - PingReply Creation and Serialization Tests
    
    @Test("Create pingReply programmatically without uid")
    func testCreatePingReplyWithoutUid() {
        let pingReply = INDIPingReply(uid: nil)
        
        #expect(pingReply.operation == .pingReply)
        #expect(pingReply.uid == nil)
        #expect(pingReply.diagnostics.isEmpty)
        
        do {
            let xml = try pingReply.toXML()
            #expect(xml == "<pingReply/>")
        } catch {
            Issue.record("Failed to serialize pingReply: \(error)")
        }
    }
    
    @Test("Create pingReply programmatically with uid")
    func testCreatePingReplyWithUid() {
        let pingReply = INDIPingReply(uid: "12345")
        
        #expect(pingReply.operation == .pingReply)
        #expect(pingReply.uid == "12345")
        #expect(pingReply.diagnostics.isEmpty)
        
        do {
            let xml = try pingReply.toXML()
            #expect(xml.contains("<pingReply"))
            #expect(xml.contains("uid=\"12345\""))
            #expect(xml.contains("/>"))
        } catch {
            Issue.record("Failed to serialize pingReply: \(error)")
        }
    }
    
    @Test("Create pingReply programmatically with empty uid")
    func testCreatePingReplyWithEmptyUid() {
        let pingReply = INDIPingReply(uid: "")
        
        #expect(pingReply.operation == .pingReply)
        #expect(pingReply.uid == "")
        
        do {
            let xml = try pingReply.toXML()
            // Empty uid should not be included in XML
            #expect(xml == "<pingReply/>")
        } catch {
            Issue.record("Failed to serialize pingReply: \(error)")
        }
    }
    
    @Test("Serialize pingReply with escaped uid to XML")
    func testSerializePingReplyWithEscapedUid() {
        let pingReply = INDIPingReply(uid: "test&uid<value>")
        
        do {
            let xml = try pingReply.toXML()
            #expect(xml.contains("uid=\"test&amp;uid&lt;value&gt;\""))
        } catch {
            Issue.record("Failed to serialize pingReply: \(error)")
        }
    }
    
    @Test("INDIMessage enum wrapper for pingReply")
    func testINDIMessageEnumWrapperForPingReply() {
        let pingReply = INDIPingReply(uid: "12345")
        let message = INDIMessage.pingReply(pingReply)
        
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
        
        do {
            let xml = try message.toXML()
            #expect(xml.contains("<pingReply"))
            #expect(xml.contains("uid=\"12345\""))
        } catch {
            Issue.record("Failed to serialize message: \(error)")
        }
    }
    
    @Test("PingRequest cannot be serialized")
    func testPingRequestCannotBeSerialized() async throws {
        let xml = """
        <pingRequest uid="12345"/>
        """
        
        let messages = try await parseXML(xml)
        let message = messages[0]
        
        #expect(message.operation == .pingRequest)
        
        do {
            _ = try message.toXML()
            Issue.record("Expected toXML() to throw an error for pingRequest")
        } catch {
            // Expected - pingRequest is receive-only and cannot be serialized
            #expect(error.localizedDescription.contains("pingRequest") || 
                    error.localizedDescription.contains("cannot be serialized"))
        }
    }
}


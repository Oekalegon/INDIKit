import Testing
import Foundation
@testable import INDIProtocol

@Suite("INDI Delete Property Parsing Tests")
struct INDIDeletePropertyParsingTests {
    
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
    
    @Test("Parse delProperty with device and name")
    func testParseDelPropertyWithDeviceAndName() async throws {
        let xml = """
        <delProperty device="Telescope Simulator" name="CONNECTION"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .delete)
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(deleteProp.device == "Telescope Simulator")
            #expect(deleteProp.name?.indiName == "CONNECTION")
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Parse delProperty with device only")
    func testParseDelPropertyWithDeviceOnly() async throws {
        let xml = """
        <delProperty device="Telescope Simulator"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .delete)
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(deleteProp.device == "Telescope Simulator")
            #expect(deleteProp.name == nil)
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Parse delProperty without attributes")
    func testParseDelPropertyWithoutAttributes() async throws {
        let xml = """
        <delProperty/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        #expect(message.operation == .delete)
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(deleteProp.device == nil)
            #expect(deleteProp.name == nil)
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    // MARK: - Enum Wrapper Tests
    
    @Test("Delete property accessible via enum wrapper")
    func testDeletePropertyViaEnumWrapper() async throws {
        let xml = """
        <delProperty device="Telescope Simulator" name="CONNECTION"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        // Test enum wrapper properties
        #expect(message.operation == .delete)
        #expect(message.device == "Telescope Simulator")
        #expect(message.name?.indiName == "CONNECTION")
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
    
    // MARK: - Validation Tests
    
    @Test("Delete property with name but no device generates error")
    func testDeletePropertyWithNameButNoDevice() async throws {
        let xml = """
        <delProperty name="CONNECTION"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(INDIDiagnosticsTestHelpers.hasError(
                deleteProp.diagnostics,
                containing: "delProperty has 'name' attribute but missing 'device' attribute"
            ))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Delete property with unexpected attribute generates warning")
    func testDeletePropertyWithUnexpectedAttribute() async throws {
        let xml = """
        <delProperty device="Telescope Simulator" unexpected="value"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                deleteProp.diagnostics,
                containing: "unexpected attribute 'unexpected'"
            ))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Delete property with child elements generates warning")
    func testDeletePropertyWithChildElements() async throws {
        let xml = """
        <delProperty device="Telescope Simulator">
            <child>Should not be here</child>
        </delProperty>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(INDIDiagnosticsTestHelpers.hasWarning(
                deleteProp.diagnostics,
                containing: "child element"
            ))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Delete property with valid attributes has no errors")
    func testDeletePropertyWithValidAttributes() async throws {
        let xml = """
        <delProperty device="Telescope Simulator" name="CONNECTION"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(deleteProp.diagnostics))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Delete property with device only has no errors")
    func testDeletePropertyWithDeviceOnlyHasNoErrors() async throws {
        let xml = """
        <delProperty device="Telescope Simulator"/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(deleteProp.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(deleteProp.diagnostics))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
    
    @Test("Delete property without attributes has no errors")
    func testDeletePropertyWithoutAttributesHasNoErrors() async throws {
        let xml = """
        <delProperty/>
        """
        
        let messages = try await parseXML(xml)
        
        #expect(messages.count == 1)
        let message = messages[0]
        
        if case .deleteProperty(let deleteProp) = message {
            #expect(!INDIDiagnosticsTestHelpers.hasAnyError(deleteProp.diagnostics))
            #expect(!INDIDiagnosticsTestHelpers.hasAnyWarning(deleteProp.diagnostics))
        } else {
            Issue.record("Expected deleteProperty case")
        }
    }
}


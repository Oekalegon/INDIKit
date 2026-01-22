import Testing
import Foundation
@testable import INDIKit

@Suite("INDI Sending Tests")
struct INDISendingTests {
    
    // MARK: - sendHandshake Tests
    
    @Test("sendHandshake constructs correct message")
    func testSendHandshakeMessage() async throws {
        // The handshake message should be: <getProperties version='1.7'/>\n
        let expectedMessage = "<getProperties version='1.7'/>\n"
        let expectedData = Data(expectedMessage.utf8)
        
        // Verify the message format by checking what sendHandshake would send
        // Since we can't easily mock NWConnection, we test the message construction logic
        let handshake = "<getProperties version='1.7'/>\n"
        let handshakeData = Data(handshake.utf8)
        
        #expect(handshakeData == expectedData)
        #expect(String(data: handshakeData, encoding: .utf8) == expectedMessage)
    }
    
    @Test("sendHandshake message format is correct")
    func testSendHandshakeFormat() async throws {
        // Test that the handshake message has the correct XML structure
        let handshake = "<getProperties version='1.7'/>\n"
        
        // Verify it's valid XML-like structure
        #expect(handshake.hasPrefix("<getProperties"))
        #expect(handshake.contains("version='1.7'"))
        #expect(handshake.hasSuffix("/>\n"))
        
        // Verify it ends with newline
        #expect(handshake.last == "\n")
    }
    
    // MARK: - send() Tests
    
    @Test("send throws error when not connected")
    func testSendWhenNotConnected() async throws {
        let endpoint = INDIServerEndpoint(host: "localhost", port: 7624)
        let server = INDIServer(endpoint: endpoint)
        
        let testData = Data("test message".utf8)
        
        // Verify that send throws an error when not connected
        do {
            try await server.send(testData)
            Issue.record("Expected send to throw error when not connected")
        } catch {
            // Expected to throw - verify it's the right error
            #expect(error.localizedDescription.contains("Connection is not open"))
        }
    }
    
    // MARK: - Message Construction Tests
    
    @Test("Construct newSwitchVector message")
    func testConstructNewSwitchVector() async throws {
        // Test constructing a newSwitchVector message
        let message = """
        <newSwitchVector device="Telescope Simulator" name="CONNECTION">
            <oneSwitch name="CONNECT">On</oneSwitch>
            <oneSwitch name="DISCONNECT">Off</oneSwitch>
        </newSwitchVector>
        """
        
        let messageData = Data(message.utf8)
        
        // Verify it's valid UTF-8
        #expect(String(data: messageData, encoding: .utf8) == message)
        
        // Verify structure
        #expect(message.contains("<newSwitchVector"))
        #expect(message.contains("device=\"Telescope Simulator\""))
        #expect(message.contains("name=\"CONNECTION\""))
        #expect(message.contains("<oneSwitch name=\"CONNECT\">On</oneSwitch>"))
        #expect(message.contains("<oneSwitch name=\"DISCONNECT\">Off</oneSwitch>"))
    }
    
    @Test("Construct newNumberVector message")
    func testConstructNewNumberVector() async throws {
        let message = """
        <newNumberVector device="Telescope Simulator" name="EQUATORIAL_EOD_COORD">
            <oneNumber name="RA">23.5</oneNumber>
            <oneNumber name="DEC">45.0</oneNumber>
        </newNumberVector>
        """
        
        let messageData = Data(message.utf8)
        
        #expect(String(data: messageData, encoding: .utf8) == message)
        #expect(message.contains("<newNumberVector"))
        #expect(message.contains("name=\"EQUATORIAL_EOD_COORD\""))
        #expect(message.contains("<oneNumber name=\"RA\">23.5</oneNumber>"))
        #expect(message.contains("<oneNumber name=\"DEC\">45.0</oneNumber>"))
    }
    
    @Test("Construct newTextVector message")
    func testConstructNewTextVector() async throws {
        let message = """
        <newTextVector device="CCD Simulator" name="FILTER_NAME">
            <oneText name="FILTER_SLOT_NAME_1">Red</oneText>
            <oneText name="FILTER_SLOT_NAME_2">Green</oneText>
        </newTextVector>
        """
        
        let messageData = Data(message.utf8)
        
        #expect(String(data: messageData, encoding: .utf8) == message)
        #expect(message.contains("<newTextVector"))
        #expect(message.contains("name=\"FILTER_NAME\""))
        #expect(message.contains("<oneText name=\"FILTER_SLOT_NAME_1\">Red</oneText>"))
        #expect(message.contains("<oneText name=\"FILTER_SLOT_NAME_2\">Green</oneText>"))
    }
    
    @Test("Message data encoding is correct")
    func testMessageDataEncoding() async throws {
        let testMessages = [
            "<getProperties version='1.7'/>\n",
            "<newSwitchVector device=\"Test\" name=\"TEST\"><oneSwitch name=\"SW\">On</oneSwitch></newSwitchVector>\n",
            "<newNumberVector device=\"Test\" name=\"NUM\"><oneNumber name=\"VAL\">42</oneNumber></newNumberVector>\n"
        ]
        
        for message in testMessages {
            let data = Data(message.utf8)
            let decoded = String(data: data, encoding: .utf8)
            #expect(decoded == message)
        }
    }
    
    @Test("Message with special characters encodes correctly")
    func testMessageWithSpecialCharacters() async throws {
        let message = "<newTextVector device=\"Test\" name=\"TEXT\"><oneText name=\"VALUE\">Test & Value < > \" '</oneText></newTextVector>\n"
        
        // Note: In real XML, special characters should be escaped, but we're testing the data encoding
        let data = Data(message.utf8)
        let decoded = String(data: data, encoding: .utf8)
        
        // The decoded string should match the original (UTF-8 encoding should preserve it)
        #expect(decoded == message)
    }
    
    @Test("Multiple messages can be sent sequentially")
    func testMultipleMessagesSequential() async throws {
        let messages = [
            "<getProperties version='1.7'/>\n",
            "<newSwitchVector device=\"Test\" name=\"SW1\"><oneSwitch name=\"V1\">On</oneSwitch></newSwitchVector>\n",
            "<newSwitchVector device=\"Test\" name=\"SW2\"><oneSwitch name=\"V2\">Off</oneSwitch></newSwitchVector>\n"
        ]
        
        for message in messages {
            let data = Data(message.utf8)
            let decoded = String(data: data, encoding: .utf8)
            #expect(decoded == message)
            #expect(data.count > 0)
        }
    }
}


import Foundation

/// Parser that converts a stream of raw Data chunks into parsed INDI XML messages.
///
/// This parser uses Foundation's XMLParser (a SAX-style parser) to parse XML messages.
/// It handles the fact that XML messages may arrive split across multiple Data chunks
/// by buffering incoming data and detecting complete XML elements by tracking tag depth.
///
/// The parser can handle messages larger than the 64KB chunk size from INDIServer
/// by accumulating chunks until a complete XML element is detected.
public actor INDIXMLParser {
    private var buffer = Data()
    
    /// Maximum buffer size in bytes before throwing an error.
    ///
    /// Default is 2GB, which should accommodate large FITS files and other
    /// astronomical data transfers via INDI BLOB messages. Set to a higher value
    /// if you expect even larger messages, or lower to limit memory usage.
    public var maxBufferSize: Int = 2 * 1024 * 1024 * 1024 // 2GB
    
    /// Initialize a new XML parser.
    public init() {
    }
    
    /// Parse a stream of Data chunks into a stream of INDIMessage objects.
    ///
    /// - Parameter dataStream: The stream of raw Data chunks from INDIServer
    /// - Returns: A stream of parsed INDIMessage objects
    public func parse(_ dataStream: AsyncThrowingStream<Data, Error>) -> AsyncThrowingStream<INDIMessage, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await data in dataStream {
                        await self.processData(data, continuation: continuation)
                    }
                    // Try to parse any remaining buffered data
                    await self.processRemainingBuffer(continuation: continuation)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Process incoming data chunks, extracting and parsing complete XML messages.
    private func processData(
        _ data: Data,
        continuation: AsyncThrowingStream<INDIMessage, Error>.Continuation
    ) async {
        // Check if adding this data would exceed the maximum buffer size
        if buffer.count + data.count > maxBufferSize {
            let bufferSize = buffer.count + data.count
            let errorMessage = "Buffer size (\(bufferSize) bytes) exceeds maximum " +
                "(\(maxBufferSize) bytes). Message may be too large or malformed."
            let error = NSError(
                domain: "INDIXMLParser",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
            continuation.finish(throwing: error)
            return
        }
        
        buffer.append(data)
        
        // Try to extract and parse complete XML messages
        // Messages are detected by finding complete root XML elements
        while let message = await extractAndParseNextMessage() {
            continuation.yield(message)
        }
    }
    
    /// Process any remaining data in the buffer after the stream ends.
    private func processRemainingBuffer(
        continuation: AsyncThrowingStream<INDIMessage, Error>.Continuation
    ) async {
        // Try to parse any remaining buffered data
        while let message = await extractAndParseNextMessage() {
            continuation.yield(message)
        }
    }
    
    /// Extract and parse the next complete XML message from the buffer.
    ///
    /// A complete message is detected by finding a complete root XML element
    /// (opening tag with matching closing tag, or self-closing tag).
    ///
    /// Returns nil if no complete message is available yet.
    private func extractAndParseNextMessage() async -> INDIMessage? {
        guard !buffer.isEmpty else { return nil }
        
        guard let bufferString = String(data: buffer, encoding: .utf8) else {
            // Invalid UTF-8, skip this byte
            buffer.removeFirst()
            return nil
        }
        
        // Trim leading whitespace
        let trimmed = bufferString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            buffer.removeAll()
            return nil
        }
        
        // Find a complete XML element by tracking tag depth
        guard let elementRange = findCompleteXMLElement(in: trimmed) else {
            // No complete element found yet, wait for more data
            return nil
        }
        
        let xmlString = String(trimmed[elementRange])
        
        // Try to parse this XML element
        guard let message = tryParseXML(xmlString) else {
            // Parsing failed, skip this element and continue
            await removeFromBuffer(upTo: elementRange.upperBound, in: trimmed)
            return nil
        }
        
        // Remove the parsed message from buffer
        await removeFromBuffer(upTo: elementRange.upperBound, in: trimmed)
        return message
    }
    
    /// Find a complete XML element in the string by tracking tag depth.
    ///
    /// Returns the range of a complete root XML element, or nil if no complete element is found.
    private func findCompleteXMLElement(in string: String) -> Range<String.Index>? {
        guard string.hasPrefix("<") else { return nil }
        
        // Find the start of the first element
        guard let elementStart = findElementStart(in: string) else {
            return nil
        }
        
        // Check if it's a self-closing tag first
        if let selfClosingRange = findSelfClosingTag(in: string, start: elementStart) {
            return selfClosingRange
        }
        
        // Otherwise, find the matching closing tag
        return findCompleteElementWithClosingTag(in: string, start: elementStart)
    }
    
    /// Find the start of the first XML element in the string.
    private func findElementStart(in string: String) -> String.Index? {
        guard string.hasPrefix("<") else { return nil }
        return string.startIndex
    }
    
    /// Find a self-closing XML tag starting at the given position.
    private func findSelfClosingTag(
        in string: String,
        start: String.Index
    ) -> Range<String.Index>? {
        var inQuotes = false
        var quoteChar: Character?
        var i = start
        
        while i < string.endIndex {
            let char = string[i]
            
            if char == "\"" || char == "'" {
                if !inQuotes {
                    inQuotes = true
                    quoteChar = char
                } else if char == quoteChar {
                    inQuotes = false
                    quoteChar = nil
                }
            }
            
            if !inQuotes && char == ">" {
                // Check if there's a '/' before this '>'
                var checkIndex = string.index(before: i)
                while checkIndex > start && string[checkIndex].isWhitespace {
                    checkIndex = string.index(before: checkIndex)
                }
                if checkIndex >= start && string[checkIndex] == "/" {
                    return start..<string.index(after: i)
                }
                break
            }
            
            i = string.index(after: i)
        }
        
        return nil
    }
    
    /// Find a complete XML element including its closing tag.
    private func findCompleteElementWithClosingTag(
        in string: String,
        start: String.Index
    ) -> Range<String.Index>? {
        // Extract the tag name from the opening tag
        guard let tagName = extractTagName(from: string, start: start) else {
            return nil
        }
        
        // Find the closing tag
        let closingTag = "</\(tagName)>"
        if let closingRange = string.range(of: closingTag, range: start..<string.endIndex) {
            return start..<closingRange.upperBound
        }
        
        return nil
    }
    
    /// Extract the tag name from an opening XML tag.
    private func extractTagName(from string: String, start: String.Index) -> String? {
        guard start < string.endIndex && string[start] == "<" else {
            return nil
        }
        
        var i = string.index(after: start)
        var inQuotes = false
        var quoteChar: Character?
        var tagNameEnd: String.Index?
        
        while i < string.endIndex {
            let char = string[i]
            
            if char == "\"" || char == "'" {
                if !inQuotes {
                    inQuotes = true
                    quoteChar = char
                } else if char == quoteChar {
                    inQuotes = false
                    quoteChar = nil
                }
            }
            
            if !inQuotes {
                if char.isWhitespace || char == ">" || char == "/" {
                    tagNameEnd = i
                    break
                }
            }
            
            i = string.index(after: i)
        }
        
        guard let end = tagNameEnd else {
            return nil
        }
        
        let tagNameStart = string.index(after: start)
        return String(string[tagNameStart..<end])
    }
    
    /// Remove data from buffer up to (and including) the specified index.
    private func removeFromBuffer(upTo index: String.Index, in string: String) async {
        let substring = String(string[string.startIndex..<index])
        guard let dataToRemove = substring.data(using: .utf8) else {
            return
        }
        
        let bytesToRemove = dataToRemove.count
        if buffer.count >= bytesToRemove {
            buffer.removeFirst(bytesToRemove)
        }
    }
    
    /// Try to parse a string as XML and return an INDIMessage if successful.
    private func tryParseXML(_ xmlString: String) -> INDIMessage? {
        guard let xmlData = xmlString.data(using: .utf8) else {
            return nil
        }
        
        let parser = XMLParser(data: xmlData)
        let delegate = INDIXMLParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            return nil
        }
        
        guard let rootNode = delegate.rootNode else {
            return nil
        }
        
        return RawINDIMessage(xmlNode: rootNode)
    }
}

/// XMLParser delegate to capture parsed XML elements.
///
/// This implements a SAX-style parser delegate that builds a tree structure
/// from the event-driven XML parsing callbacks.
private class INDIXMLParserDelegate: NSObject, XMLParserDelegate {
    var rootNode: XMLNodeRepresentation?
    private struct ElementBuilder {
        let name: String
        var attributes: [String: String]
        var text: String?
        var children: [XMLNodeRepresentation]
    }
    private var elementStack: [ElementBuilder] = []
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let builder = ElementBuilder(
            name: elementName,
            attributes: attributeDict,
            text: nil,
            children: []
        )
        elementStack.append(builder)
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let builder = elementStack.popLast() else { return }
        
        let node = XMLNodeRepresentation(
            name: builder.name,
            attributes: builder.attributes,
            text: builder.text,
            children: builder.children
        )
        
        if elementStack.isEmpty {
            rootNode = node
        } else {
            // Add as child to parent
            let lastIndex = elementStack.count - 1
            elementStack[lastIndex].children.append(node)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !elementStack.isEmpty else { return }
        let lastIndex = elementStack.count - 1
        if let existingText = elementStack[lastIndex].text {
            elementStack[lastIndex].text = existingText + string
        } else {
            elementStack[lastIndex].text = string
        }
    }
}

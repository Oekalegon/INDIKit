import Foundation
import os

/// A Sendable representation of an XML element.
struct XMLNodeRepresentation: Sendable {
    let name: String
    let attributes: [String: String]
    let text: String?
    let children: [XMLNodeRepresentation]
    
    init(name: String, attributes: [String: String] = [:], text: String? = nil, children: [XMLNodeRepresentation] = []) {
        self.name = name
        self.attributes = attributes
        self.text = text
        self.children = children
    }
}

/// Parser that converts a stream of raw Data chunks into parsed INDI XML properties.
///
/// This parser uses Foundation's XMLParser (a SAX-style parser) to parse XML properties.
/// It handles the fact that XML properties may arrive split across multiple Data chunks
/// by buffering incoming data and detecting complete XML elements by tracking tag depth.
///
/// The parser can handle properties larger than the 64KB chunk size from INDIServer
/// by accumulating chunks until a complete XML element is detected.
actor INDIXMLParser {
    private static let logger = Logger(subsystem: "com.indikit", category: "parsing")
    private var buffer = Data()
    
    /// Maximum buffer size in bytes before throwing an error.
    ///
    /// Default is 2GB, which should accommodate large FITS files and other
    /// astronomical data transfers via INDI BLOB messages. Set to a higher value
    /// if you expect even larger messages, or lower to limit memory usage.
    var maxBufferSize: Int = 2 * 1024 * 1024 * 1024 // 2GB
    
    /// Initialize a new XML parser.
    init() {
    }
    
    /// Parse a stream of Data chunks into a stream of INDIProperty objects.
    ///
    /// - Parameter dataStream: The stream of raw Data chunks from INDIServer
    /// - Returns: A stream of parsed INDIProperty objects
    func parse(_ dataStream: AsyncThrowingStream<Data, Error>) -> AsyncThrowingStream<INDIProperty, Error> {
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
    
    /// Process incoming data chunks, extracting and parsing complete XML properties.
    private func processData(
        _ data: Data,
        continuation: AsyncThrowingStream<INDIProperty, Error>.Continuation
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
        
        // Try to extract and parse complete XML properties
        // Properties are detected by finding complete root XML elements
        while let property = await extractAndParseNextMessage() {
            continuation.yield(property)
        }
    }
    
    /// Process any remaining data in the buffer after the stream ends.
    private func processRemainingBuffer(
        continuation: AsyncThrowingStream<INDIProperty, Error>.Continuation
    ) async {
        // Try to parse any remaining buffered data
        while let property = await extractAndParseNextMessage() {
            continuation.yield(property)
        }
    }
    
    /// Extract and parse the next complete XML property from the buffer.
    ///
    /// A complete property is detected by finding a complete root XML element
    /// (opening tag with matching closing tag, or self-closing tag).
    ///
    /// Returns nil if no complete property is available yet.
    private func extractAndParseNextMessage() async -> INDIProperty? {
        guard !buffer.isEmpty else { return nil }
        
        guard let bufferString = String(data: buffer, encoding: .utf8) else {
            // Invalid UTF-8, skip this byte
            let bufferSize = buffer.count
            Self.logger.warning(
                "Invalid UTF-8 data in buffer (size: \(bufferSize) bytes), skipping first byte"
            )
            buffer.removeFirst()
            return nil
        }
        
        // Find the start of the first XML element (skip leading whitespace)
        let whitespaceChars = CharacterSet.whitespacesAndNewlines
        guard let firstNonWhitespace = bufferString.rangeOfCharacter(from: whitespaceChars.inverted) else {
            // Only whitespace, clear buffer
            buffer.removeAll()
            return nil
        }
        
        let trimmedStart = firstNonWhitespace.lowerBound
        let trimmed = String(bufferString[trimmedStart...])
        
        // Find a complete XML element by tracking tag depth
        guard let elementRange = findCompleteXMLElement(in: trimmed) else {
            // No complete element found yet, wait for more data
            // Log if buffer is getting large (might indicate a problem)
            let bufferSize = buffer.count
            if bufferSize > 64 * 1024 {
                let preview = String(trimmed.prefix(200))
                Self.logger.debug(
                    "No complete XML element found yet (buffer: \(bufferSize) bytes). Preview: \(preview)..."
                )
            }
            return nil
        }
        
        let xmlString = String(trimmed[elementRange])
        
        // Try to parse this XML element
        guard let property = tryParseXML(xmlString) else {
            // Parsing failed, skip this element and continue
            let xmlLength = xmlString.count
            let preview = String(xmlString.prefix(200))
            let message = "Failed to parse XML element (length: \(xmlLength) bytes). " +
                "Skipping and continuing. Preview: \(preview)..."
            Self.logger.warning("\(message)")
            // Calculate the end position in the original bufferString
            let endInTrimmed = elementRange.upperBound
            let trimmedDistance = trimmed.distance(from: trimmed.startIndex, to: endInTrimmed)
            let endInOriginal = bufferString.index(trimmedStart, offsetBy: trimmedDistance)
            await removeFromBuffer(upTo: endInOriginal, in: bufferString)
            return nil
        }
        
        // Remove the parsed property from buffer
        // Calculate the end position in the original bufferString
        let endInTrimmed = elementRange.upperBound
        let trimmedDistance = trimmed.distance(from: trimmed.startIndex, to: endInTrimmed)
        let endInOriginal = bufferString.index(trimmedStart, offsetBy: trimmedDistance)
        await removeFromBuffer(upTo: endInOriginal, in: bufferString)
        return property
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
            let preview = String(string[start...].prefix(100))
            Self.logger.debug(
                "findCompleteElementWithClosingTag: failed to extract tag name. Preview: \(preview)..."
            )
            return nil
        }
        
        // Track depth to find the matching closing tag
        let openingTag = "<\(tagName)"
        let closingTag = "</\(tagName)>"
        var depth = 0
        var i = start
        var inQuotes = false
        var quoteChar: Character?
        
        while i < string.endIndex {
            let char = string[i]
            
            // Track quotes to avoid matching tags inside attribute values
            if !inQuotes && (char == "\"" || char == "'") {
                inQuotes = true
                quoteChar = char
            } else if inQuotes && char == quoteChar {
                inQuotes = false
                quoteChar = nil
            }
            
            if !inQuotes {
                if string[i...].hasPrefix(openingTag) && isTagBoundary(string, at: i, tag: openingTag) {
                    depth += 1
                }
                
                if string[i...].hasPrefix(closingTag) {
                    depth -= 1
                    if depth == 0 {
                        let tagEnd = string.index(i, offsetBy: closingTag.count)
                        return start..<tagEnd
                    }
                }
            }
            
            i = string.index(after: i)
        }
        
        return nil
    }
    
    /// Check if a tag at the given position is actually a tag boundary
    /// (followed by space, >, or /).
    private func isTagBoundary(_ string: String, at index: String.Index, tag: String) -> Bool {
        let afterTag = string.index(index, offsetBy: tag.count, limitedBy: string.endIndex) ?? string.endIndex
        guard afterTag < string.endIndex else { return false }
        let nextChar = string[afterTag]
        return nextChar == ">" || nextChar == " " || nextChar == "/"
    }
    
    /// Extract the tag name from an opening XML tag.
    private func extractTagName(from string: String, start: String.Index) -> String? {
        guard start < string.endIndex && string[start] == "<" else {
            Self.logger.debug("extractTagName: invalid start position or missing '<' character")
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
            let preview = String(string[start...].prefix(100))
            Self.logger.warning(
                "Failed to extract tag name: could not find tag name end. Preview: \(preview)..."
            )
            return nil
        }
        
        let tagNameStart = string.index(after: start)
        return String(string[tagNameStart..<end])
    }
    
    /// Remove data from buffer up to (and including) the specified index.
    private func removeFromBuffer(upTo index: String.Index, in string: String) async {
        let substring = String(string[string.startIndex..<index])
        guard let dataToRemove = substring.data(using: .utf8) else {
            Self.logger.warning(
                "removeFromBuffer: failed to convert substring to UTF-8 data. Buffer may become inconsistent."
            )
            return
        }
        
        let bytesToRemove = dataToRemove.count
        let bufferSize = buffer.count
        if bufferSize >= bytesToRemove {
            buffer.removeFirst(bytesToRemove)
        } else {
            let message = "removeFromBuffer: buffer size (\(bufferSize)) is less than " +
                "bytes to remove (\(bytesToRemove)). Buffer may become inconsistent."
            Self.logger.warning("\(message)")
        }
    }
    
    /// Try to parse a string as XML and return an INDIProperty if successful.
    private func tryParseXML(_ xmlString: String) -> INDIProperty? {
        guard let xmlData = xmlString.data(using: .utf8) else {
            Self.logger.warning("Failed to parse INDI property: could not convert XML string to UTF-8 data")
            return nil
        }
        
        let parser = XMLParser(data: xmlData)
        let delegate = INDIXMLParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            Self.logger.warning("Failed to parse INDI property: XML parsing failed")
            return nil
        }
        
        guard let rootNode = delegate.rootNode else {
            Self.logger.warning("Failed to parse INDI property: no root node found in parsed XML")
            return nil
        }
        
        guard let property = INDIProperty(xmlNode: rootNode) else {
            Self.logger.warning(
                "Failed to parse INDI property: could not create INDIProperty from element '\(rootNode.name)'"
            )
            return nil
        }
        
        return property
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

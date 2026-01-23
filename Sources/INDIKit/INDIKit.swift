import Foundation

/// INDIKit is a convenience module that re-exports all INDIKit modules.
///
/// Import `INDIKit` to get access to all functionality:
/// - `INDIProtocol`: Core protocol implementation
/// - `INDIState`: State management
/// - `INDIStateUI`: SwiftUI wrappers
///
/// For more granular control, you can import individual modules:
/// ```swift
/// import INDIProtocol  // Only protocol implementation
/// import INDIState     // Only state management
/// import INDIStateUI   // Only SwiftUI wrappers
/// ```
@_exported import INDIProtocol
@_exported import INDIState
@_exported import INDIStateUI


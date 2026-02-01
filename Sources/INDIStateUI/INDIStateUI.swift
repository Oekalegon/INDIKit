import Foundation
import INDIProtocol
import INDIState
import SwiftUI

/// INDIStateUI provides SwiftUI wrappers for INDI state management.
///
/// This module wraps INDIState's business logic with `@Observable` classes
/// to enable SwiftUI integration. It provides:
///
/// - ``ObservableINDIStateRegistry``: Observable wrapper for the INDI state registry
/// - ``ObservableINDIDevice``: Observable wrapper for INDI devices
/// - ``ObservableINDIProperty``: Observable wrappers for INDI properties
///
/// All business logic remains in the INDIState module, with INDIStateUI
/// providing only the observation layer for SwiftUI.
public enum INDIStateUI {
    // Module namespace - use ObservableINDIStateRegistry, ObservableINDIDevice, etc.
}

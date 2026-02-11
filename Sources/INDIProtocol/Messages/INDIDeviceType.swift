import Foundation

/// Represents the type of an INDI device based on its properties.
///
/// Device types are inferred from the properties that a device exposes.
/// A device may have properties from multiple types (e.g., a telescope mount
/// might also have focuser properties), but the primary type is determined
/// by counting which device type's properties are most prevalent.
public enum INDIDeviceType: String, Sendable, CaseIterable, Hashable {
    /// Telescope or mount device (equatorial/horizontal coordinates, tracking, etc.)
    case telescope
    
    /// Camera or CCD device (exposure, frame capture, temperature control, etc.)
    case camera
    
    /// Focuser device (focus position, speed, motion control, etc.)
    case focuser
    
    /// Filter wheel device (filter selection, filter names, etc.)
    case filterWheel
    
    /// Dome device (dome position, shutter control, park/unpark, etc.)
    case dome
    
    /// Rotator device (rotation control)
    case rotator
    
    /// GPS device (location, time synchronization)
    case gps
    
    /// Weather station device (temperature, pressure, humidity, etc.)
    case weather
    
    /// Light box device (light control for flat frames)
    case lightBox
    
    /// Input interface device (joystick, gamepad, etc.)
    case inputInterface
    
    /// Output interface device (relays, switches, etc.)
    case outputInterface
    
    /// Tilt Corrector
    case tiltCorrector
    
    /// Unknown or generic device type (no specific device type properties detected)
    case unknown
    
    /// Human-readable name for the device type.
    public var displayName: String {
        switch self {
        case .telescope: return "Telescope/Mount"
        case .camera: return "Camera/CCD"
        case .focuser: return "Focuser"
        case .filterWheel: return "Filter Wheel"
        case .dome: return "Dome"
        case .rotator: return "Rotator"
        case .gps: return "GPS"
        case .weather: return "Weather Station"
        case .lightBox: return "Light Box"
        case .inputInterface: return "Input Interface"
        case .outputInterface: return "Output Interface"
        case .tiltCorrector: return "Tilt Corrector"
        case .unknown: return "Unknown"
        }
    }
}

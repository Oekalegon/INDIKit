import Foundation

public enum INDIProperty: Sendable, CaseIterable {

    // MARK: General Properties
    case connection
    case devicePort
    case localSideralTime
    case universalTime
    case geographicCoordinates
    case atmosphere
    case uploadMode
    case uploadSettings
    case activeDevices

    // MARK: Telescope Properties
    case equatorialCoordinatesJ2000
    case equatorialCoordinatesEpoch
    case targetEquatorialCoordinatesEpoch
    case horizontalCoordinates
    case telescopeActionOnCoordinatesSet
    case telescopeMotionNorthSouth
    case telescopeMotionWestEast
    case telescopeTimedGuideNorthSouth
    case telescopeTimedGuideWestEast
    case telescopeSlewRate
    case telescopePark
    case telescopeParkPosition
    case telescopeParkOption
    case telescopeAbortMotion
    case telescopeTrackRate
    case telescopeInfo
    case telescopePierSide
    case telescopeHome
    case domePolicy
    case periodicErrorCorrection
    case telescopeTrackMode
    case telescopeTrackState
    case satelliteTLEText
    case satellitePassWindow
    case satelliteTrackingState
    case telescopeReverseMotion
    case motionControlMode
    case joystickLockAxis
    case simulatePierSide

    // MARK: CCD Properties
    // MARK: CCD Streaming Properties
    // MARK: Filter wheel Properties
    // MARK: Focuser Properties
    // MARK: Dome Properties
    // MARK: Input Interface Properties
    // MARK: Output Interface Properties
    // MARK: Light box Interface Properties
    // MARK: GPS Interface Properties
    // MARK: Weather Interface Properties
    // MARK: Rotator Interface Properties

    case other(String)

    public var indiName: String {
        switch self {
        case .connection: return "CONNECTION"
        case .devicePort: return "DEVICE_PORT"
        case .localSideralTime: return "TIME_LST"
        case .universalTime: return "TIME_UTC"
        case .geographicCoordinates: return "GEOGRAPHIC_COORD"
        case .atmosphere: return "ATMOSPHERE"
        case .uploadMode: return "UPLOAD_MODE"
        case .uploadSettings: return "UPLOAD_SETTINGS"
        case .activeDevices: return "ACTIVE_DEVICES"
        
        case .equatorialCoordinatesJ2000: return "EQUATORIAL_EOD_COORD"
        case .equatorialCoordinatesEpoch: return "EQUATORIAL_COORD"
        case .targetEquatorialCoordinatesEpoch: return "TARGET_COORD"
        case .horizontalCoordinates: return "HORIZONTAL_COORD"
        case .telescopeActionOnCoordinatesSet: return "ON_COORD_SET"
        case .telescopeMotionNorthSouth: return "TELESCOPE_TIMED_GUIDE_NS"
        case .telescopeMotionWestEast: return "TELESCOPE_TIMED_GUIDE_WE"
        case .telescopeTimedGuideNorthSouth: return "TELESCOPE_TIMED_GUIDE_NS"
        case .telescopeTimedGuideWestEast: return "TELESCOPE_TIMED_GUIDE_WE"
        case .telescopeSlewRate: return "TELESCOPE_SLEW_RATE"
        case .telescopePark: return "TELESCOPE_PARK"
        case .telescopeParkPosition: return "TELESCOPE_PARK_POSITION"
        case .telescopeParkOption: return "TELESCOPE_PARK_OPTION"
        case .telescopeAbortMotion: return "TELESCOPE_ABORT_MOTION"
        case .telescopeTrackRate: return "TELESCOPE_TRACK_RATE"
        case .telescopeInfo: return "TELESCOPE_INFO"
        case .telescopePierSide: return "TELESCOPE_PIER_SIDE"
        case .telescopeHome: return "TELESCOPE_HOME"
        case .domePolicy: return "DOME_POLICY"
        case .periodicErrorCorrection: return "PEC"
        case .telescopeTrackMode: return "TELESCOPE_TRACK_MODE"
        case .telescopeTrackState: return "TELESCOPE_TRACK_STATE"
        case .satelliteTLEText: return "SAT_TLE_TEXT"
        case .satellitePassWindow: return "SAT_PASS_WINDOW"
        case .satelliteTrackingState: return "SAT_TRACKING_STAT"
        case .telescopeReverseMotion: return "TELESCOPE_REVERSE_MOTION"
        case .motionControlMode: return "MOTION_CONTROL_MODE"
        case .joystickLockAxis: return "JOYSTICK_LOCK_AXIS"
        case .simulatePierSide: return "SIMULATE_PIER_SIDE"
        
        case .other(let name): return name
        }
    }
    
    /// A human-readable display name for the property with proper spacing and capitalization.
    public var displayName: String {
        switch self {
        case .connection: return "Connection"
        case .devicePort: return "Device Port"
        case .localSideralTime: return "Local Sidereal Time"
        case .universalTime: return "Universal Time"
        case .geographicCoordinates: return "Geographic Coordinates"
        case .atmosphere: return "Atmosphere"
        case .uploadMode: return "Upload Mode"
        case .uploadSettings: return "Upload Settings"
        case .activeDevices: return "Active Devices"
        case .equatorialCoordinatesJ2000: return "Equatorial Coordinates J2000"
        case .equatorialCoordinatesEpoch: return "Equatorial Coordinates Epoch"
        case .targetEquatorialCoordinatesEpoch: return "Target Equatorial Coordinates Epoch"
        case .horizontalCoordinates: return "Horizontal Coordinates"
        case .telescopeActionOnCoordinatesSet: return "Telescope Action On Coordinates Set"
        case .telescopeMotionNorthSouth: return "Telescope Motion North South"
        case .telescopeMotionWestEast: return "Telescope Motion West East"
        case .telescopeTimedGuideNorthSouth: return "Telescope Timed Guide North South"
        case .telescopeTimedGuideWestEast: return "Telescope Timed Guide West East"
        case .telescopeSlewRate: return "Telescope Slew Rate"
        case .telescopePark: return "Telescope Park"
        case .telescopeParkPosition: return "Telescope Park Position"
        case .telescopeParkOption: return "Telescope Park Option"
        case .telescopeAbortMotion: return "Telescope Abort Motion"
        case .telescopeTrackRate: return "Telescope Track Rate"
        case .telescopeInfo: return "Telescope Info"
        case .telescopePierSide: return "Telescope Pier Side"
        case .telescopeHome: return "Telescope Home"
        case .domePolicy: return "Dome Policy"
        case .periodicErrorCorrection: return "Periodic Error Correction"
        case .telescopeTrackMode: return "Telescope Track Mode"
        case .telescopeTrackState: return "Telescope Track State"
        case .satelliteTLEText: return "Satellite TLE Text"
        case .satellitePassWindow: return "Satellite Pass Window"
        case .satelliteTrackingState: return "Satellite Tracking State"
        case .telescopeReverseMotion: return "Telescope Reverse Motion"
        case .motionControlMode: return "Motion Control Mode"
        case .joystickLockAxis: return "Joystick Lock Axis"
        case .simulatePierSide: return "Simulate Pier Side"
        case .other(let name): return name
        }
    }

    public var type: INDIPropertyType? {
        switch self {
        case .connection: return .toggle
        case .devicePort: return .text
        case .localSideralTime: return .number
        case .universalTime: return .text
        case .geographicCoordinates: return .number
        case .atmosphere: return .number
        case .uploadMode: return .toggle
        case .uploadSettings: return .text
        case .activeDevices: return .text
        
        case .equatorialCoordinatesJ2000: return .number
        case .equatorialCoordinatesEpoch: return .number
        case .targetEquatorialCoordinatesEpoch: return .number
        case .horizontalCoordinates: return .number
        case .telescopeActionOnCoordinatesSet: return .toggle
        case .telescopeMotionNorthSouth: return .toggle
        case .telescopeMotionWestEast: return .toggle
        case .telescopeTimedGuideNorthSouth: return .number
        case .telescopeTimedGuideWestEast: return .number
        case .telescopeSlewRate: return .toggle
        case .telescopePark: return .toggle
        case .telescopeParkPosition: return .number
        case .telescopeParkOption: return .toggle
        case .telescopeAbortMotion: return .toggle
        case .telescopeTrackRate: return .number
        case .telescopeInfo: return .number
        case .telescopePierSide: return .toggle
        case .telescopeHome: return .toggle
        case .domePolicy: return .toggle
        case .periodicErrorCorrection: return .toggle
        case .telescopeTrackMode: return .toggle
        case .telescopeTrackState: return .toggle
        case .satelliteTLEText: return .text
        case .satellitePassWindow: return .text
        case .satelliteTrackingState: return .toggle
        case .telescopeReverseMotion: return .toggle
        case .motionControlMode: return .toggle
        case .joystickLockAxis: return .toggle
        case .simulatePierSide: return .toggle

        default: return nil
        }
    }
    
    /// Initialize from an INDI property name string.
    ///
    /// - Parameter indiName: The INDI property name (e.g., "CONNECTION", "TELESCOPE_PARK")
    /// - Returns: The matching property, or `.other(name)` if no known property matches
    public init(indiName: String) {
        if let found = Self.allCases.first(where: { $0.indiName == indiName }) {
            self = found
        } else {
            self = .other(indiName)
        }
    }
    
    // MARK: - CaseIterable
    
    /// All known property cases (excluding `.other` which has infinite possible values).
    public static var allCases: [INDIProperty] {
        [
            .connection,
            .devicePort,
            .localSideralTime,
            .universalTime,
            .geographicCoordinates,
            .atmosphere,
            .uploadMode,
            .uploadSettings,
            .activeDevices,
            .equatorialCoordinatesJ2000,
            .equatorialCoordinatesEpoch,
            .targetEquatorialCoordinatesEpoch,
            .horizontalCoordinates,
            .telescopeActionOnCoordinatesSet,
            .telescopeMotionNorthSouth,
            .telescopeMotionWestEast,
            .telescopeTimedGuideNorthSouth,
            .telescopeTimedGuideWestEast,
            .telescopeSlewRate,
            .telescopePark,
            .telescopeParkPosition,
            .telescopeParkOption,
            .telescopeAbortMotion,
            .telescopeTrackRate,
            .telescopeInfo,
            .telescopePierSide,
            .telescopeHome,
            .domePolicy,
            .periodicErrorCorrection,
            .telescopeTrackMode,
            .telescopeTrackState,
            .satelliteTLEText,
            .satellitePassWindow,
            .satelliteTrackingState,
            .telescopeReverseMotion,
            .motionControlMode,
            .joystickLockAxis,
            .simulatePierSide
        ]
    }
}

import Foundation

public enum INDIPropertyValueName: Sendable, CaseIterable, Equatable {

    // MARK: General Properties' values

    // Connection
    /// Connect to the device.
    /// 
    /// Value of ``INDIPropertyName/connection``.
    case connect

    /// Disconnect from the device.
    /// 
    /// Value of ``INDIPropertyName/connection``.
    case disconnect

    // Device Port
    /// Device connection port.
    /// 
    /// Value of ``INDIPropertyName/devicePort``.
    case port
    
    // Local Sideral Time
    /// Local sidereal time.
    /// 
    /// Value of ``INDIPropertyName/localSideralTime``.
    case localSideralTime
    
    // Universal Time
    /// Universal time.
    /// 
    /// Value of ``INDIPropertyName/universalTime``.
    case universalTime

    /// Offset from the universal time in hours (positive for east of Greenwich, negative for west of Greenwich).
    /// 
    /// Value of ``INDIPropertyName/universalTime``.
    case offset

    // Geographic Coordinates
    /// Latitude of the site in degrees (positive for north of the equator, negative for south of the equator).
    /// 
    /// Value of ``INDIPropertyName/geographicCoordinates``.
    case latitude

    /// Longitude of the site in degrees (positive for east of Greenwich, negative for west of Greenwich).
    /// 
    /// Value of ``INDIPropertyName/geographicCoordinates``.
    case longitude

    /// Elevation of the site in meters above sea level.
    /// 
    /// Value of ``INDIPropertyName/geographicCoordinates``.
    case elevation

    // Atmosphere
    /// Temperature of the atmosphere in Kelvin.
    /// 
    /// Value of ``INDIPropertyName/atmosphere``.
    case temperature

    /// Pressure of the atmosphere in hectopascals.
    /// 
    /// Value of ``INDIPropertyName/atmosphere``.
    case pressure

    /// Humidity of the atmosphere in percent.
    /// 
    /// Value of ``INDIPropertyName/atmosphere``.
    case humidity

    // Upload Mode
    /// Upload data to the client.
    /// 
    /// Value of ``INDIPropertyName/uploadMode``.
    case uploadClient

    /// Save data locally to the server.
    /// 
    /// Value of ``INDIPropertyName/uploadMode``.
    case uploadLocal

    /// Send the data to the client and save it locally to the server.
    /// 
    /// Value of ``INDIPropertyName/uploadMode``.
    case uploadBoth

    // Upload Settings
    /// Upload directory if the data is saved locally.
    /// 
    /// Value of ``INDIPropertyName/uploadSettings``.
    case uploadDirectory

    /// Upload prefix to the file name.
    /// 
    /// Value of ``INDIPropertyName/uploadSettings``.
    case uploadPrefix

    // Active Devices
    /// Name of the active telescope.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
    case activeTelescope

    /// Name of the active camera.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
    case activeCamera
    case activeFilterWheel

    /// Name of the active focuser.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
    case activeFocuser

    /// Name of the active dome.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
    case activeDome

    /// Name of the active GPS device.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
    case activeGPS

    // Equatorial Coordinates J2000
    /// Right Ascension of the target in hours.
    /// 
    /// Value of ``INDIPropertyName/equatorialCoordinatesJ2000``.
    case rightAscension

    /// Declination of the target in degrees.
    /// 
    /// Value of ``INDIPropertyName/equatorialCoordinatesJ2000``.
    case declination

    /// Azimuth of the target in degrees. 0° is North, 90° is East, 
    /// 180° is South, 270° is West.
    /// 
    /// Value of ``INDIPropertyName/horizontalCoordinates``.
    case azimuth

    /// Altitude of the target in degrees. 0° is horizon, 90° is zenith.
    /// 
    /// Value of ``INDIPropertyName/horizontalCoordinates``.
    case altitude

    /// If in this mode, the telescope will slew to the coordinates it 
    /// recieves from the client after this property is set.
    /// and stop upon reaching the target coordinates.
    /// 
    /// The coordinates are set by the ciient on the property
    /// ``INDIPropertyName/equatorialCoordinatesEpoch``.
    /// 
    /// Value of ``INDIPropertyName/telescopeActionOnCoordinatesSet``.
    case slew

    /// If in this mode, the telescope will slew to the coordinates
    /// it recieves from the client after this property is set.
    /// and continue tracking the target.
    /// 
    /// The coordinates are set by the ciient on the property
    /// ``INDIPropertyName/targetEquatorialCoordinatesEpoch``.
    /// 
    /// Value of ``INDIPropertyName/telescopeActionOnCoordinatesSet``.
    case track

    /// If in this mode, the telescope will synchronize the coordinates it thinks
    /// it is at to the coordinates it recieves from the client after this 
    /// property is set.
    /// 
    /// This is useful when the client needs to correct the telescope's position,
    /// probably after plate solving determined the telescope's exact position.
    /// 
    /// The coordinates are set by the ciient on the property
    /// ``INDIPropertyName/targetEquatorialCoordinatesEpoch``.
    /// 
    /// Value of ``INDIPropertyName/telescopeActionOnCoordinatesSet``.
    case synchronize

    /// Move the telescope north.
    /// 
    /// Value of ``INDIPropertyName/telescopeMotionNorthSouth``.
    case motionNorth

    /// Move the telescope south.
    /// 
    /// Value of ``INDIPropertyName/telescopeMotionNorthSouth``.
    case motionSouth

    /// Move the telescope west.
    /// 
    /// Value of ``INDIPropertyName/telescopeMotionWestEast``.
    case motionWest

    /// Move the telescope east.
    /// 
    /// Value of ``INDIPropertyName/telescopeMotionWestEast``.
    case motionEast

    /// Move the telescope north  for the specified number of 
    /// milliseconds.
    /// 
    /// Value of ``INDIPropertyName/telescopeTimedGuideNorthSouth``.
    case timedGuideNorth

    /// Move the telescope south for the specified number of 
    /// milliseconds.
    /// 
    /// Value of ``INDIPropertyName/telescopeTimedGuideNorthSouth``.
    case timedGuideSouth

    /// Move the telescope north for the specified number of 
    /// milliseconds.
    /// 
    /// Value of ``INDIPropertyName/telescopeTimedGuideWestEast``.
    case timedGuideWest

    /// Move the telescope east for the specified number of 
    /// milliseconds.
    /// 
    /// Value of ``INDIPropertyName/telescopeTimedGuideWestEast``.
    case timedGuideEast

    /// The slowest slew rate of the telescope, 0.5x to 1.0x the
    /// sidereal speed.
    /// 
    /// Value of ``INDIPropertyName/telescopeSlewRate``.
    case slewRateGuide

    /// Slow slew rate. Often used for centering the field of view.
    /// 
    /// Value of ``INDIPropertyName/telescopeSlewRate``.
    case slewRateCentering

    /// Medium slew rate. Often used for finding the desired field of view.
    /// 
    /// Value of ``INDIPropertyName/telescopeSlewRate``.
    case slewRateFind

    /// The maximum slew rate of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeSlewRate``.
    case slewRateMaximum

    /// Park the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopePark``.
    case park

    /// Unpark the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopePark``.
    case unpark

    /// The right ascension of the home park position.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkPosition``.
    case parkRightAscension

    /// The declination of the home park position.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkPosition``.
    case parkDeclination

    /// The azimuth of the home park position.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkPosition``.
    case parkAzimuth

    /// The altitude of the home park position.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkPosition``.
    case parkAltitude

    /// Sets the current position of the telescope as the home park position.
    /// 
    /// This will in effect set ``INDIPropertyName/telescopeParkPosition`` 
    /// to the current position of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkOption``.
    case parkCurrentPosition

    /// Sets the default position of the telescope driver as the home park position.
    /// 
    /// This will in effect set ``INDIPropertyName/telescopeParkPosition`` 
    /// to the default position of the telescope driver. This is typically
    /// when the counterweight points down or pointing to the pole.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkOption``.
    case parkDefaultPosition

    /// Write the home park position to the telescope driver so that the park
    /// poisition is retained after a power cycle.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkOption``.
    case parkWriteData

    /// Purge the home park position data from the telescope driver.
    /// 
    /// This will in effect set ``INDIPropertyName/telescopeParkPosition`` 
    /// to an empty value or to the driver's default position.
    /// 
    /// Value of ``INDIPropertyName/telescopeParkOption``.
    case parkPurgeData

    /// Abort the current motion of the telescope rapidly, but gracefully.
    /// 
    /// Value of ``INDIPropertyName/telescopeAbortMotion``.
    case abortMotion

    /// The track rate of the telescope in arcseconds per second for the right ascension.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackRate``.
    case trackRateRightAscension

    /// The track rate of the telescope in arcseconds per second for the declination.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackRate``.
    case trackRateDeclination

    /// The aperture of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeInfo``.
    case telescopeAperture

    /// The focal length of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeInfo``.
    case telescopeFocalLength

    /// The aperture of the guide scope.
    /// 
    /// Value of ``INDIPropertyName/telescopeInfo``.
    case guiderScopeAperture

    /// The focal length of the guide scope.
    /// 
    /// Value of ``INDIPropertyName/telescopeInfo``.
    case guiderScopeFocalLength

    /// The telescope is on the east side of the pier pointing west.
    /// 
    /// Value of ``INDIPropertyName/telescopePierSide``.
    case pierSideEast

    /// The telescope is on the west side of the pier pointing east.
    /// 
    /// Value of ``INDIPropertyName/telescopePierSide``.
    case pierSideWest

    /// Find the home position of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeHome``.
    case findHome

    /// Set the home position of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeHome``.
    case setHome

    /// Go to the home position of the telescope.
    /// 
    /// Value of ``INDIPropertyName/telescopeHome``.
    case goHome

    /// Ignore the dome status.
    /// 
    /// Value of ``INDIPropertyName/domePolicy``.
    case domeIgnore

    /// Prevent the telescope from moving when the dome is parked (closed).
    /// 
    /// Value of ``INDIPropertyName/domePolicy``.
    case domeLocks

    /// Enable the periodic error correction.
    /// 
    /// Value of ``INDIPropertyName/periodicErrorCorrection``.
    case periodicErrorCorrectionOn

    /// Disable the periodic error correction.
    /// 
    /// Value of ``INDIPropertyName/periodicErrorCorrection``.
    case periodicErrorCorrectionOff

    /// The default sidereal track rate.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackMode``.
    case trackRateSidereal

    /// The solar track rate.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackMode``.
    case trackRateSolar

    /// The lunar track rate.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackMode``.
    case trackRateLunar

    /// A custom track rate, specified by the client on the property
    /// ``INDIPropertyName/telescopeTrackRate``.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackMode``.
    case trackRateCustom

    /// Enable the telescope tracking.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackState``.
    case trackStateOn

    /// Disable the telescope tracking.
    /// 
    /// Value of ``INDIPropertyName/telescopeTrackState``.
    case trackStateOff

    /// The satellite TLE orbital solution for tracking earth-orbiting satellites.
    /// 
    /// Value of ``INDIPropertyName/satelliteTLE``.
    case satelliteTLE

    /// The start time of the pass window for the satellite tracking.
    /// 
    /// Value of ``INDIPropertyName/satellitePassWindow``.
    case satellitePassWindowStart

    /// The end time of the pass window for the satellite tracking.
    /// 
    /// Value of ``INDIPropertyName/satellitePassWindow``.
    case satellitePassWindowEnd

    /// The satellite tracking is active.
    /// 
    /// Value of ``INDIPropertyName/satelliteTrackingState``.
    case satelliteTrackingActive

    /// The satellite tracking is halted.
    /// 
    /// Value of ``INDIPropertyName/satelliteTrackingState``.
    case satelliteTrackingHalted

    /// Reverse the telescope motion for the north-south direction. This will
    /// invert the effect of the ``motionNorth`` and ``motionSouth`` properties.
    /// 
    /// Value of ``INDIPropertyName/telescopeReverseMotion``.
    case reverseNorthSouth

    /// Reverse the telescope motion for the west-east direction. This will
    /// invert the effect of the ``motionWest`` and ``motionEast`` properties.
    /// 
    /// Value of ``INDIPropertyName/telescopeReverseMotion``.
    case reverseWestEast

    /// A 4-Way joystick.
    /// 
    /// Value of ``INDIPropertyName/motionControlMode``.
    case motionControlModeJoystick

    /// A 2-Axis joystick.
    /// 
    /// Value of ``INDIPropertyName/motionControlMode``.
    case motionControlModeAxes

    /// Lock the west-east axis of the joystick.
    /// 
    /// Value of ``INDIPropertyName/joystickLockAxis``. 
    case lockAxisWestEast

    /// Lock the north-south axis of the joystick.
    /// 
    /// Value of ``INDIPropertyName/joystickLockAxis``.
    case lockAxisNorthSouth

    /// Simulate the pier side of the telescope for mounts that do not report
    /// the actual pier side.
    /// 
    /// Value of ``INDIPropertyName/simulatePierSide``.
    case simulateYes

    /// Do not simulate the pier side of the telescope.
    /// 
    /// Value of ``INDIPropertyName/simulatePierSide``.
    case simulateNo

    case other(String)

    public var indiName: String {
        switch self {
        case .connect: return "CONNECT"
        case .disconnect: return "DISCONNECT"
        case .port: return "PORT"
        case .localSideralTime: return "LST"
        case .universalTime: return "UTC"
        case .offset: return "OFFSET"
        case .latitude: return "LAT"
        case .longitude: return "LON"
        case .elevation: return "ELEV"
        case .temperature: return "TEMPERATURE"
        case .pressure: return "PRESSURE"
        case .humidity: return "HUMIDITY"
        case .uploadClient: return "UPLOAD_CLIENT"
        case .uploadLocal: return "UPLOAD_LOCAL"
        case .uploadBoth: return "UPLOAD_BOTH"
        case .uploadDirectory: return "UPLOAD_DIR"
        case .uploadPrefix: return "UPLOAD_PREFIX"
        case .activeTelescope: return "ACTIVE_TELESCOPE"
        case .activeCamera: return "ACTIVE_CCD"
        case .activeFilterWheel: return "ACTIVE_FILTER"
        case .activeFocuser: return "ACTIVE_FOCUSER"
        case .activeDome: return "ACTIVE_DOME"
        case .activeGPS: return "ACTIVE_GPS"
        case .rightAscension: return "RA"
        case .declination: return "DEC"
        case .azimuth: return "AZIMUTH"
        case .altitude: return "ALTITUDE"
        case .slew: return "SLEW"
        case .track: return "TRACK"
        case .synchronize: return "SYNC"
        case .motionNorth: return "MOTION_NORTH"
        case .motionSouth: return "MOTION_SOUTH"
        case .motionWest: return "MOTION_WEST"
        case .motionEast: return "MOTION_EAST"
        case .timedGuideNorth: return "TIMED_GUIDE_N"
        case .timedGuideSouth: return "TIMED_GUIDE_S"
        case .timedGuideWest: return "TIMED_GUIDE_W"
        case .timedGuideEast: return "TIMED_GUIDE_E"
        case .slewRateGuide: return "SLEW_GUIDE"
        case .slewRateCentering: return "SLEW_CENTERING"
        case .slewRateFind: return "SLEW_FIND"
        case .slewRateMaximum: return "SLEW_MAX"
        case .park: return "PARK"
        case .unpark: return "UNPARK"
        case .parkRightAscension: return "PARK_RA"
        case .parkDeclination: return "PARK_DEC"
        case .parkAzimuth: return "PARK_AZ"
        case .parkAltitude: return "PARK_ALT"
        case .parkCurrentPosition: return "PARK_CURRENT"
        case .parkDefaultPosition: return "PARK_DEFAULT"
        case .parkWriteData: return "PARK_WRITE_DATA"
        case .parkPurgeData: return "PARK_PURGE_DATA"
        case .abortMotion: return "ABORT_MOTION"
        case .trackRateRightAscension: return "TRACK_RATE_RA"
        case .trackRateDeclination: return "TRACK_RATE_DEC"
        case .telescopeAperture: return "TELESCOPE_APERTURE"
        case .telescopeFocalLength: return "TELESCOPE_FOCAL_LENGTH"
        case .guiderScopeAperture: return "GUIDER_APERTURE"
        case .guiderScopeFocalLength: return "GUIDER_FOCAL_LENGTH"
        case .pierSideEast: return "PIER_EAST"
        case .pierSideWest: return "PIER_WEST"
        case .findHome: return "FIND"
        case .setHome: return "SET"
        case .goHome: return "GO"
        case .domeIgnore: return "DOME_IGNORED"
        case .domeLocks: return "DOME_LOCKS"
        case .periodicErrorCorrectionOn: return "PEC_ON"
        case .periodicErrorCorrectionOff: return "PEC_OFF"
        case .trackRateSidereal: return "TRACK_SIDEREAL"
        case .trackRateSolar: return "TRACK_SOLAR"
        case .trackRateLunar: return "TRACK_LUNAR"
        case .trackRateCustom: return "TRACK_CUSTOM"
        case .trackStateOn: return "TRACK_ON"
        case .trackStateOff: return "TRACK_OFF"
        case .satelliteTLE: return "TLE"
        case .satellitePassWindowStart: return "SAT_PASS_WINDOW_START"
        case .satellitePassWindowEnd: return "SAT_PASS_WINDOW_END"
        case .satelliteTrackingActive: return "SAT_TRACK"
        case .satelliteTrackingHalted: return "SAT_HALT"
        case .reverseNorthSouth: return "REVERSE_NS"
        case .reverseWestEast: return "REVERSE_WE"
        case .motionControlModeJoystick: return "MOTION_CONTROL_MODE_JOYSTICK"
        case .motionControlModeAxes: return "MOTION_CONTROL_MODE_AXES"
        case .lockAxisWestEast: return "LOCK_AXIS_1"
        case .lockAxisNorthSouth: return "LOCK_AXIS_2"
        case .simulateYes: return "SIMULATE_YES"
        case .simulateNo: return "SIMULATE_NO"
        case .other(let name): return name
        }
    }

    private static let expectedValueNamesMap: [INDIPropertyName: [INDIPropertyValueName]] = [
        .connection: [.connect, .disconnect],
        .devicePort: [.port],
        .localSideralTime: [.localSideralTime],
        .universalTime: [.universalTime, .offset],
        .geographicCoordinates: [.latitude, .longitude, .elevation],
        .atmosphere: [.temperature, .pressure, .humidity],
        .uploadMode: [.uploadClient, .uploadLocal, .uploadBoth],
        .uploadSettings: [.uploadDirectory, .uploadPrefix],
        .activeDevices: [.activeTelescope, .activeCamera, .activeFilterWheel, .activeFocuser, .activeDome, .activeGPS],
        .equatorialCoordinatesJ2000: [.rightAscension, .declination],
        .equatorialCoordinatesEpoch: [.rightAscension, .declination],
        .targetEquatorialCoordinatesEpoch: [.rightAscension, .declination],
        .horizontalCoordinates: [.azimuth, .altitude],
        .telescopeActionOnCoordinatesSet: [.slew, .track, .synchronize],
        .telescopeMotionNorthSouth: [.motionNorth, .motionSouth],
        .telescopeMotionWestEast: [.motionWest, .motionEast],
        .telescopeTimedGuideNorthSouth: [.timedGuideNorth, .timedGuideSouth],
        .telescopeTimedGuideWestEast: [.timedGuideWest, .timedGuideEast],
        .telescopeSlewRate: [.slewRateGuide, .slewRateCentering, .slewRateFind, .slewRateMaximum],
        .telescopePark: [.park, .unpark],
        .telescopeParkPosition: [.parkRightAscension, .parkDeclination, .parkAzimuth, .parkAltitude],
        .telescopeParkOption: [.parkCurrentPosition, .parkDefaultPosition, .parkWriteData, .parkPurgeData],
        .telescopeAbortMotion: [.abortMotion],
        .telescopeTrackRate: [.trackRateRightAscension, .trackRateDeclination],
        .telescopeInfo: [.telescopeAperture, .telescopeFocalLength, .guiderScopeAperture, .guiderScopeFocalLength],
        .telescopePierSide: [.pierSideEast, .pierSideWest],
        .telescopeHome: [.findHome, .setHome, .goHome],
        .domePolicy: [.domeIgnore, .domeLocks],
        .periodicErrorCorrection: [.periodicErrorCorrectionOn, .periodicErrorCorrectionOff],
        .telescopeTrackMode: [.trackRateSidereal, .trackRateSolar, .trackRateLunar, .trackRateCustom],
        .telescopeTrackState: [.trackStateOn, .trackStateOff],
        .satelliteTLE: [.satelliteTLE],
        .satellitePassWindow: [.satellitePassWindowStart, .satellitePassWindowEnd],
        .satelliteTrackingState: [.satelliteTrackingActive, .satelliteTrackingHalted],
        .telescopeReverseMotion: [.reverseNorthSouth, .reverseWestEast],
        .motionControlMode: [.motionControlModeJoystick, .motionControlModeAxes],
        .joystickLockAxis: [.lockAxisWestEast, .lockAxisNorthSouth],
        .simulatePierSide: [.simulateYes, .simulateNo]
    ]

    public func expectedValueNames(for property: INDIPropertyName) -> [INDIPropertyValueName]? {
        Self.expectedValueNamesMap[property]
    }

    /// All known value name cases (excluding `.other` which has infinite possible values).
    public static var allCases: [INDIPropertyValueName] {
        [
            .connect, .disconnect, .port, .localSideralTime, .universalTime, .offset,
            .latitude, .longitude, .elevation, .temperature, .pressure, .humidity,
            .uploadClient, .uploadLocal, .uploadBoth, .uploadDirectory, .uploadPrefix,
            .activeTelescope, .activeCamera, .activeFilterWheel, .activeFocuser, .activeDome,
            .activeGPS, .rightAscension, .declination, .azimuth, .altitude, .slew, 
            .track, .synchronize, .motionNorth, .motionSouth, .motionWest, .motionEast,
            .timedGuideNorth, .timedGuideSouth, .timedGuideWest, .timedGuideEast,
            .slewRateGuide, .slewRateCentering, .slewRateFind, .slewRateMaximum,
            .park, .unpark, .parkRightAscension, .parkDeclination, .parkAzimuth, .parkAltitude,
            .parkCurrentPosition, .parkDefaultPosition, .parkWriteData, .parkPurgeData, .abortMotion,
            .trackRateRightAscension, .trackRateDeclination, .telescopeAperture, .telescopeFocalLength,
            .guiderScopeAperture, .guiderScopeFocalLength, .pierSideEast, .pierSideWest,
            .findHome, .setHome, .goHome, .domeIgnore, .domeLocks, 
            .periodicErrorCorrectionOn, .periodicErrorCorrectionOff,
            .trackRateSidereal, .trackRateSolar, .trackRateLunar, .trackRateCustom,
            .trackStateOn, .trackStateOff, .satelliteTLE, .satellitePassWindowStart, 
            .satellitePassWindowEnd, .satelliteTrackingActive, .satelliteTrackingHalted,
            .reverseNorthSouth, .reverseWestEast, .motionControlModeJoystick, 
            .motionControlModeAxes, .lockAxisWestEast, .lockAxisNorthSouth,
            .simulateYes, .simulateNo
        ]
    }
    
    /// Initialize from an INDI value name string.
    ///
    /// - Parameter indiName: The INDI value name (e.g., "CONNECT", "LAT", "TEMPERATURE")
    /// - Returns: The matching value name, or `.other(name)` if no known value name matches
    public init(indiName: String) {
        // Try to find a known value name by matching INDI name
        if let found = Self.allCases.first(where: { $0.indiName == indiName }) {
            self = found
        } else {
            self = .other(indiName)
        }
    }
}

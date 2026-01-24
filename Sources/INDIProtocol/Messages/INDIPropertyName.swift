import Foundation

// swiftlint:disable:next orphaned_doc_comment
/// Standard INDI property names.
/// 
/// This enum contains the standard INDI property names as defined in the INDI protocol.
/// Use these to identify the standard properties of an INDI device. Other properties are
/// possible. The device driver can define additional properties.
/// 
/// See [INDI Property Names](https://www.indilib.org/doc/v1.8/protocol/properties.html) for more information.
/// 
/// ## Topics
/// 
/// ### General Properties
/// - ``connection``
/// - ``devicePort``
/// - ``localSideralTime``
/// - ``universalTime``
/// - ``geographicCoordinates``
/// - ``atmosphere``
/// - ``uploadMode``
/// - ``uploadSettings``
/// - ``activeDevices``
/// 
/// ### Telescope Properties
/// - ``equatorialCoordinatesJ2000``
/// - ``equatorialCoordinatesEpoch``
/// - ``targetEquatorialCoordinatesEpoch``
/// - ``horizontalCoordinates``
/// - ``telescopeActionOnCoordinatesSet``
/// - ``telescopeMotionNorthSouth``
/// - ``telescopeMotionWestEast``
/// - ``telescopeTimedGuideNorthSouth``
/// - ``telescopeTimedGuideWestEast``
/// - ``telescopeSlewRate``
/// - ``telescopePark``
/// - ``telescopeParkPosition``
/// - ``telescopeParkOption``
/// - ``telescopeAbortMotion``
/// - ``telescopeTrackRate``
/// - ``telescopeInfo``
/// - ``telescopePierSide``
/// - ``telescopeHome``
/// - ``domePolicy``
/// - ``periodicErrorCorrection``
/// - ``telescopeTrackMode``
/// - ``telescopeTrackState``
/// - ``satelliteTLE``
/// - ``satellitePassWindow``
/// - ``satelliteTrackingState``
/// - ``telescopeReverseMotion``
/// - ``motionControlMode``
/// - ``joystickLockAxis``
/// - ``simulatePierSide``
/// 
/// ### Camera/CCD Properties
/// - ``ccdExposureTime``
/// - ``ccdAbortExposure``
/// - ``ccdFrame``
/// - ``ccdTemperature``
/// - ``ccdCooler``
/// - ``ccdFrameType``
/// - ``ccdBinning``
/// - ``ccdCompression``
/// - ``ccdFrameReset``
/// - ``ccdInfo``
/// - ``ccdColorFilterArray``
/// - ``ccd1``
/// - ``ccd2``
/// - ``ccdTemperatureCoolerRampParameters``
/// - ``worldCoordinateSystemKeywordInclusion``
/// - ``ccdRotation``
/// - ``ccdCaptureFormat``
/// - ``ccdTransferFormat``
/// - ``ccdFilePath``
/// - ``ccdFastToggle``
/// - ``ccdFastCount``
/// - ``fitsHeader``
/// 
/// ### Camera/CCD Streaming Properties
/// - ``ccdVideoStream``
/// - ``streamDelay``
/// - ``streamingExposureTime``
/// - ``framesPerSecond``
/// - ``ccdStreamingFrameSize``
/// - ``ccdStreamEncoder``
/// - ``ccdStreamRecorder``
/// - ``limits``
/// - ``recordFile``
/// - ``recordOptions``
/// - ``recordStream``
/// 
/// ### Filter Wheel Properties
/// - ``filterSlot``
/// - ``filterName``
/// 
/// ### Focuser Properties
/// - ``focusSpeed``
/// - ``focusMotion``
/// - ``focusTimer``
/// - ``relativeFocusPosition``
/// - ``absoluteFocusPosition``
/// - ``focusMax``
/// - ``focusReverseMotion``
/// - ``focusAbortMotion``
/// - ``focusSync``
/// 
// swiftlint:disable:next type_body_length
public enum INDIPropertyName: Sendable, CaseIterable, Hashable {

    // MARK: General Properties

    /// A switch to toggle the connection to the device on or off.
    /// The supported values are:
    /// - ``INDIPropertyValueName/connect`` to connect to the device
    /// - ``INDIPropertyValueName/disconnect`` to disconnect from the device
    case connection

    /// The device connection port.
    /// 
    /// The supported value is:
    /// - ``INDIPropertyValueName/port`` the port of the device.
    case devicePort

    /// The local sidereal time (LST).
    /// 
    /// The supported value is:
    /// - ``INDIPropertyValueName/localSideralTime`` the local sidereal time.
    case localSideralTime

    /// The universal time (UTC).
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/universalTime`` the universal time.
    /// - ``INDIPropertyValueName/offset`` the offset from the universal time in 
    /// hours (positive for east of Greenwich, negative for west of Greenwich).
    case universalTime

    /// The geographic coordinates (latitude, longitude, and elevation).
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/latitude`` the latitude of the site in degrees 
    /// (positive for north of the equator, negative for south of the equator).
    /// - ``INDIPropertyValueName/longitude`` the longitude of the site in degrees
    /// (positive for east of Greenwich, negative for west of Greenwich).
    /// - ``INDIPropertyValueName/elevation`` the elevation of the site in meters 
    /// above sea level.
    case geographicCoordinates

    /// The atmospheric conditions (temperature, pressure, and humidity).
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/temperature`` the temperature of the atmosphere in Kelvin.
    /// - ``INDIPropertyValueName/pressure`` the pressure of the atmosphere in hectopascals.
    /// - ``INDIPropertyValueName/humidity`` the humidity of the atmosphere in percent.
    case atmosphere

    /// A switch to toggle the upload mode on or off.
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/uploadClient`` to upload data to the client
    /// - ``INDIPropertyValueName/uploadLocal`` to save data locally to the server
    /// - ``INDIPropertyValueName/uploadBoth`` to send the data to the client and save it locally to the server.
    case uploadMode

    /// The upload settings.
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/uploadDirectory`` upload directory if the data is saved locally.
    /// - ``INDIPropertyValueName/uploadPrefix`` to set the upload prefix to the file name.
    case uploadSettings

    /// The active devices.
    /// 
    /// It is used to provide the user with a list of the connecter devices
    /// (whose connection status is ``INDIPropertyValueName/connect``). For example,
    /// for a Camera, the client may set this property to the name of the 
    /// telescope. Once set, the Camera (CCD driver) may automatically fill in
    /// the telescope information (including postioning) in the frame header.
    /// 
    /// The allowed values are:
    /// - ``INDIPropertyValueName/activeTelescope`` the name of the active telescope
    /// - ``INDIPropertyValueName/activeCamera`` the name of the active camera
    /// - ``INDIPropertyValueName/activeFilterWheel`` the name of the active filter wheel
    /// - ``INDIPropertyValueName/activeFocuser`` the name of the active focuser
    /// - ``INDIPropertyValueName/activeDome`` the name of the active dome
    /// - ``INDIPropertyValueName/activeGPS`` the name of the active GPS device
    case activeDevices

    // MARK: Telescope Properties

    /// The equatorial coordinates (J2000).
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/rightAscension`` the Right Ascension of the target in hours.
    /// - ``INDIPropertyValueName/declination`` the Declination of the target in degrees.
    case equatorialCoordinatesJ2000

    /// The equatorial coordinates (epoch of the date).
    /// 
    /// This property can be set by the client to slew the telescope to this position.
    /// The action is determined by the property 
    /// ``INDIPropertyName/telescopeActionOnCoordinatesSet``.
    /// The telescope position can also be set by inputting the horizontal coordinates
    /// on the property ``INDIPropertyName/horizontalCoordinates``.
    /// 
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/rightAscension`` the Right Ascension of the target in hours.
    /// - ``INDIPropertyValueName/declination`` the Declination of the target in degrees.
    case equatorialCoordinatesEpoch

    /// The slew target equatorial coordinates (epoch of the date).
    /// 
    /// Property set once ``equatorialCoordinatesEpoch`` is accepted by the driver.
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/rightAscension`` the Right Ascension of the target in hours.
    /// - ``INDIPropertyValueName/declination`` the Declination of the target in degrees.
    case targetEquatorialCoordinatesEpoch

    /// The horizontal/topocentric coordinates (altitude and azimuth).
    /// 
    /// This property can be set by the client to slew the telescope to this position.
    /// The action is determined by the property 
    /// ``INDIPropertyName/telescopeActionOnCoordinatesSet``.
    /// The telescope position can also be set by inputting the equatorial coordinates
    /// on the property ``INDIPropertyName/equatorialCoordinatesEpoch``.
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/altitude`` the altitude of the target in degrees.
    /// - ``INDIPropertyValueName/azimuth`` the azimuth of the target in degrees.
    case horizontalCoordinates

    /// The telescope action on coordinates set.
    /// 
    /// This property is set by the client to indicate the action to take
    /// when the coordinates are set. 
    /// 
    /// - If this property is set to 
    /// ``INDIPropertyValueName/slew``, the telescope will slew to the 
    /// coordinates it recieves from the client after this property is set
    /// and stop upon reaching the target coordinates.
    /// - If this property is set to ``INDIPropertyValueName/track``, the telescope 
    /// will slew to the coordinates it recieves from the client after this property
    /// is set and continue tracking the target.
    ///     
    /// - If this property is set to ``INDIPropertyValueName/synchronize``, the telescope 
    /// will synchronize the coordinates it thinks it is at to the coordinates it recieves 
    /// from the client after this property is set.
    /// This is useful when the client needs to correct the telescope's position,
    /// probably after plate solving determined the telescope's exact position.
    /// 
    /// The coordinates are set by the ciient on the property
    /// ``INDIPropertyName/targetEquatorialCoordinatesEpoch``.
    case telescopeActionOnCoordinatesSet

    /// Move the telescope north or south.
    /// *Note: This property is solely used as a command, it is not a state property.*
    /// 
    /// Setting this property will cause the telescope to move north or south
    /// at a constant speed. The speed is set by the client on the property
    /// ``INDIPropertyName/telescopeSlewRate``.
    /// 
    /// This can be used to move the telescope manually by the user.
    /// 
    /// Supported values are:
    /// - ``INDIPropertyValueName/motionNorth`` to move the telescope north.
    /// - ``INDIPropertyValueName/motionSouth`` to move the telescope south.
    case telescopeMotionNorthSouth

    /// Move the telescope west or east.
    /// *Note: This property is solely used as a command, it is not a state property.*
    /// 
    /// Setting this property will cause the telescope to move west or east
    /// at a constant speed. The speed is set by the client on the property
    /// ``INDIPropertyName/telescopeSlewRate``.
    /// 
    /// This can be used to move the telescope manually by the user.
    /// 
    /// Supported values are:
    /// - ``INDIPropertyValueName/motionWest`` to move the telescope west.
    /// - ``INDIPropertyValueName/motionEast`` to move the telescope east.
    case telescopeMotionWestEast

    /// Move the telescope north or south for the specified number of 
    /// milliseconds.
    /// 
    /// This is useful for automatic guiding. When the autoguiding 
    /// algorithm detects a guiding error, it will give the telescope
    /// a guide command to move the telescope north or south for the specified
    /// number of milliseconds.
    /// 
    /// Supported values are:
    /// - ``INDIPropertyValueName/timedGuideNorth`` to move the telescope north.
    /// - ``INDIPropertyValueName/timedGuideSouth`` to move the telescope south.
    case telescopeTimedGuideNorthSouth

    /// Move the telescope west or east for the specified number of 
    /// milliseconds.
    /// 
    /// This is useful for automatic guiding. When the autoguiding 
    /// algorithm detects a guiding error, it will give the telescope
    /// a guide command to move the telescope west or east for the specified
    /// number of milliseconds.
    /// 
    /// Supported values are:
    /// - ``INDIPropertyValueName/timedGuideWest`` to move the telescope west.
    /// - ``INDIPropertyValueName/timedGuideEast`` to move the telescope east.
    case telescopeTimedGuideWestEast

    /// The slew rate of the telescope.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/slewRateGuide`` the slowest slew rate of the telescope, 0.5x to 1.0x the sidereal speed.
    /// - ``INDIPropertyValueName/slewRateCentering`` the slow slew rate. Often used for centering the field of view.
    /// - ``INDIPropertyValueName/slewRateFind`` the medium slew rate. Often used for finding the desired field of view.
    /// - ``INDIPropertyValueName/slewRateMaximum`` the maximum slew rate of the telescope.
    case telescopeSlewRate

    /// Park or unpark the telescope.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/park`` to park the telescope.
    /// - ``INDIPropertyValueName/unpark`` to unpark the telescope.
    case telescopePark

    /// The home park position of the telescope.
    /// 
    /// This property should have a combinatoion of the following values:
    /// ``INDIPropertyValueName/parkRightAscension`` and ``INDIPropertyValueName/parkDeclination``,
    /// or ``INDIPropertyValueName/parkAzimuth`` and ``INDIPropertyValueName/parkAltitude``.
    /// 
    /// The supported values are:
    /// - ``INDIPropertyValueName/parkRightAscension`` the right ascension of the home park position.
    /// - ``INDIPropertyValueName/parkDeclination`` the declination of the home park position.
    /// - ``INDIPropertyValueName/parkAzimuth`` the azimuth of the home park position.
    /// - ``INDIPropertyValueName/parkAltitude`` the altitude of the home park position.
    case telescopeParkPosition

    /// A command to set the park options of the telescope.
    /// *Note: This property is solely used as a command, it is not a state property.*
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/parkCurrentPosition`` to set the current position of the telescope as the home park position.
    /// - ``INDIPropertyValueName/parkDefaultPosition`` to set the default position of the telescope driver as the home park position.
    /// - ``INDIPropertyValueName/parkWriteData`` to write the home park position to the telescope driver so that the park
    /// position is retained after a power cycle.
    /// - ``INDIPropertyValueName/parkPurgeData`` to purge the home park position data from the telescope driver.
    case telescopeParkOption

    /// Abort the current motion of the telescope rapidly, but gracefully.
    /// *Note: This property is solely used as a command, it is not a state property.*
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/abortMotion`` to abort the current motion of the telescope.
    case telescopeAbortMotion

    /// The custom track rate of the telescope.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/trackRateRightAscension`` the track rate of the telescope in arcseconds per second for the right ascension.
    /// - ``INDIPropertyValueName/trackRateDeclination`` the track rate of the telescope in arcseconds per second for the declination.
    case telescopeTrackRate

    /// The information about the telescope and/or guide scope. 
    /// Includes aperture and focal length.
    /// 
    /// This is a text property with the following values:
    case telescopeInfo

    /// The side of the pier the telescope is on in the case of an equatorial mount.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/pierSideEast`` the telescope is on the east side of the pier.
    /// - ``INDIPropertyValueName/pierSideWest`` the telescope is on the west side of the pier.
    case telescopePierSide

    /// Home position operations for the telescope.
    /// 
    /// This is a switch property with the following values:
    case telescopeHome

    /// The policy for the telescope with respect to the dome.
    /// It is set to either ignore the dome or prevent the telescope
    /// from moving when the dome is parked (closed).
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/domeIgnore`` to ignore the dome status.
    /// - ``INDIPropertyValueName/domeLocks`` to prevent the telescope from moving when the dome is parked (closed).
    case domePolicy

    /// The periodic error correction mode for the telescope, either on or off.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/periodicErrorCorrectionOn`` to enable the periodic error correction.
    /// - ``INDIPropertyValueName/periodicErrorCorrectionOff`` to disable the periodic error correction.
    case periodicErrorCorrection

    /// The track mode for the telescope, specifying predefined track rates for the 
    /// right ascension. This is used to adapt the tracking rate to specific solar 
    /// system objects.
    /// 
    /// It is related to the ``INDIPropertyName/telescopeTrackRate`` property.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/trackRateSidereal`` to use the default sidereal track rate.
    /// - ``INDIPropertyValueName/trackRateSolar`` to use the solar track rate.
    /// - ``INDIPropertyValueName/trackRateLunar`` to use the lunar track rate.
    /// - ``INDIPropertyValueName/trackRateCustom`` to use a custom track rate, specified by the client on the property
    /// ``INDIPropertyName/telescopeTrackRate``.
    case telescopeTrackMode

    /// The state of the telescope tracking, either on or off.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/trackStateOn`` to enable the telescope tracking.
    /// - ``INDIPropertyValueName/trackStateOff`` to disable the telescope tracking.
    case telescopeTrackState

    /// The satellite TLE orbital solution for tracking earth-orbiting satellites.
    /// 
    /// Not supported by all drivers/mounts.
    /// 
    /// This is a text property with the following value:
    /// - ``INDIPropertyValueName/satelliteTLE`` the TLE orbital solution for the satellite.
    case satelliteTLE

    /// The pass window for the satellite tracking.
    /// 
    /// Not supported by all drivers/mounts.
    /// 
    /// This is a text property with the following value:
    /// - ``INDIPropertyValueName/satellitePassWindowStart`` the start time of the pass window.
    /// - ``INDIPropertyValueName/satellitePassWindowEnd`` the end time of the pass window.
    case satellitePassWindow

    /// The tracking state of the satellite, either tracking or not halted.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/satelliteTrackingActive`` the satellite tracking is active.
    /// - ``INDIPropertyValueName/satelliteTrackingHalted`` the satellite tracking is halted.
    case satelliteTrackingState

    /// The telescope motion can be reversed for the north-south 
    /// and/or west-east directions.
    /// 
    /// This affects the effect of the ``telescopeMotionNorthSouth`` and 
    /// ``telescopeMotionWestEast`` properties. It can be used to align the control
    /// buttons with the actual motion of the telescope observed by the user or the
    /// camera.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/reverseNorthSouth`` to reverse the telescope motion for the north-south direction.
    /// - ``INDIPropertyValueName/reverseWestEast`` to reverse the telescope motion for the west-east direction.
    case telescopeReverseMotion

    /// The joystick motion control mode for the telescope.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/motionControlModeJoystick`` to use the 4-Way joystick motion control mode.
    /// - ``INDIPropertyValueName/motionControlModeAxes`` to use the 2-Axis joystick motion control mode.
    case motionControlMode

    /// Select which axes of the joystick are locked.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/lockAxisWestEast`` to lock the west-east axis of the joystick.
    /// - ``INDIPropertyValueName/lockAxisNorthSouth`` to lock the north-south axis of the joystick.
    case joystickLockAxis

    /// Simulate the pier side of the telescope for mounts that do not report
    /// the actual pier side.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/simulateYes`` to simulate the pier side of the telescope.
    /// - ``INDIPropertyValueName/simulateNo`` to do not simulate the pier side of the telescope.
    case simulatePierSide

    // MARK: CCD Properties

    /// The exposure time of the camera/CCD.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/ccdExposureValue`` the exposure time of the camera/CCD in seconds.
    case ccdExposureTime

    /// Abort the current exposure of the camera/CCD.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/abortExposure`` to abort the current exposure of the camera/CCD.
    case ccdAbortExposure

    /// The frame size of the camera/CCD.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/ccdFrameX`` the left most pixel position in the frame.
    /// - ``INDIPropertyValueName/ccdFrameY`` the top most pixel position in the frame.
    /// - ``INDIPropertyValueName/ccdFrameWidth`` the width of the frame in pixels.
    /// - ``INDIPropertyValueName/ccdFrameHeight`` the height of the frame in pixels.
    case ccdFrame

    /// The temperature of the camera/CCD in °C.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/ccdTemperatureValue`` the temperature of the camera/CCD in °C.
    case ccdTemperature

    /// The cooler status of the camera/CCD.
    /// 
    /// This is a switch with the following values:
    /// - ``INDIPropertyValueName/ccdCoolerOn`` to turn on the cooler.
    /// - ``INDIPropertyValueName/ccdCoolerOff`` to turn off the cooler.
    case ccdCooler

    /// The type of the frame of the camera/CCD.
    /// 
    /// This is a text property with the following values:
    /// - ``INDIPropertyValueName/lightFrame`` the type of the frame of the camera/CCD is a light frame.
    /// - ``INDIPropertyValueName/biasFrame`` the type of the frame of the camera/CCD is a bias frame.
    /// - ``INDIPropertyValueName/darkFrame`` the type of the frame of the camera/CCD is a dark frame.
    /// - ``INDIPropertyValueName/flatFrame`` the type of the frame of the camera/CCD is a flat frame.
    case ccdFrameType

    /// Camera binning settings.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/horizontalBinning`` horizontal binning factor.
    /// - ``INDIPropertyValueName/verticalBinning`` vertical binning factor.
    case ccdBinning

    /// Camera frame compression settings.
    /// 
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/ccdCompress`` compress camera frame (If FITS, it uses fpack to send a .fz file).
    /// - ``INDIPropertyValueName/ccdRaw`` send raw camera sensor data.
    case ccdCompression

    /// Reset Camera frame to default settings.
    /// 
    /// This sets the frame size and binning to the default values.
    /// 
    /// This is a switch property with the following value:
    /// - ``INDIPropertyValueName/reset`` reset CCD frame to default X, Y, W, and H settings. Set binning to 1x1.
    case ccdFrameReset

    /// Camera sensor information.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/ccdMaximumXResolution`` maximum X resolution.
    /// - ``INDIPropertyValueName/ccdMaximumYResolution`` maximum Y resolution.
    /// - ``INDIPropertyValueName/ccdPixelSize`` Camera sensor pixel size in microns.
    /// - ``INDIPropertyValueName/ccdPixelSizeX`` Camera sensor pixel size X in microns.
    /// - ``INDIPropertyValueName/ccdPixelSizeY`` Camera sensor pixel size Y in microns.
    /// - ``INDIPropertyValueName/ccdBitsPerPixel`` bits per pixel.
    case ccdInfo

    /// Camera sensor color filter array information.
    /// 
    /// This is used if the camera sensor creates a bayer pattern image.
    /// 
    /// This is a text property with the following values:
    /// - ``INDIPropertyValueName/cfaOffsetX`` color filter array X offset.
    /// - ``INDIPropertyValueName/cfaOffsetY`` color filter array Y offset.
    /// - ``INDIPropertyValueName/cfaType`` color filter array filter type (e.g. RGGB).
    case ccdColorFilterArray

    /// Primary Camera sensor data.
    /// 
    /// This is the main camera sensor. Binary fits data encoded in base64. 
    /// The CCD1.format is used to indicate the data type (e.g. “.fits”)
    /// 
    /// This is a BLOB property with the following values:
    /// - ``INDIPropertyValueName/ccd1`` the main camera sensor data.
    case ccd1

    /// Secondary CCD (Guider) sensor data. This is the sensor in a dual-CCD camera
    /// where a small off-axis CCD is used for guiding.
    /// 
    /// Binary fits data encoded in base64. The CCD2.format is used to indicate the data type (e.g. “.fits”)
    /// 
    /// This is a BLOB property with the following values:
    /// - ``INDIPropertyValueName/ccd2`` the secondary camera sensor data.
    case ccd2

    /// Camera cooler temperature ramp parameters.
    /// 
    /// Set TEC cooler ramp parameters. The ramp is software controlled inside INDI.
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/rampSlope`` maximum temperature change in degrees Celsius per minute.
    /// - ``INDIPropertyValueName/rampThreshold`` threshold in degrees celsius. If the absolute difference
    ///   of target and current temperature equals to or below this threshold, then the cooling operation is complete.
    case ccdTemperatureCoolerRampParameters

    /// World Coordinate System keyword inclusion in FITS header.
    /// 
    /// Toggle World Coordinate System keyword inclusion in FITS Header.
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/worldCoordinateSystemEnabled`` enable WCS keywords.
    /// - ``INDIPropertyValueName/worldCoordinateSystemDisabled`` disable WCS keywords.
    case worldCoordinateSystemKeywordInclusion

    /// Camera field of view rotation.
    /// 
    /// Camera field of view rotation measured as East of North in degrees.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/ccdRotationValue`` the rotation angle in degrees.
    case ccdRotation

    /// Raw capture format as supported by the driver or hardware.
    /// 
    /// For example, Bayer 16bit or RGB. This is a switch property.
    /// **NB. No standard values are defined for this property.**
    case ccdCaptureFormat

    /// Transfer format of the raw captured data.
    /// 
    /// Transfer format of the raw captured format before sending the image back to the client or saving to disk.
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/formatFits`` encode captured image as FITS.
    /// - ``INDIPropertyValueName/formatNative`` send image as-is without encoding.
    /// - ``INDIPropertyValueName/formatXisf`` encode captured images as XISF (eXtensible Image Serialization Format).
    case ccdTransferFormat

    /// Absolute path where images are saved on disk.
    /// 
    /// This is a text property with the following value:
    /// - ``INDIPropertyValueName/filePath`` the directory path where images are saved.
    case ccdFilePath

    /// Fast exposure mode toggle.
    /// 
    /// Fast Exposure is used to enable camera to immediately begin capturing the next frames.
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/fastToggleEnabled`` enable fast exposure.
    /// - ``INDIPropertyValueName/fastToggleDisabled`` disable fast exposure.
    case ccdFastToggle

    /// Number of fast exposure frames to capture.
    /// 
    /// Number of fast exposure frames to capture once exposure begins.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/frames`` the number of frames to capture.
    case ccdFastCount

    /// FITS header keywords to append.
    /// 
    /// Name, value, and comment row to be appended to the fits header on the next capture. The row needs to be
    /// set once for any subsequent captures. It is not retained on driver restart.
    /// This is a text property with the following values:
    /// - ``INDIPropertyValueName/keywordName`` the FITS keyword name.
    /// - ``INDIPropertyValueName/keywordValue`` the FITS keyword value.
    /// - ``INDIPropertyValueName/keywordComment`` the FITS keyword comment.
    case fitsHeader

    // MARK: CCD Streaming Properties

    /// Camera video stream toggle.
    /// 
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/streamOn`` turn on video stream.
    /// - ``INDIPropertyValueName/streamOff`` turn off video stream.
    case ccdVideoStream

    /// Delay between streaming frames.
    /// 
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/streamDelayTime`` delay in seconds between frames.
    case streamDelay

    /// Streaming frame exposure and divisor settings.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/streamingExposureTimeValue`` frame exposure values in seconds when streaming.
    /// - ``INDIPropertyValueName/streamingDivisorValue`` the divisor is used to skip frames as way to throttle the stream down.
    case streamingExposureTime

    /// Frames per second information.
    /// 
    /// Read-only frame rate information. This is a number property with the following values:
    /// - ``INDIPropertyValueName/instantFrameRate`` instant frame rate (EST_FPS).
    /// - ``INDIPropertyValueName/averageFramesPerSecondOneSecond`` average FPS over 1 second (AVG_FPS).
    case framesPerSecond

    /// Streaming frame size settings.
    /// 
    /// This is a number property with frame coordinates and dimensions. Uses the same value names as ``ccdFrame``:
    /// - ``INDIPropertyValueName/ccdFrameX`` left-most pixel position.
    /// - ``INDIPropertyValueName/ccdFrameY`` top-most pixel position.
    /// - ``INDIPropertyValueName/ccdFrameWidth`` frame width in pixels.
    /// - ``INDIPropertyValueName/ccdFrameHeight`` frame height in pixels.
    case ccdStreamingFrameSize

    /// Streaming encoder selection.
    /// 
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/rawStreamEncoder`` raw encoder.
    /// - ``INDIPropertyValueName/mjpegStreamEncoder`` MJPEG encoder.
    case ccdStreamEncoder

    /// Stream recording format selection.
    /// 
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/serStreamRecorder`` SER recorder.
    /// - ``INDIPropertyValueName/ogvStreamRecorder`` OGV recorder.
    case ccdStreamRecorder

    /// Streaming buffer and frame rate limits.
    /// 
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/maximumBufferSize`` maximum buffer size in MB.
    /// - ``INDIPropertyValueName/maximumPreviewFramesPerSecond`` maximum preview FPS.
    case limits

    /// Recording file path settings.
    /// 
    /// This is a text property with the following values:
    /// - ``INDIPropertyValueName/recordFileDirectory`` directory to save the file. It defaults to $HOME/indi_D.
    /// - ``INDIPropertyValueName/recordFileName`` recording file name. It defaults to indirecord__T.
    case recordFile

    /// Recording duration and frame count settings.
    /// 
    /// Set the desired duration in seconds or total frames required for the recording.
    /// This is a number property with the following values:
    /// - ``INDIPropertyValueName/recordDuration`` duration in seconds.
    /// - ``INDIPropertyValueName/recordFrameTotal`` total number of frames required.
    case recordOptions

    /// Stream recording control.
    /// 
    /// Start or stop the stream recording to a file. This is a switch property with the following values:
    /// - ``INDIPropertyValueName/recordOn`` start recording. Do not stop unless asked to.
    /// - ``INDIPropertyValueName/recordDurationOn`` start recording until the duration set in recordOptions has elapsed.
    /// - ``INDIPropertyValueName/recordFrameOn`` start recording until the number of frames set in recordOptions has been captured.
    /// - ``INDIPropertyValueName/recordOff`` stops recording.
    case recordStream
    // ccdFastToggle and ccdFastCount are also used for streaming properties but
    // are already defined above.

    // MARK: Filter wheel Properties
    case filterSlot

    case filterName

    // MARK: Focuser Properties

    /// Focus speed selection.
    /// 
    /// Select focus speed from 0 to N where 0 maps to no motion, and N maps to the fastest speed possible.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusSpeedValue`` set focuser speed.
    case focusSpeed

    /// Focus motion direction.
    /// 
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/focusInward`` focus inward.
    /// - ``INDIPropertyValueName/focusOutward`` focus outward.
    case focusMotion

    /// Focus timer duration.
    /// 
    /// Focus in the direction of ``focusMotion`` at rate ``focusSpeed`` for the specified duration.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusTimerValue`` focus timer value in milliseconds.
    case focusTimer

    /// Relative focus position.
    /// 
    /// Move a number of steps in the direction specified by ``focusMotion``.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusRelativePosition`` number of steps to move in the focus motion direction.
    case relativeFocusPosition

    /// Absolute focus position.
    /// 
    /// Move to this absolute position.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusAbsolutePosition`` absolute position in steps.
    case absoluteFocusPosition

    /// Focus maximum travel limit.
    /// 
    /// Focus maximum travel limit in steps.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusMaxValue`` focus maximum travel limit in steps.
    case focusMax

    /// Focus reverse motion toggle.
    /// 
    /// Reverse default motor direction.
    /// This is a switch property with the following values:
    /// - ``INDIPropertyValueName/focusReverseMotionEnabled`` reverse default motor direction.
    /// - ``INDIPropertyValueName/focusReverseMotionDisabled`` do not reverse, move motor in the default direction.
    case focusReverseMotion

    /// Abort focus motion.
    /// 
    /// This is a switch property with the following value:
    /// - ``INDIPropertyValueName/focusAbort`` abort focus motion.
    case focusAbortMotion

    /// Focus sync position.
    /// 
    /// Accept this position as the new focuser absolute position.
    /// This is a number property with the following value:
    /// - ``INDIPropertyValueName/focusSyncValue`` accept this position as the new focuser absolute position.
    case focusSync

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
        case .telescopeMotionNorthSouth: return "TELESCOPE_MOTION_NS"
        case .telescopeMotionWestEast: return "TELESCOPE_MOTION_WE"
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
        case .satelliteTLE: return "SAT_TLE_TEXT"
        case .satellitePassWindow: return "SAT_PASS_WINDOW"
        case .satelliteTrackingState: return "SAT_TRACKING_STAT"
        case .telescopeReverseMotion: return "TELESCOPE_REVERSE_MOTION"
        case .motionControlMode: return "MOTION_CONTROL_MODE"
        case .joystickLockAxis: return "JOYSTICK_LOCK_AXIS"
        case .simulatePierSide: return "SIMULATE_PIER_SIDE"

        case .ccdExposureTime: return "CCD_EXPOSURE"
        case .ccdAbortExposure: return "CCD_ABORT_EXPOSURE"
        case .ccdFrame: return "CCD_FRAME"
        case .ccdTemperature: return "CCD_TEMPERATURE"
        case .ccdCooler: return "CCD_COOLER"
        case .ccdFrameType: return "CCD_FRAME_TYPE"
        case .ccdBinning: return "CCD_BINNING"
        case .ccdCompression: return "CCD_COMPRESSION"
        case .ccdFrameReset: return "CCD_FRAME_RESET"
        case .ccdInfo: return "CCD_INFO"
        case .ccdColorFilterArray: return "CCD_CFA"
        case .ccd1: return "CCD1"
        case .ccd2: return "CCD2"
        case .ccdTemperatureCoolerRampParameters: return "CCD_TEMP_RAMP"
        case .worldCoordinateSystemKeywordInclusion: return "WCS_CONTROL"
        case .ccdRotation: return "CCD_ROTATION"
        case .ccdCaptureFormat: return "CCD_CAPTURE_FORMAT"
        case .ccdTransferFormat: return "CCD_TRANSFER_FORMAT"
        case .ccdFilePath: return "CCD_FILE_PATH"
        case .ccdFastToggle: return "CCD_FAST_TOGGLE"
        case .ccdFastCount: return "CCD_FAST_COUNT"
        case .fitsHeader: return "FITS_HEADER"

        case .ccdVideoStream: return "CCD_VIDEO_STREAM"
        case .streamDelay: return "STREAM_DELAY"
        case .streamingExposureTime: return "STREAMING_EXPOSURE"
        case .framesPerSecond: return "FPS"
        case .ccdStreamingFrameSize: return "CCD_STREAM_FRAME_SIZE"
        case .ccdStreamEncoder: return "CCD_STREAM_ENCODER"
        case .ccdStreamRecorder: return "CCD_STREAM_RECORDER"
        case .limits: return "LIMITS"
        case .recordFile: return "RECORD_FILE"
        case .recordOptions: return "RECORD_OPTIONS"
        case .recordStream: return "RECORD_STREAM"
        // ccdFastToggle and ccdFastCount are also used for streaming properties but
        // are already defined above.

        case .filterSlot: return "FILTER_SLOT"
        case .filterName: return "FILTER_NAME"
        case .focusSpeed: return "FOCUS_SPEED"
        case .focusMotion: return "FOCUS_MOTION"
        case .focusTimer: return "FOCUS_TIMER"
        case .relativeFocusPosition: return "REL_FOCUS_POSITION"
        case .absoluteFocusPosition: return "ABS_FOCUS_POSITION"
        case .focusMax: return "FOCUS_MAX"
        case .focusReverseMotion: return "FOCUS_REVERSE_MOTION"
        case .focusAbortMotion: return "FOCUS_ABORT_MOTION"
        case .focusSync: return "FOCUS_SYNC"

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
        case .satelliteTLE: return "Satellite TLE Text"
        case .satellitePassWindow: return "Satellite Pass Window"
        case .satelliteTrackingState: return "Satellite Tracking State"
        case .telescopeReverseMotion: return "Telescope Reverse Motion"
        case .motionControlMode: return "Motion Control Mode"
        case .joystickLockAxis: return "Joystick Lock Axis"
        case .simulatePierSide: return "Simulate Pier Side"

        case .ccdExposureTime: return "Camera Exposure Time"
        case .ccdAbortExposure: return "Abort Camera Exposure"
        case .ccdFrame: return "Frame Size"
        case .ccdTemperature: return "Camera Chip Temperature"
        case .ccdCooler: return "Camera Cooler Temperature"
        case .ccdFrameType: return "Frame type"
        case .ccdBinning: return "Binning"
        case .ccdCompression: return "Compression"
        case .ccdFrameReset: return "Reset Frame to default size and binning settings"
        case .ccdInfo: return "Camera Info"
        case .ccdColorFilterArray: return "Color Filter Array Information"
        case .ccd1: return "Camera Sensor 1"
        case .ccd2: return "Camera Sensor 2 (Guider)"
        case .ccdTemperatureCoolerRampParameters: return "Temperature Cooler Ramp Parameters"
        case .worldCoordinateSystemKeywordInclusion: return "World Coordinate System Keyword Inclusion"
        case .ccdRotation: return "Camera Field of View Rotation"
        case .ccdCaptureFormat: return "Raw Capture Format"
        case .ccdTransferFormat: return "Transfer Format"
        case .ccdFilePath: return "File Path"
        case .ccdFastToggle: return "Fast Exposure Toggle"
        case .ccdFastCount: return "Fast Exposure Count"
        case .fitsHeader: return "FITS Header Information"

        case .ccdVideoStream: return "Camera Video Stream Toggle"
        case .streamDelay: return "Delay between frames"
        case .streamingExposureTime: return "Streaming Exposure Time"
        case .framesPerSecond: return "Frames Per Second"
        case .ccdStreamingFrameSize: return "Streaming Frame Size"
        case .ccdStreamEncoder: return "Stream Encoder"
        case .ccdStreamRecorder: return "Stream Recorder"
        case .limits: return "StreamingLimits"
        case .recordFile: return "Record File Directory"
        case .recordOptions: return "Record Options"
        case .recordStream: return "Toggle Stream Recording"

        case .filterSlot: return "Filter Slot"
        case .filterName: return "Filter Name"
        case .focusSpeed: return "Focus Speed"
        case .focusMotion: return "Focus Motion"
        case .focusTimer: return "Focus Timer"
        case .relativeFocusPosition: return "Relative Focus Position"
        case .absoluteFocusPosition: return "Absolute Focus Position"
        case .focusMax: return "Focus Maximum"
        case .focusReverseMotion: return "Focus Reverse Motion"
        case .focusAbortMotion: return "Focus Abort Motion"
        case .focusSync: return "Focus Sync"

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
        case .satelliteTLE: return .text
        case .satellitePassWindow: return .text
        case .satelliteTrackingState: return .toggle
        case .telescopeReverseMotion: return .toggle
        case .motionControlMode: return .toggle
        case .joystickLockAxis: return .toggle
        case .simulatePierSide: return .toggle

        case .ccdExposureTime: return .number
        case .ccdAbortExposure: return .toggle
        case .ccdFrame: return .number
        case .ccdTemperature: return .number
        case .ccdCooler: return .toggle
        case .ccdFrameType: return .toggle
        case .ccdBinning: return .number
        case .ccdCompression: return .toggle
        case .ccdFrameReset: return .toggle
        case .ccdInfo: return .number
        case .ccdColorFilterArray: return .text
        case .ccd1: return .blob
        case .ccd2: return .blob
        case .ccdTemperatureCoolerRampParameters: return .number
        case .worldCoordinateSystemKeywordInclusion: return .toggle
        case .ccdRotation: return .number
        case .ccdCaptureFormat: return .toggle
        case .ccdTransferFormat: return .toggle
        case .ccdFilePath: return .text
        case .ccdFastToggle: return .toggle
        case .ccdFastCount: return .number
        case .fitsHeader: return .text

        case .ccdVideoStream: return .toggle
        case .streamDelay: return .number
        case .streamingExposureTime: return .number
        case .framesPerSecond: return .number
        case .ccdStreamingFrameSize: return .number
        case .ccdStreamEncoder: return .toggle
        case .ccdStreamRecorder: return .toggle
        case .limits: return .number
        case .recordFile: return .text
        case .recordOptions: return .text
        case .recordStream: return .toggle

        case .filterSlot: return .number
        case .filterName: return .text
        case .focusSpeed: return .number
        case .focusMotion: return .toggle
        case .focusTimer: return .number
        case .relativeFocusPosition: return .number
        case .absoluteFocusPosition: return .number
        case .focusMax: return .number
        case .focusReverseMotion: return .toggle
        case .focusAbortMotion: return .toggle
        case .focusSync: return .number

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
    public static var allCases: [INDIPropertyName] {
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
            .satelliteTLE,
            .satellitePassWindow,
            .satelliteTrackingState,
            .telescopeReverseMotion,
            .motionControlMode,
            .joystickLockAxis,
            .simulatePierSide,
            .ccdExposureTime,
            .ccdAbortExposure,
            .ccdFrame,
            .ccdTemperature,
            .ccdCooler,
            .ccdFrameType,
            .ccdBinning,
            .ccdCompression,
            .ccdFrameReset,
            .ccdInfo,
            .ccdColorFilterArray,
            .ccd1,
            .ccd2,
            .ccdTemperatureCoolerRampParameters,
            .worldCoordinateSystemKeywordInclusion,
            .ccdRotation,
            .ccdCaptureFormat,
            .ccdTransferFormat,
            .ccdFilePath,
            .ccdFastToggle,
            .ccdFastCount,
            .fitsHeader,
            .ccdVideoStream,
            .streamDelay,
            .streamingExposureTime,
            .framesPerSecond,
            .ccdStreamingFrameSize,
            .ccdStreamEncoder,
            .ccdStreamRecorder,
            .limits,
            .recordFile,
            .recordOptions,
            .recordStream,
            .filterSlot,
            .filterName
        ]
    }
}

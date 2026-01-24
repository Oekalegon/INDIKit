import Foundation

// swiftlint:disable:next orphaned_doc_comment
/// Standard INDI property value names.
/// 
/// This enum contains the standard INDI property value names as defined in the INDI protocol.
/// Use these to identify the standard values of an INDI property. Other values are
/// possible. The device driver can define additional values.
/// 
/// See [INDI Property Value Names](https://www.indilib.org/doc/v1.8/protocol/properties.html) for more information.
/// 
/// ## Topics
/// 
/// ### General Properties' values
/// 
/// #### [Connection Properties](INDIPropertyName/connection)' values
/// - ``connect``
/// - ``disconnect``
/// 
/// #### [Device Port Properties](INDIPropertyName/devicePort)' values
/// - ``port``
/// 
/// #### [Local Sideral Time Properties](INDIPropertyName/localSideralTime)' values
/// - ``localSideralTime``
/// 
/// #### [Universal Time Properties](INDIPropertyName/universalTime)' values
/// - ``universalTime``
/// - ``offset``
/// 
/// #### [Geographic Coordinates Properties](INDIPropertyName/geographicCoordinates)' values
/// - ``latitude``
/// - ``longitude``
/// - ``elevation``
/// 
/// #### [Atmosphere Properties](INDIPropertyName/atmosphere)' values
/// - ``temperature``
/// - ``pressure``
/// - ``humidity``
/// 
/// #### [Upload Mode Properties](INDIPropertyName/uploadMode)' values
/// - ``uploadClient``
/// - ``uploadLocal``
/// - ``uploadBoth``
/// 
/// #### [Upload Settings Properties](INDIPropertyName/uploadSettings)' values
/// - ``uploadDirectory``
/// - ``uploadPrefix``
/// 
/// #### [Active Devices Properties](INDIPropertyName/activeDevices)' values
/// - ``activeTelescope``
/// - ``activeCamera``
/// - ``activeFilterWheel``
/// - ``activeFocuser``
/// 
/// ### Telescope Properties' values
/// #### [Equatorial Coordinates J2000 Properties](INDIPropertyName/equatorialCoordinatesJ2000)' values
/// - ``rightAscension``
/// - ``declination``
/// 
/// #### [Equatorial Coordinates Epoch Properties](INDIPropertyName/equatorialCoordinatesEpoch)' values
/// - ``rightAscension``
/// - ``declination``
/// 
/// #### [Target Equatorial Coordinates Epoch Properties](INDIPropertyName/targetEquatorialCoordinatesEpoch)' values
/// - ``rightAscension``
/// - ``declination``
/// 
/// #### [Horizontal Coordinates Properties](INDIPropertyName/horizontalCoordinates)' values
/// - ``azimuth``
/// - ``altitude``
/// 
/// #### [Telescope Action On Coordinates Set Properties](INDIPropertyName/telescopeActionOnCoordinatesSet)' values
/// - ``slew``
/// - ``track``
/// - ``synchronize``
/// 
/// #### [Telescope Motion North South Properties](INDIPropertyName/telescopeMotionNorthSouth)' values
/// - ``motionNorth``
/// - ``motionSouth``
/// 
/// #### [Telescope Motion West East Properties](INDIPropertyName/telescopeMotionWestEast)' values
/// - ``motionWest``
/// - ``motionEast``
/// 
/// #### [Telescope Timed Guide North South Properties](INDIPropertyName/telescopeTimedGuideNorthSouth)' values
/// - ``timedGuideNorth``
/// - ``timedGuideSouth``
/// 
/// #### [Telescope Timed Guide West East Properties](INDIPropertyName/telescopeTimedGuideWestEast)' values
/// - ``timedGuideWest``
/// - ``timedGuideEast``
/// 
/// #### [Telescope Slew Rate Properties](INDIPropertyName/telescopeSlewRate)' values
/// - ``slewRateGuide``
/// - ``slewRateCentering``
/// - ``slewRateFind``
/// - ``slewRateMaximum``
/// 
/// #### [Telescope Park Properties](INDIPropertyName/telescopePark)' values
/// - ``park``
/// - ``unpark``
/// 
/// #### [Telescope Park Position Properties](INDIPropertyName/telescopeParkPosition)' values
/// - ``parkRightAscension``
/// - ``parkDeclination``
/// - ``parkAzimuth``
/// - ``parkAltitude``
/// 
/// #### [Telescope Park Option Properties](INDIPropertyName/telescopeParkOption)' values
/// - ``parkCurrentPosition``
/// - ``parkDefaultPosition``
/// - ``parkWriteData``
/// - ``parkPurgeData``
/// 
/// #### [Telescope Abort Motion Properties](INDIPropertyName/telescopeAbortMotion)' values
/// - ``abortMotion``
/// 
/// #### [Telescope Track Rate Properties](INDIPropertyName/telescopeTrackRate)' values
/// - ``trackRateRightAscension``
/// - ``trackRateDeclination``
/// 
/// #### [Telescope Info Properties](INDIPropertyName/telescopeInfo)' values
/// - ``telescopeAperture``
/// - ``telescopeFocalLength``
/// - ``guiderScopeAperture``
/// - ``guiderScopeFocalLength``
/// 
/// #### [Telescope Pier Side Properties](INDIPropertyName/telescopePierSide)' values
/// - ``pierSideEast``
/// - ``pierSideWest``
/// 
/// #### [Telescope Home Properties](INDIPropertyName/telescopeHome)' values
/// - ``home``
/// - ``unhome``
/// 
/// #### [Dome Policy Properties](INDIPropertyName/domePolicy)' values
/// - ``domeIgnore``
/// - ``domeLocks``
/// 
/// #### [Periodic Error Correction Properties](INDIPropertyName/periodicErrorCorrection)' values
/// - ``periodicErrorCorrectionOn``
/// - ``periodicErrorCorrectionOff``
/// 
/// #### [Telescope Track Mode Properties](INDIPropertyName/telescopeTrackMode)' values
/// - ``trackRateSidereal``
/// - ``trackRateSolar``
/// - ``trackRateLunar``
/// - ``trackRateCustom``
/// 
/// #### [Telescope Track State Properties](INDIPropertyName/telescopeTrackState)' values
/// - ``trackStateOn``
/// - ``trackStateOff``
/// 
/// #### [Satellite TLE Properties](INDIPropertyName/satelliteTLE)' values
/// - ``satelliteTLE``
/// - ``satellitePassWindowStart``
/// - ``satellitePassWindowEnd``
/// - ``satelliteTrackingActive``
/// - ``satelliteTrackingHalted``
/// 
/// #### [Reverse North South Properties](INDIPropertyName/telescopeReverseMotion)' values
/// - ``reverseNorthSouth``
/// - ``reverseWestEast``
/// 
/// #### [Motion Control Mode Properties](INDIPropertyName/motionControlMode)' values
/// - ``motionControlModeJoystick``
/// - ``motionControlModeAxes``
/// 
/// #### [Lock Axis West East Properties](INDIPropertyName/joystickLockAxis)' values
/// - ``lockAxisWestEast``
/// - ``lockAxisNorthSouth``
/// 
/// #### [Lock Axis North South Properties](INDIPropertyName/simulatePierSide)' values
/// - ``lockAxisNorthSouth``
/// - ``lockAxisWestEast``
/// 
/// ### Camera/CCD Properties' values
/// #### [CCD Exposure Time Properties](INDIPropertyName/ccdExposureTime)' values
/// - ``exposureTime``
/// 
/// #### [CCD Abort Exposure Properties](INDIPropertyName/ccdAbortExposure)' values
/// - ``abortExposure``
/// 
/// #### [CCD Frame Properties](INDIPropertyName/ccdFrame)' values
/// - ``frame``
/// 
/// #### [CCD Temperature Properties](INDIPropertyName/ccdTemperature)' values
/// - ``temperature``
/// 
/// #### [CCD Cooler Properties](INDIPropertyName/ccdCooler)' values
/// - ``cooler``
/// 
/// #### [CCD Frame Type Properties](INDIPropertyName/ccdFrameType)' values
/// - ``frameType``
/// 
/// #### [CCD Binning Properties](INDIPropertyName/ccdBinning)' values
/// - ``binning``
/// 
/// #### [CCD Compression Properties](INDIPropertyName/ccdCompression)' values
/// - ``compression``
/// 
/// #### [CCD Frame Reset Properties](INDIPropertyName/ccdFrameReset)' values
/// - ``frameReset``
/// 
/// #### [CCD Info Properties](INDIPropertyName/ccdInfo)' values
/// - ``info``
/// 
/// #### [CCD Color Filter Array Properties](INDIPropertyName/ccdColorFilterArray)' values
/// - ``colorFilterArray``
/// 
/// #### [CCD 1 Properties](INDIPropertyName/ccd1)' values
/// - ``ccd1``
/// 
/// #### [CCD 2 Properties](INDIPropertyName/ccd2)' values
/// - ``ccd2``
/// 
/// #### [CCD Temperature Cooler Ramp Parameters Properties](INDIPropertyName/ccdTemperatureCoolerRampParameters)' values
/// - ``rampSlope``
/// - ``rampThreshold``
/// 
/// #### [World Coordinate System Control Properties](INDIPropertyName/worldCoordinateSystemKeywordInclusion)' values
/// - ``worldCoordinateSystemEnabled``
/// - ``worldCoordinateSystemDisabled``
/// 
/// #### [CCD Rotation Properties](INDIPropertyName/ccdRotation)' values    
/// - ``ccdRotationValue``
/// 
/// #### [CCD Transfer Format Properties](INDIPropertyName/ccdTransferFormat)' values
/// - ``formatFits``
/// - ``formatNative``
/// - ``formatXisf``
/// 
/// #### [CCD File Path Properties](INDIPropertyName/ccdFilePath)' values
/// - ``filePath``
/// 
/// #### [CCD Fast Toggle Properties](INDIPropertyName/ccdFastToggle)' values
/// - ``fastToggleEnabled``
/// - ``fastToggleDisabled``
/// 
/// #### [CCD Fast Count Properties](INDIPropertyName/ccdFastCount)' values
/// - ``numberOfFrames``
/// 
/// #### [FITS Header Properties](INDIPropertyName/fitsHeader)' values
/// - ``keywordName``
/// - ``keywordValue``
/// - ``keywordComment``
/// 
/// ### Camera/CCD Streaming Properties' values
/// #### [CCD Video Stream Properties](INDIPropertyName/ccdVideoStream)' values
/// - ``streamOn``
/// - ``streamOff``
/// 
/// #### [Stream Delay Properties](INDIPropertyName/streamDelay)' values
/// - ``streamDelayTime``
/// 
/// #### [Streaming Exposure Time Properties](INDIPropertyName/streamingExposureTime)' values
/// - ``streamingExposureTimeValue``
/// 
/// #### [Frame Rate Properties](INDIPropertyName/framesPerSecond)' values
/// - ``instantFrameRate``
/// - ``averageFramesPerSecondOneSecond``
/// 
/// #### [Streaming Frame Size Properties](INDIPropertyName/ccdStreamingFrameSize)' values
/// - ``ccdFrameX``
/// - ``ccdFrameY``
/// - ``ccdFrameWidth``
/// - ``ccdFrameHeight``
/// 
/// #### [Streaming Encoder Properties](INDIPropertyName/ccdStreamEncoder)' values
/// - ``rawStreamEncoder``
/// - ``mjpegStreamEncoder``
/// 
/// #### [Streaming Recorder Properties](INDIPropertyName/ccdStreamRecorder)' values
/// - ``serStreamRecorder``
/// - ``ogvStreamRecorder``
/// 
/// #### [Limits Properties](INDIPropertyName/limits)' values
/// - ``maximumBufferSize``
/// - ``maximumPreviewFramesPerSecond``
/// 
/// #### [Record File Properties](INDIPropertyName/recordFile)' values
/// - ``recordFileDirectory``
/// - ``recordFileName``
/// 
/// #### [Record Options Properties](INDIPropertyName/recordOptions)' values
/// - ``recordDuration``
/// - ``recordFrameTotal``
/// 
/// #### [Record Stream Properties](INDIPropertyName/recordStream)' values
/// - ``recordOn``
/// - ``recordDurationOn``
/// - ``recordFrameOn``
/// - ``recordOff``
/// 
/// #### [Fast Toggle Properties](INDIPropertyName/ccdFastToggle)' values
/// - ``fastToggleEnabled``
/// - ``fastToggleDisabled``
/// 
/// #### [Fast Count Properties](INDIPropertyName/ccdFastCount)' values
/// - ``numberOfFrames``
/// 
/// ### Filter Wheel Properties' values
/// #### [Filter Slot Properties](INDIPropertyName/filterSlot)' values
/// - ``filterSlot``
/// 
/// #### [Filter Name Properties](INDIPropertyName/filterName)' values
/// - ``filterName``
/// 
/// ### Focuser Properties' values
/// #### [Focus Speed Properties](INDIPropertyName/focusSpeed)' values
/// - ``focusSpeedValue``
/// 
/// #### [Focus Motion Properties](INDIPropertyName/focusMotion)' values
/// - ``focusInward``
/// - ``focusOutward``
/// 
/// #### [Focus Timer Properties](INDIPropertyName/focusTimer)' values
/// - ``focusTimerValue``
/// 
/// #### [Relative Focus Position Properties](INDIPropertyName/relativeFocusPosition)' values
/// - ``focusRelativePosition``
/// 
/// #### [Absolute Focus Position Properties](INDIPropertyName/absoluteFocusPosition)' values
/// - ``focusAbsolutePosition``
/// 
/// #### [Focus Max Properties](INDIPropertyName/focusMax)' values
/// - ``focusMaxValue``
/// 
/// #### [Focus Reverse Motion Properties](INDIPropertyName/focusReverseMotion)' values
/// - ``focusReverseMotionEnabled``
/// - ``focusReverseMotionDisabled``
/// 
/// #### [Focus Abort Motion Properties](INDIPropertyName/focusAbortMotion)' values
/// - ``focusAbort``
/// 
/// #### [Focus Sync Properties](INDIPropertyName/focusSync)' values
/// - ``focusSyncValue``
/// 
// swiftlint:disable:next type_body_length
public enum INDIPropertyValueName: Sendable, CaseIterable {

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

    /// Name of the active filter wheel.
    /// 
    /// Value of ``INDIPropertyName/activeDevices``.
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
    /// Value of ``INDIPropertyName/equatorialCoordinatesJ2000``, 
    /// ``INDIPropertyName/equatorialCoordinatesEpoch``, and 
    /// ``INDIPropertyName/targetEquatorialCoordinatesEpoch``.
    case rightAscension

    /// Declination of the target in degrees.
    /// 
    /// Value of ``INDIPropertyName/equatorialCoordinatesJ2000``, 
    /// ``INDIPropertyName/equatorialCoordinatesEpoch``, and 
    /// ``INDIPropertyName/targetEquatorialCoordinatesEpoch``.
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

    // MARK: Camera/CCD Properties

    /// The exposure time of the camera/CCD in seconds.
    /// 
    /// Value of ``INDIPropertyName/ccdExposureTime``.
    case ccdExposureValue

    /// Abort the current exposure of the camera/CCD.
    /// 
    /// Value of ``INDIPropertyName/ccdAbortExposure``.
    case abortExposure

    /// The left most pixel position in the frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrame``.
    case ccdFrameX

    /// The top most pixel position in the frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrame``.
    case ccdFrameY

    /// The width of the frame in pixels.
    /// 
    /// Value of ``INDIPropertyName/ccdFrame``.
    case ccdFrameWidth

    /// The height of the frame in pixels.
    /// 
    /// Value of ``INDIPropertyName/ccdFrame``.
    case ccdFrameHeight

    /// The temperature of the camera/CCD in °C.
    /// 
    /// Value of ``INDIPropertyName/ccdTemperature``.
    case ccdTemperatureValue

    /// Turn on the cooler of the camera/CCD.
    /// 
    /// Value of ``INDIPropertyName/ccdCooler``.
    case ccdCoolerOn

    /// Turn off the cooler of the camera/CCD.
    /// 
    /// Value of ``INDIPropertyName/ccdCooler``.
    case ccdCoolerOff

    /// The type of the frame of the camera/CCD is a light frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrameType``.
    case lightFrame

    /// The type of the frame of the camera/CCD is a bias frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrameType``.
    case biasFrame

    /// The type of the frame of the camera/CCD is a dark frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrameType``.
    case darkFrame  

    /// The type of the frame of the camera/CCD is a flat frame.
    /// 
    /// Value of ``INDIPropertyName/ccdFrameType``.
    case flatFrame

    // CCD Binning
    /// Horizontal binning.
    /// 
    /// Value of ``INDIPropertyName/ccdBinning``.
    case horizontalBinning

    /// Vertical binning.
    /// 
    /// Value of ``INDIPropertyName/ccdBinning``.
    case verticalBinning

    // CCD Compression
    /// Compress CCD frame (If FITS, it uses fpack to send a .fz file).
    /// 
    /// Value of ``INDIPropertyName/ccdCompression``.
    case ccdCompress

    /// Send raw CCD frame.
    /// 
    /// Value of ``INDIPropertyName/ccdCompression``.
    case ccdRaw

    // CCD Frame Reset
    /// Reset CCD frame to default X, Y, W, and H settings. Set binning to 1x1.
    /// 
    /// Value of ``INDIPropertyName/ccdFrameReset``.
    case reset

    // CCD Info
    /// Maximum X resolution.
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdMaximumXResolution

    /// Maximum Y resolution.
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdMaximumYResolution

    /// CCD pixel size in microns.
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdPixelSize

    /// CCD pixel size in microns (X axis).
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdPixelSizeX

    /// CCD pixel size in microns (Y axis).
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdPixelSizeY

    /// Bits per pixel.
    /// 
    /// Value of ``INDIPropertyName/ccdInfo``.
    case ccdBitsPerPixel

    // CCD Color Filter Array
    /// Color Filter Array X offset.
    /// 
    /// Value of ``INDIPropertyName/ccdColorFilterArray``.
    case cfaOffsetX

    /// Color Filter Array Y offset.
    /// 
    /// Value of ``INDIPropertyName/ccdColorFilterArray``.
    case cfaOffsetY

    /// Color Filter Array filter type (e.g. RGGB).
    /// 
    /// Value of ``INDIPropertyName/ccdColorFilterArray``.
    case cfaType

    // CCD1
    /// Primary Camera sensor data.
    /// 
    /// Binary fits data encoded in base64. The CCD1.format is used to indicate the data type (e.g. ".fits")
    /// 
    /// Value of ``INDIPropertyName/ccd1``.
    case ccd1

    // CCD2
    /// Secondary Camera sensor data.
    /// 
    /// Binary fits data encoded in base64. The CCD2.format is used to indicate the data type (e.g. ".fits")
    /// 
    /// Value of ``INDIPropertyName/ccd2``.
    case ccd2

    // CCD Temperature Ramp Parameters
    /// Maximum temperature change in degrees Celsius per minute.
    /// 
    /// Value of ``INDIPropertyName/ccdTemperatureCoolerRampParameters``.
    case rampSlope

    /// Threshold in degrees celsius. If the absolute difference of target and current temperature
    /// equals to or below this threshold, then the cooling operation is complete.
    /// 
    /// Value of ``INDIPropertyName/ccdTemperatureCoolerRampParameters``.
    case rampThreshold

    // World Coordinate System Control
    /// Enable World Coordinate System keyword inclusion in FITS header.
    /// 
    /// Value of ``INDIPropertyName/worldCoordinateSystemKeywordInclusion``.
    case worldCoordinateSystemEnabled

    /// Disable World Coordinate System keyword inclusion in FITS header.
    /// 
    /// Value of ``INDIPropertyName/worldCoordinateSystemKeywordInclusion``.
    case worldCoordinateSystemDisabled

    // CCD Rotation
    /// Camera field of view rotation measured as East of North in degrees.
    /// 
    /// Value of ``INDIPropertyName/ccdRotation``.
    case ccdRotationValue

    // CCD Transfer Format
    /// Encode captured image as FITS.
    /// 
    /// Value of ``INDIPropertyName/ccdTransferFormat``.
    case formatFits

    /// Send image as-is without encoding.
    /// 
    /// Value of ``INDIPropertyName/ccdTransferFormat``.
    case formatNative

    /// Encode captured images as XISF (eXtensible Image Serialization Format).
    /// 
    /// Value of ``INDIPropertyName/ccdTransferFormat``.
    case formatXisf

    // CCD File Path
    /// Absolute path where images are saved on disk.
    /// 
    /// Value of ``INDIPropertyName/ccdFilePath``.
    case filePath

    // CCD Fast Toggle
    /// Enable fast exposure mode.
    /// 
    /// Value of ``INDIPropertyName/ccdFastToggle``.
    case fastToggleEnabled

    /// Disable fast exposure mode.
    /// 
    /// Value of ``INDIPropertyName/ccdFastToggle``.
    case fastToggleDisabled

    // CCD Fast Count
    /// Number of fast exposure frames to capture once exposure begins.
    /// 
    /// Value of ``INDIPropertyName/ccdFastCount``.
    case frames

    // FITS Header
    /// FITS header keyword name.
    /// 
    /// Value of ``INDIPropertyName/fitsHeader``.
    case keywordName

    /// FITS header keyword value.
    /// 
    /// Value of ``INDIPropertyName/fitsHeader``.
    case keywordValue

    /// FITS header keyword comment.
    /// 
    /// Value of ``INDIPropertyName/fitsHeader``.
    case keywordComment

    // MARK: CCD Streaming Properties

    /// Turn on the video stream.
    /// 
    /// Value of ``INDIPropertyName/ccdVideoStream``.
    case streamOn

    /// Turn off the video stream.
    /// 
    /// Value of ``INDIPropertyName/ccdVideoStream``.
    case streamOff

    // Stream Delay
    /// Stream delay time in seconds.
    /// 
    /// Value of ``INDIPropertyName/streamDelay``.
    case streamDelayTime

    // Streaming Exposure Time
    /// Streaming exposure time in seconds.
    /// 
    /// Value of ``INDIPropertyName/streamingExposureTime``.
    case streamingExposureTimeValue

    // Streaming Divisor
    /// Streaming divisor value. 
    /// 
    /// The divisor is used to skip frames as way to throttle the stream down
    /// 
    /// Value of ``INDIPropertyName/streamingExposureTime``.
    case streamingDivisorValue

    // Instant Frame Rate
    /// Instant frame rate in frames per second.
    /// 
    /// Value of ``INDIPropertyName/framesPerSecond``.
    case instantFrameRate

    // Average Frames Per Second over one Second
    /// Average frame rate in frames per second over 1 second.
    /// 
    /// Value of ``INDIPropertyName/framesPerSecond``.
    case averageFramesPerSecondOneSecond

    // ccdFrameX, ccdFrameY, ccdFrameWidth, ccdFrameHeight are also used for ccd properties

    // Streaming Encoder
    /// Raw stream encoder.
    /// 
    /// Value of ``INDIPropertyName/ccdStreamEncoder``.
    case rawStreamEncoder

    /// MJPEG stream encoder.
    /// 
    /// Value of ``INDIPropertyName/ccdStreamEncoder``.
    case mjpegStreamEncoder

    // SER Stream Recorder
    /// SER stream recorder.
    /// 
    /// Value of ``INDIPropertyName/ccdStreamRecorder``.
    case serStreamRecorder

    /// OGV stream recorder.
    /// 
    /// Value of ``INDIPropertyName/ccdStreamRecorder``.
    case ogvStreamRecorder

    // Limits
    /// Maximum buffer size in MB.
    /// 
    /// Value of ``INDIPropertyName/limits``.
    case maximumBufferSize

    /// Maximum preview frames per second.
    /// 
    /// Value of ``INDIPropertyName/limits``.
    case maximumPreviewFramesPerSecond

    // Record File Directory
    /// Record file directory.
    /// 
    /// Value of ``INDIPropertyName/recordFile``.
    case recordFileDirectory

    // Record File Name
    /// Record file name.
    /// 
    /// Value of ``INDIPropertyName/recordFile``.
    case recordFileName

    // Record Duration
    /// Record duration in seconds.
    /// 
    /// Value of ``INDIPropertyName/recordOptions``.
    case recordDuration

    // Record Frame Total
    /// Total number of frames required for the recording.
    /// 
    /// Value of ``INDIPropertyName/recordOptions``.
    case recordFrameTotal

    // Record Stream
    /// Start recording. Do not stop unless asked to
    /// 
    /// Value of ``INDIPropertyName/recordStream``.
    case recordOn

    /// Start recording until the duration set in ``INDIPropertyName/recordOptions`` has elapsed
    /// 
    /// Value of ``INDIPropertyName/recordStream``.
    case recordDurationOn

    /// Start recording until the number of frames set in ``INDIPropertyName/recordOptions`` has been captured
    /// 
    /// Value of ``INDIPropertyName/recordStream``.
    case recordFrameOn

    /// Stop recording.
    /// 
    /// Value of ``INDIPropertyName/recordStream``.
    case recordOff

    // Fast count
    /// Number of fast exposure captured to take once capture begins.
    /// 
    /// Value of ``INDIPropertyName/ccdFastCount``.
    case numberOfFrames

    // Filter Wheel Properties
    /// Filter wheel slot number.
    /// 
    /// Value of ``INDIPropertyName/filterSlot``.
    case filterSlot

    /// Filter wheel name.
    /// 
    /// Value of ``INDIPropertyName/filterName``.
    case filterName

    // MARK: Focuser Properties

    // Focus Speed
    /// Focus speed value.
    /// 
    /// Set focuser speed. Select focus speed from 0 to N where 0 maps to no motion, and N maps to the fastest speed possible.
    /// 
    /// Value of ``INDIPropertyName/focusSpeed``.
    case focusSpeedValue

    // Focus Motion
    /// Focus inward.
    /// 
    /// Value of ``INDIPropertyName/focusMotion``.
    case focusInward

    /// Focus outward.
    /// 
    /// Value of ``INDIPropertyName/focusMotion``.
    case focusOutward

    // Focus Timer
    /// Focus timer value in milliseconds.
    /// 
    /// Focus in the direction of ``INDIPropertyName/focusMotion`` at rate ``INDIPropertyName/focusSpeed`` for this duration.
    /// 
    /// Value of ``INDIPropertyName/focusTimer``.
    case focusTimerValue

    // Relative Focus Position
    /// Relative focus position in steps.
    /// 
    /// Move this number of steps in the direction specified by ``INDIPropertyName/focusMotion``.
    /// 
    /// Value of ``INDIPropertyName/relativeFocusPosition``.
    case focusRelativePosition

    // Absolute Focus Position
    /// Absolute focus position in steps.
    /// 
    /// Move to this absolute position.
    /// 
    /// Value of ``INDIPropertyName/absoluteFocusPosition``.
    case focusAbsolutePosition

    // Focus Max
    /// Focus maximum travel limit in steps.
    /// 
    /// Value of ``INDIPropertyName/focusMax``.
    case focusMaxValue

    // Focus Reverse Motion
    /// Reverse default motor direction.
    /// 
    /// Value of ``INDIPropertyName/focusReverseMotion``.
    case focusReverseMotionEnabled

    /// Do not reverse, move motor in the default direction.
    /// 
    /// Value of ``INDIPropertyName/focusReverseMotion``.
    case focusReverseMotionDisabled

    // Focus Abort Motion
    /// Abort focus motion.
    /// 
    /// Value of ``INDIPropertyName/focusAbortMotion``.
    case focusAbort

    // Focus Sync
    /// Focus sync value.
    /// 
    /// Accept this position as the new focuser absolute position.
    /// 
    /// Value of ``INDIPropertyName/focusSync``.
    case focusSyncValue

    // Other
    /// Other value.
    /// 
    /// Value of ``INDIPropertyName/other``.
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
        case .ccdExposureValue: return "CCD_EXPOSURE_VALUE"
        case .abortExposure: return "ABORT"
        case .ccdFrameX: return "X"
        case .ccdFrameY: return "Y"
        case .ccdFrameWidth: return "WIDTH"
        case .ccdFrameHeight: return "HEIGHT"
        case .ccdTemperatureValue: return "CCD_TEMPERATURE_VALUE"
        case .ccdCoolerOn: return "COOLER_ON"
        case .ccdCoolerOff: return "COOLER_OFF"
        case .lightFrame: return "FRAME_LIGHT"
        case .biasFrame: return "FRAME_BIAS"
        case .darkFrame: return "FRAME_DARK"
        case .flatFrame: return "FRAME_FLAT"
        case .horizontalBinning: return "HOR_BIN"
        case .verticalBinning: return "VER_BIN"
        case .ccdCompress: return "CCD_COMPRESS"
        case .ccdRaw: return "CCD_RAW"
        case .reset: return "RESET"
        case .ccdMaximumXResolution: return "CCD_MAX_X"
        case .ccdMaximumYResolution: return "CCD_MAX_Y"
        case .ccdPixelSize: return "CCD_PIXEL_SIZE"
        case .ccdPixelSizeX: return "CCD_PIXEL_SIZE_X"
        case .ccdPixelSizeY: return "CCD_PIXEL_SIZE_Y"
        case .ccdBitsPerPixel: return "CCD_BITSPERPIXEL"
        case .cfaOffsetX: return "CFA_OFFSET_X"
        case .cfaOffsetY: return "CFA_OFFSET_Y"
        case .cfaType: return "CFA_TYPE"
        case .ccd1: return "CCD1"
        case .ccd2: return "CCD2"
        case .rampSlope: return "RAMP_SLOPE"
        case .rampThreshold: return "RAMP_THRESHOLD"
        case .worldCoordinateSystemEnabled: return "WCS_ENABLE"
        case .worldCoordinateSystemDisabled: return "WCS_DISABLE"
        case .ccdRotationValue: return "CCD_ROTATION_VALUE"
        case .formatFits: return "FORMAT_FITS"
        case .formatNative: return "FORMAT_NATIVE"
        case .formatXisf: return "FORMAT_XISF"
        case .filePath: return "FILE_PATH"
        case .fastToggleEnabled: return "INDI_ENABLED"
        case .fastToggleDisabled: return "INDI_DISABLED"
        case .frames: return "FRAMES"
        case .keywordName: return "KEYWORD_NAME"
        case .keywordValue: return "KEYWORD_VALUE"
        case .keywordComment: return "KEYWORD_COMMENT"
        case .streamOn: return "STREAM_ON"
        case .streamOff: return "STREAM_OFF"
        case .streamDelayTime: return "STREAM_DELAY_TIME"
        case .streamingExposureTimeValue: return "STREAMING_EXPOSURE_VALUE"
        case .streamingDivisorValue: return "STREAMING_DIVISOR_VALUE"
        case .instantFrameRate: return "EST_FPS"
        case .averageFramesPerSecondOneSecond: return "AVG_FPS"
        case .rawStreamEncoder: return "RAW"
        case .mjpegStreamEncoder: return "MJPEG"
        case .serStreamRecorder: return "SER"
        case .ogvStreamRecorder: return "OGV"
        case .maximumBufferSize: return "LIMITS_BUFFER_MAX"
        case .maximumPreviewFramesPerSecond: return "LIMITS_PREVIEW_FPS"
        case .recordFileDirectory: return "RECORD_FILE_DIR"
        case .recordFileName: return "RECORD_FILE_NAME"
        case .recordDuration: return "RECORD_DURATION"
        case .recordFrameTotal: return "RECORD_FRAME_TOTAL"
        case .recordOn: return "RECORD_ON"
        case .recordDurationOn: return "RECORD_DURATION_ON"
        case .recordFrameOn: return "RECORD_FRAME_ON"
        case .recordOff: return "RECORD_OFF"
        case .numberOfFrames: return "FRAMES"
        case .filterSlot: return "FILTER_SLOT"
        case .filterName: return "FILTER_NAME"
        case .focusSpeedValue: return "FOCUS_SPEED_VALUE"
        case .focusInward: return "FOCUS_INWARD"
        case .focusOutward: return "FOCUS_OUTWARD"
        case .focusTimerValue: return "FOCUS_TIMER_VALUE"
        case .focusRelativePosition: return "FOCUS_RELATIVE_POSITION"
        case .focusAbsolutePosition: return "FOCUS_ABSOLUTE_POSITION"
        case .focusMaxValue: return "FOCUS_MAX_VALUE"
        case .focusReverseMotionEnabled: return "ENABLED"
        case .focusReverseMotionDisabled: return "DISABLED"
        case .focusAbort: return "ABORT"
        case .focusSyncValue: return "FOCUS_SYNC_VALUE"
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
        .simulatePierSide: [.simulateYes, .simulateNo],
        .ccdExposureTime: [.ccdExposureValue],
        .ccdAbortExposure: [.abortExposure],
        .ccdFrame: [.ccdFrameX, .ccdFrameY, .ccdFrameWidth, .ccdFrameHeight],
        .ccdTemperature: [.ccdTemperatureValue],
        .ccdCooler: [.ccdCoolerOn, .ccdCoolerOff],
        .ccdFrameType: [.lightFrame, .biasFrame, .darkFrame, .flatFrame],
        .ccdBinning: [.horizontalBinning, .verticalBinning],
        .ccdCompression: [.ccdCompress, .ccdRaw],
        .ccdFrameReset: [.reset],
        .ccdInfo: [
            .ccdMaximumXResolution, .ccdMaximumYResolution, .ccdPixelSize, .ccdPixelSizeX, .ccdPixelSizeY,
            .ccdBitsPerPixel
        ],
        .ccdColorFilterArray: [.cfaOffsetX, .cfaOffsetY, .cfaType],
        .ccd1: [.ccd1],
        .ccd2: [.ccd2],
        .ccdTemperatureCoolerRampParameters: [.rampSlope, .rampThreshold],
        .worldCoordinateSystemKeywordInclusion: [.worldCoordinateSystemEnabled, .worldCoordinateSystemDisabled],
        .ccdRotation: [.ccdRotationValue],
        .ccdTransferFormat: [.formatFits, .formatNative, .formatXisf],
        .ccdFilePath: [.filePath],
        .ccdFastToggle: [.fastToggleEnabled, .fastToggleDisabled],
        .ccdFastCount: [.frames],
        .fitsHeader: [.keywordName, .keywordValue, .keywordComment],
        .ccdVideoStream: [.streamOn, .streamOff],
        .streamDelay: [.streamDelayTime],
        .streamingExposureTime: [.streamingExposureTimeValue, .streamingDivisorValue],
        .framesPerSecond: [.instantFrameRate, .averageFramesPerSecondOneSecond],
        .ccdStreamingFrameSize: [.ccdFrameX, .ccdFrameY, .ccdFrameWidth, .ccdFrameHeight],
        .ccdStreamEncoder: [.rawStreamEncoder, .mjpegStreamEncoder],
        .ccdStreamRecorder: [.serStreamRecorder, .ogvStreamRecorder],
        .limits: [.maximumBufferSize, .maximumPreviewFramesPerSecond],
        .recordFile: [.recordFileDirectory, .recordFileName],
        .recordOptions: [.recordDuration, .recordFrameTotal],
        .recordStream: [.recordOn, .recordDurationOn, .recordFrameOn, .recordOff],
        .filterSlot: [.filterSlot],
        .filterName: [.filterName],
        .focusSpeed: [.focusSpeedValue],
        .focusMotion: [.focusInward, .focusOutward],
        .focusTimer: [.focusTimerValue],
        .relativeFocusPosition: [.focusRelativePosition],
        .absoluteFocusPosition: [.focusAbsolutePosition],
        .focusMax: [.focusMaxValue],
        .focusReverseMotion: [.focusReverseMotionEnabled, .focusReverseMotionDisabled],
        .focusAbortMotion: [.focusAbort],
        .focusSync: [.focusSyncValue]
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
            .simulateYes, .simulateNo, .ccdExposureValue, .abortExposure, .ccdFrameX, .ccdFrameY, 
            .ccdFrameWidth, .ccdFrameHeight, .ccdTemperatureValue, .ccdCoolerOn, .ccdCoolerOff,
            .lightFrame, .biasFrame, .darkFrame, .flatFrame, .horizontalBinning, .verticalBinning,
            .ccdCompress, .ccdRaw, .reset, .ccdMaximumXResolution, .ccdMaximumYResolution, .ccdPixelSize,
            .ccdPixelSizeX, .ccdPixelSizeY, .ccdBitsPerPixel, .cfaOffsetX, .cfaOffsetY, .cfaType, .ccd1, .ccd2,
            .rampSlope, .rampThreshold, .worldCoordinateSystemEnabled, .worldCoordinateSystemDisabled,
            .ccdRotationValue,
            .formatFits, .formatNative, .formatXisf, .filePath, .fastToggleEnabled, .fastToggleDisabled, .frames,
            .keywordName, .keywordValue, .keywordComment,
            .streamOn, .streamOff, .streamDelayTime, .streamingExposureTimeValue, .streamingDivisorValue,
            .instantFrameRate, .averageFramesPerSecondOneSecond, .rawStreamEncoder, .mjpegStreamEncoder,
            .serStreamRecorder, .ogvStreamRecorder, .maximumBufferSize, .maximumPreviewFramesPerSecond,
            .recordFileDirectory, .recordFileName, .recordDuration, .recordFrameTotal,
            .recordOn, .recordDurationOn, .recordFrameOn, .recordOff, .numberOfFrames,
            .filterSlot, .filterName,
            .focusSpeedValue, .focusInward, .focusOutward, .focusTimerValue,
            .focusRelativePosition, .focusAbsolutePosition, .focusMaxValue,
            .focusReverseMotionEnabled, .focusReverseMotionDisabled, .focusAbort, .focusSyncValue
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

import Foundation

public enum INDIPropertyValueName: Sendable, CaseIterable {

    // MARK: General Properties' values

    // Connection
    case connect
    case disconnect

    // Device Port
    case port
    
    // Local Sideral Time
    case localSideralTime
    
    // Universal Time
    case universalTime
    case offset
    
    // Geographic Coordinates
    case latitude
    case longitude
    case elevation

    // Atmosphere
    case temperature
    case pressure
    case humidity

    // TODO: Add more property values

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

        case .other(let name): return name
        }
    }

    public func expectedValueNames(for property: INDIPropertyName) -> [INDIPropertyValueName]? {
        switch property {
        case .connection: return [.connect, .disconnect]
        case .devicePort: return [.port]
        case .localSideralTime: return [.localSideralTime]
        case .universalTime: return [.universalTime, .offset]
        case .geographicCoordinates: return [.latitude, .longitude, .elevation]
        case .atmosphere: return [.temperature, .pressure, .humidity]
        // TODO: Add more properties
        default: return nil
        }
    }

    /// All known value name cases (excluding `.other` which has infinite possible values).
    public static var allCases: [INDIPropertyValueName] {
        [
            .connect, .disconnect, .port, .localSideralTime, .universalTime, .offset,
            .latitude, .longitude, .elevation, .temperature, .pressure, .humidity
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

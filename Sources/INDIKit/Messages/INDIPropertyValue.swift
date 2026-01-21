import Foundation

public enum INDIPropertyValue: Sendable {

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

}

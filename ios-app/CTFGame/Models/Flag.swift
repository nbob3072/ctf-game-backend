import Foundation
import CoreLocation
import MapKit

struct Flag: Codable, Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let type: FlagType
    let distanceMeters: Double?
    let ownerTeam: TeamInfo?
    let ownerUsername: String?
    let hasDefender: Bool
    let defender: Defender?
    let totalCaptures: Int?
    let capturedAt: Date?
    let captureRadius: Double?
    
    // Computed properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isCapturable: Bool {
        guard let distance = distanceMeters else { return false }
        let radius = captureRadius ?? 30.0 // Default 30m
        return distance <= radius
    }
    
    var isNeutral: Bool {
        return ownerTeam == nil
    }
    
    var teamColor: String {
        return ownerTeam?.color ?? "#808080" // Gray for neutral
    }
    
    // Distance formatted for display
    var formattedDistance: String {
        guard let distance = distanceMeters else { return "Unknown" }
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

enum FlagType: String, Codable {
    case common
    case rare
    case legendary
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .common: return "🚩"
        case .rare: return "⭐"
        case .legendary: return "👑"
        }
    }
    
    var xpReward: Int {
        switch self {
        case .common: return 100
        case .rare: return 500
        case .legendary: return 2000
        }
    }
}

struct TeamInfo: Codable {
    let id: Int?
    let name: String
    let color: String
}

struct FlagsResponse: Codable {
    let userLocation: LocationInfo
    let flags: [Flag]
    let count: Int
}

struct LocationInfo: Codable {
    let latitude: Double
    let longitude: Double
}

struct FlagDetailResponse: Codable {
    let flag: FlagDetail
}

struct FlagDetail: Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let type: FlagType
    let totalCaptures: Int
    let currentOwner: FlagOwner?
    let defender: Defender?
    let recentCaptures: [Capture]?
}

struct FlagOwner: Codable {
    let username: String
    let team: TeamInfo
}

// MapKit annotation for flags
class FlagAnnotation: NSObject, MKAnnotation {
    let flag: Flag
    
    var coordinate: CLLocationCoordinate2D {
        flag.coordinate
    }
    
    var title: String? {
        flag.name
    }
    
    var subtitle: String? {
        if let team = flag.ownerTeam {
            return "\(team.name) • \(flag.type.displayName)"
        }
        return "Neutral • \(flag.type.displayName)"
    }
    
    init(flag: Flag) {
        self.flag = flag
        super.init()
    }
}

import Foundation

struct Defender: Codable, Identifiable {
    let id: String?
    let name: String
    let strength: Int
    let duration: Int? // seconds
    let deployedBy: String?
    let deployedAt: Date?
    let expiresAt: Date?
    let description: String?
    
    // Computed properties
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var remainingTime: TimeInterval? {
        guard let expiresAt = expiresAt else { return nil }
        return expiresAt.timeIntervalSince(Date())
    }
    
    var formattedRemainingTime: String {
        guard let remaining = remainingTime, remaining > 0 else {
            return "Expired"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var strengthLevel: DefenderStrength {
        switch strength {
        case 0..<30: return .weak
        case 30..<60: return .medium
        case 60..<80: return .strong
        default: return .legendary
        }
    }
}

enum DefenderStrength {
    case weak
    case medium
    case strong
    case legendary
    
    var displayName: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        case .legendary: return "Legendary"
        }
    }
    
    var emoji: String {
        switch self {
        case .weak: return "🛡️"
        case .medium: return "⚔️"
        case .strong: return "🏰"
        case .legendary: return "👑"
        }
    }
}

struct DefenderType: Codable, Identifiable {
    let id: Int
    let name: String
    let strength: Int
    let duration: Int
    let cost: Int?
    let description: String
    let unlockLevel: Int?
    
    var formattedDuration: String {
        let hours = duration / 3600
        if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = duration / 60
            return "\(minutes)m"
        }
    }
}

struct DefenderTypesResponse: Codable {
    let defenderTypes: [DefenderType]
}

// Request models
struct DeployDefenderRequest: Codable {
    let defenderTypeId: Int
}

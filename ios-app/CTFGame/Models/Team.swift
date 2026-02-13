import SwiftUI

struct Team: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let color: String
    let description: String
    let motto: String?
    
    // SwiftUI Color from hex string
    var colorValue: Color {
        Color(hex: color) ?? .gray
    }
    
    // Static team definitions (matching backend)
    static let titans = Team(
        id: 1,
        name: "Titans",
        color: "#E74C3C",
        description: "Strength through unity, aggressive expansion",
        motto: "Conquer and Dominate"
    )
    
    static let guardians = Team(
        id: 2,
        name: "Guardians",
        color: "#3498DB",
        description: "Protect and defend, honor above all",
        motto: "Defend with Honor"
    )
    
    static let phantoms = Team(
        id: 3,
        name: "Phantoms",
        color: "#2ECC71",
        description: "Speed and stealth, strike from shadows",
        motto: "Strike from Shadows"
    )
    
    static let allTeams: [Team] = [titans, guardians, phantoms]
    
    // Team emoji for fun
    var emoji: String {
        switch id {
        case 1: return "⚔️"
        case 2: return "🛡️"
        case 3: return "👻"
        default: return "🚩"
        }
    }
}

struct TeamStats: Codable {
    let teamId: Int
    let teamName: String
    let memberCount: Int
    let flagsControlled: Int
    let totalCaptures: Int
    let totalTeamXp: Int
    let avgLevel: Double
}

struct TeamStatsResponse: Codable {
    let team: Team
    let stats: TeamStats
    let topMembers: [User]?
    let recentCaptures: [Capture]?
}

// Extension for hex color parsing
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

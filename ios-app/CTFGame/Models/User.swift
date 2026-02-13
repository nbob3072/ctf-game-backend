import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    var teamId: Int?
    var level: Int
    var xp: Int
    var captureCount: Int?
    var createdAt: Date?
    
    // Computed property for team
    var team: Team? {
        guard let teamId = teamId else { return nil }
        return Team.allTeams.first { $0.id == teamId }
    }
    
    // Progress to next level
    var xpProgress: Double {
        let currentLevelXP = xpForLevel(level)
        let nextLevelXP = xpForLevel(level + 1)
        let levelRange = nextLevelXP - currentLevelXP
        let currentProgress = xp - currentLevelXP
        
        return Double(currentProgress) / Double(levelRange)
    }
    
    var xpToNextLevel: Int {
        return xpForLevel(level + 1) - xp
    }
    
    // XP required for a given level (simple formula)
    private func xpForLevel(_ level: Int) -> Int {
        return level * level * 100
    }
}

struct UserStats: Codable {
    let captureCount: Int
    let defenseCount: Int
    let battleWins: Int
    let battleLosses: Int
    let totalDistance: Double // meters traveled
    let longestStreak: Int
    let favoriteFlag: String?
}

struct AuthResponse: Codable {
    let message: String
    let user: User
    let token: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let teamId: Int?
}

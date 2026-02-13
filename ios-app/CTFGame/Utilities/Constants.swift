import Foundation

enum Constants {
    // MARK: - API
    enum API {
        static let baseURL = "http://192.168.9.206:3000"
        static let wsURL = "ws://192.168.9.206:3001"
        static let timeout: TimeInterval = 30
    }
    
    // MARK: - Game Settings
    enum Game {
        static let defaultCaptureRadius: Double = 30.0 // meters
        static let flagRefreshRadius: Double = 2000.0 // meters (2km)
        static let locationUpdateDistance: Double = 10.0 // meters
        static let autoRefreshDistance: Double = 500.0 // meters
    }
    
    // MARK: - XP & Levels
    enum XP {
        static func xpForLevel(_ level: Int) -> Int {
            return level * level * 100
        }
        
        static func levelForXP(_ xp: Int) -> Int {
            return Int(sqrt(Double(xp) / 100.0))
        }
    }
    
    // MARK: - Map
    enum Map {
        static let defaultLatitude = 37.7749 // San Francisco
        static let defaultLongitude = -122.4194
        static let defaultSpan = 0.05
    }
    
    // MARK: - Notifications
    enum Notifications {
        static let flagCaptured = "FlagCapturedNotification"
        static let flagUnderAttack = "FlagUnderAttackNotification"
        static let levelUp = "LevelUpNotification"
    }
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTeamId = "selectedTeamId"
        static let lastKnownLatitude = "lastKnownLatitude"
        static let lastKnownLongitude = "lastKnownLongitude"
    }
}

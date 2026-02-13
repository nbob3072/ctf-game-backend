import Foundation

struct Capture: Codable, Identifiable {
    let id: String
    let flagId: String
    let flagName: String?
    let userId: String
    let username: String?
    let teamId: Int
    let capturedAt: Date
    let xpEarned: Int?
    let durationHeld: Int? // seconds
    let battleOccurred: Bool?
    
    // Formatted time since capture
    var formattedTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(capturedAt)
        
        let minutes = Int(interval) / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

struct CaptureRequest: Codable {
    let latitude: Double
    let longitude: Double
    let defenderTypeId: Int?
}

struct CaptureResponse: Codable {
    let message: String
    let capture: CaptureResult
}

struct CaptureResult: Codable {
    let flagId: String
    let flagName: String
    let xpEarned: Int
    let battleOccurred: Bool?
    let newLevel: Int?
    let totalXp: Int
    let deployedDefender: Defender?
}

struct CaptureHistory: Codable {
    let captures: [Capture]
    let totalCount: Int
    let totalXpEarned: Int
}

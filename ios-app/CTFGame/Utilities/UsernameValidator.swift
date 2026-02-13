import Foundation

struct UsernameValidator {
    
    // Basic profanity list (iOS mirrors backend validation)
    private static let profaneWords: Set<String> = [
        "fuck", "shit", "damn", "hell", "ass", "bitch", "bastard", "crap",
        "dick", "cock", "pussy", "cunt", "twat", "slut", "whore",
        "fck", "fuk", "fvck", "sh*t", "b*tch", "a$$", "azz",
        "porn", "xxx", "sex", "rape", "nazi", "kill"
    ]
    
    private static let reserved: Set<String> = [
        "admin", "moderator", "system", "official", "staff", "support", "root"
    ]
    
    static func validate(_ username: String) -> ValidationResult {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        
        // Length check
        if trimmed.count < 3 {
            return .invalid("Username must be at least 3 characters")
        }
        
        if trimmed.count > 20 {
            return .invalid("Username must be 20 characters or less")
        }
        
        // Character check - alphanumeric + underscore + hyphen only
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        if trimmed.unicodeScalars.contains(where: { !allowedCharacters.contains($0) }) {
            return .invalid("Username can only contain letters, numbers, underscores, and hyphens")
        }
        
        // Profanity check
        let lowercased = trimmed.lowercased()
        for word in profaneWords {
            if lowercased.contains(word) {
                return .invalid("Username contains inappropriate language")
            }
        }
        
        // Reserved words check
        if reserved.contains(lowercased) {
            return .invalid("This username is reserved")
        }
        
        return .valid
    }
    
    enum ValidationResult {
        case valid
        case invalid(String)
        
        var isValid: Bool {
            if case .valid = self {
                return true
            }
            return false
        }
        
        var errorMessage: String? {
            if case .invalid(let message) = self {
                return message
            }
            return nil
        }
    }
}

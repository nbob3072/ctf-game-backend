import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let serviceName = "com.ctfgame.app"
    
    private init() {}
    
    enum KeychainKey: String {
        case authToken = "auth_token"
        case refreshToken = "refresh_token"
        case userId = "user_id"
    }
    
    // MARK: - Save
    
    func save(token: String, for key: KeychainKey) {
        let data = Data(token.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        // Delete existing item if it exists
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            Logger.debug("Keychain: Saved \(key.rawValue)")
        } else {
            Logger.error("Keychain: Failed to save \(key.rawValue) - Status: \(status)")
        }
    }
    
    // MARK: - Load
    
    func load(for key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                Logger.error("Keychain: Failed to load \(key.rawValue) - Status: \(status)")
            }
            return nil
        }
        
        Logger.debug("Keychain: Loaded \(key.rawValue)")
        return token
    }
    
    // MARK: - Delete
    
    func delete(for key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            Logger.debug("Keychain: Deleted \(key.rawValue)")
        } else {
            Logger.error("Keychain: Failed to delete \(key.rawValue) - Status: \(status)")
        }
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        delete(for: .authToken)
        delete(for: .refreshToken)
        delete(for: .userId)
        Logger.debug("Keychain: Cleared all data")
    }
}

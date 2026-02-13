import Foundation
import LocalAuthentication

class BiometricAuthService {
    static let shared = BiometricAuthService()
    
    private init() {}
    
    // MARK: - Biometric Availability
    
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    var isBiometricAvailable: Bool {
        return biometricType != .none
    }
    
    var biometricName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Biometric"
        }
    }
    
    // MARK: - Authentication
    
    func authenticate(reason: String? = nil) async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw BiometricError.notAvailable(error.localizedDescription)
            }
            throw BiometricError.notAvailable("Biometric authentication not available")
        }
        
        let authReason = reason ?? "Authenticate to access your account"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: authReason
            )
            return success
        } catch let error as LAError {
            switch error.code {
            case .userCancel:
                throw BiometricError.userCancelled
            case .userFallback:
                throw BiometricError.fallbackRequested
            case .biometryNotAvailable:
                throw BiometricError.notAvailable("Biometric authentication not available")
            case .biometryNotEnrolled:
                throw BiometricError.notEnrolled
            case .biometryLockout:
                throw BiometricError.lockout
            default:
                throw BiometricError.failed(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Settings
    
    var isBiometricLoginEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "biometric_login_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "biometric_login_enabled")
        }
    }
    
    func enableBiometricLogin() {
        isBiometricLoginEnabled = true
    }
    
    func disableBiometricLogin() {
        isBiometricLoginEnabled = false
        // Clear biometric-protected token
        KeychainService.shared.delete(for: .authToken)
    }
}

// MARK: - Types

enum BiometricType {
    case faceID
    case touchID
    case opticID
    case none
}

enum BiometricError: LocalizedError {
    case notAvailable(String)
    case notEnrolled
    case lockout
    case userCancelled
    case fallbackRequested
    case failed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable(let reason):
            return "Biometric authentication not available: \(reason)"
        case .notEnrolled:
            return "No biometric authentication is enrolled on this device"
        case .lockout:
            return "Biometric authentication is locked. Please try again later."
        case .userCancelled:
            return "Authentication cancelled"
        case .fallbackRequested:
            return "User requested password fallback"
        case .failed(let reason):
            return "Authentication failed: \(reason)"
        }
    }
}

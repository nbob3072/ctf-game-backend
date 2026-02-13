import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    private let biometricService = BiometricAuthService.shared
    
    var canUseBiometric: Bool {
        biometricService.isBiometricAvailable && biometricService.isBiometricLoginEnabled
    }
    
    var biometricName: String {
        biometricService.biometricName
    }
    
    init() {
        // Check if user has valid token on init
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isLoading = true
        
        // Check if token exists in keychain
        if let token = keychainService.load(for: .authToken) {
            // Validate token by fetching user profile
            Task {
                do {
                    let user = try await apiService.getCurrentUser()
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                } catch {
                    // Token invalid or expired
                    self.logout()
                }
            }
        } else {
            isLoading = false
        }
    }
    
    func register(username: String, email: String, password: String, teamId: Int?) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(
                username: username,
                email: email,
                password: password,
                teamId: teamId
            )
            
            let response = try await apiService.register(request)
            
            // Save token
            keychainService.save(token: response.token, for: .authToken)
            
            // Update state
            self.currentUser = response.user
            self.isAuthenticated = true
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(email: email, password: password)
            let response = try await apiService.login(request)
            
            // Save token
            keychainService.save(token: response.token, for: .authToken)
            
            // Update state
            self.currentUser = response.user
            self.isAuthenticated = true
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    func logout() {
        Task {
            try? await apiService.logout()
        }
        
        // Clear token
        keychainService.delete(for: .authToken)
        
        // Disconnect WebSocket
        WebSocketService.shared.disconnect()
        
        // Clear state
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func refreshUser() async {
        do {
            let user = try await apiService.getCurrentUser()
            self.currentUser = user
        } catch {
            Logger.error("Failed to refresh user: \(error)")
        }
    }
    
    // MARK: - Biometric Authentication
    
    func loginWithBiometric() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Authenticate with biometrics
            _ = try await biometricService.authenticate(reason: "Log in to CTFGame")
            
            // Check if we have a saved token
            guard let token = keychainService.load(for: .authToken) else {
                self.isLoading = false
                throw BiometricError.failed("No saved login found")
            }
            
            // Validate token by fetching user profile
            let user = try await apiService.getCurrentUser()
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    func enableBiometricLogin() {
        biometricService.enableBiometricLogin()
    }
    
    func disableBiometricLogin() {
        biometricService.disableBiometricLogin()
    }
    
    var shouldOfferBiometricEnrollment: Bool {
        // Offer if biometric is available but not enabled
        return biometricService.isBiometricAvailable && !biometricService.isBiometricLoginEnabled
    }
    
    // MARK: - Account Deletion
    
    func deleteAccount() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete account on server
            try await apiService.deleteAccount()
            
            // Clear local data
            keychainService.delete(for: .authToken)
            biometricService.disableBiometricLogin()
            WebSocketService.shared.disconnect()
            
            // Clear state
            currentUser = nil
            isAuthenticated = false
            isLoading = false
            
            Logger.info("Account deleted successfully")
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
}

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var stats: UserStats?
    @Published var recentCaptures: [Capture] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Load user data
                let user = try await apiService.getCurrentUser()
                self.user = user
                
                // Load stats (placeholder - would need backend endpoint)
                // let stats = try await apiService.getUserStats()
                // self.stats = stats
                
                // Load recent captures (placeholder - would need backend endpoint)
                // let captures = try await apiService.getRecentCaptures(limit: 10)
                // self.recentCaptures = captures
                
                self.isLoading = false
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                Logger.error("Failed to load profile: \(error)")
            }
        }
    }
    
    func refresh() {
        loadProfile()
    }
}

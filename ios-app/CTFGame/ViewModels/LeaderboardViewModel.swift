import Foundation
import Combine

struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let rank: Int
    let username: String
    let teamName: String
    let teamColor: String
    let level: Int
    let xp: Int
    let captureCount: Int
}

struct LeaderboardResponse: Codable {
    let type: String
    let leaderboard: [LeaderboardEntry]
    let cached: Bool?
}

struct TeamLeaderboardEntry: Codable, Identifiable {
    var id: Int { teamId }
    let teamId: Int
    let teamName: String
    let memberCount: Int
    let flagsControlled: Int
    let totalCaptures: Int
    let totalTeamXp: Int
}

struct TeamLeaderboardResponse: Codable {
    let type: String
    let leaderboard: [TeamLeaderboardEntry]
}

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var globalLeaderboard: [LeaderboardEntry] = []
    @Published var teamLeaderboard: [TeamLeaderboardEntry] = []
    @Published var myRank: LeaderboardEntry?
    @Published var selectedType: LeaderboardType = .global
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    enum LeaderboardType {
        case global
        case team
    }
    
    func loadLeaderboard(type: LeaderboardType = .global, limit: Int = 100) {
        isLoading = true
        errorMessage = nil
        selectedType = type
        
        Task {
            do {
                switch type {
                case .global:
                    let response = try await apiService.getGlobalLeaderboard(limit: limit)
                    self.globalLeaderboard = response.leaderboard
                    
                    // Load my rank separately
                    await loadMyRank()
                    
                case .team:
                    let response = try await apiService.getTeamLeaderboard()
                    self.teamLeaderboard = response.leaderboard
                }
                
                self.isLoading = false
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                Logger.error("Failed to load leaderboard: \(error)")
            }
        }
    }
    
    private func loadMyRank() async {
        do {
            let response = try await apiService.getMyRank()
            self.myRank = response
        } catch {
            Logger.error("Failed to load my rank: \(error)")
        }
    }
    
    func refresh() {
        loadLeaderboard(type: selectedType)
    }
}

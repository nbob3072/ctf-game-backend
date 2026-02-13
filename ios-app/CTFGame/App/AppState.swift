import SwiftUI
import Combine

/// Global application state
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var selectedTeam: Team?
    @Published var currentCity: String = "San Francisco" // Default city
    @Published var isOfflineMode: Bool = false
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding(withTeam team: Team) {
        self.selectedTeam = team
        self.hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        selectedTeam = nil
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}

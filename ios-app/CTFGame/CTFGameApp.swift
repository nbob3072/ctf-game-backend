import SwiftUI

@main
struct CTFGameApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    init() {
        // Configure app appearance
        setupAppearance()
        
        // Request notification permissions on launch
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
                .environmentObject(mapViewModel)
                .preferredColorScheme(.dark) // CTF game uses dark mode
                .onAppear {
                    // Auto-login if token exists
                    authViewModel.checkAuthStatus()
                    
                    // Start location services
                    LocationService.shared.requestPermission()
                }
        }
    }
    
    private func setupAppearance() {
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Customize tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                LoadingView(message: "Loading...")
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else if appState.hasCompletedOnboarding {
                LoginView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct MainTabView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.white)
        .onAppear {
            // Start real-time updates
            WebSocketService.shared.connect()
            
            // Load initial data
            mapViewModel.loadNearbyFlags()
        }
    }
}

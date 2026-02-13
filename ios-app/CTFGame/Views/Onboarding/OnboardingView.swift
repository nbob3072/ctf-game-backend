import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#0F2027") ?? .black, Color(hex: "#203A43") ?? .gray, Color(hex: "#2C5364") ?? .gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Logo/Title
                VStack(spacing: 8) {
                    Text("🚩")
                        .font(.system(size: 50))
                    
                    Text("CTF GAME")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Capture The Flag")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Features carousel
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "🗺️",
                        title: "Explore Your City",
                        description: "Flags appear at landmarks and interesting locations near you"
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "⚔️",
                        title: "Capture & Defend",
                        description: "Claim flags for your team and deploy defenders to protect them"
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "👥",
                        title: "Join a Team",
                        description: "Choose Titans, Guardians, or Phantoms and compete nationwide"
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        icon: "🏆",
                        title: "Climb the Ranks",
                        description: "Earn XP, level up, and dominate the leaderboards"
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 280)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    withAnimation {
                        appState.hasCompletedOnboarding = true
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#E74C3C") ?? .red, Color(hex: "#C0392B") ?? .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 50))
            
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.callout)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineLimit(3)
        }
        .padding(.vertical, 10)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}

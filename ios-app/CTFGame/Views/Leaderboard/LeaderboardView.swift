import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedType: LeaderboardType = .global
    
    enum LeaderboardType {
        case global
        case team
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1a1a2e")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segment Picker
                    Picker("Type", selection: $selectedType) {
                        Text("Global").tag(LeaderboardType.global)
                        Text("Teams").tag(LeaderboardType.team)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedType) { newType in
                        loadLeaderboard(type: newType)
                    }
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading...")
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                // My Rank (for global)
                                if selectedType == .global, let myRank = viewModel.myRank {
                                    MyRankCard(entry: myRank)
                                        .padding(.horizontal)
                                        .padding(.top, 10)
                                }
                                
                                // Leaderboard entries
                                if selectedType == .global {
                                    ForEach(viewModel.globalLeaderboard) { entry in
                                        GlobalLeaderboardRow(entry: entry, currentUserId: authViewModel.currentUser.map { String($0.id) })
                                    }
                                    .padding(.horizontal)
                                } else {
                                    ForEach(viewModel.teamLeaderboard) { entry in
                                        TeamLeaderboardRow(entry: entry)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                loadLeaderboard(type: selectedType)
            }
        }
    }
    
    private func loadLeaderboard(type: LeaderboardType) {
        switch type {
        case .global:
            viewModel.loadLeaderboard(type: .global)
        case .team:
            viewModel.loadLeaderboard(type: .team)
        }
    }
}

struct MyRankCard: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Your Rank")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                // Rank
                Text("#\(entry.rank)")
                    .font(.title.bold())
                    .foregroundColor(.yellow)
                    .frame(width: 80)
                
                Divider()
                    .background(Color.gray)
                
                // Stats
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(entry.teamName)
                            .font(.subheadline.bold())
                            .foregroundColor(Color(hex: entry.teamColor))
                        
                        Spacer()
                        
                        Text("Lv \(entry.level)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("\(entry.xp) XP")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(entry.captureCount) captures")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct GlobalLeaderboardRow: View {
    let entry: LeaderboardEntry
    let currentUserId: String?
    
    var isCurrentUser: Bool {
        entry.id == currentUserId
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            ZStack {
                if entry.rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 40, height: 40)
                    
                    Text(rankEmoji)
                        .font(.title3)
                } else {
                    Text("#\(entry.rank)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(width: 40)
                }
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.username)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(entry.teamName)
                        .font(.caption)
                        .foregroundColor(Color(hex: entry.teamColor))
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("Lv \(entry.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.xp) XP")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                Text("\(entry.captureCount) flags")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return Color(hex: "#C0C0C0") ?? .gray
        case 3: return Color(hex: "#CD7F32") ?? .orange
        default: return .gray
        }
    }
    
    private var rankEmoji: String {
        switch entry.rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}

struct TeamLeaderboardRow: View {
    let entry: TeamLeaderboardEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text("#\(entry.teamId)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 40)
            
            // Team icon
            Text(Team.allTeams.first { $0.id == entry.teamId }?.emoji ?? "🚩")
                .font(.title2)
            
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.teamName)
                    .font(.headline.bold())
                    .foregroundColor(Team.allTeams.first { $0.id == entry.teamId }?.colorValue ?? .white)
                
                Text("\(entry.memberCount) members")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.totalTeamXp) XP")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                Text("\(entry.flagsControlled) flags")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .environmentObject(AuthViewModel())
    }
}

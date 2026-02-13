import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var deleteConfirmationText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1a1a2e")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // User Header
                        if let user = authViewModel.currentUser {
                            VStack(spacing: 15) {
                                // Avatar / Team Badge
                                ZStack {
                                    Circle()
                                        .fill(user.team?.colorValue.opacity(0.3) ?? Color.gray.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                    
                                    Text(user.team?.emoji ?? "👤")
                                        .font(.system(size: 50))
                                }
                                .padding(.top, 20)
                                
                                // Username
                                Text(user.username)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                
                                // Team badge
                                if let team = user.team {
                                    HStack {
                                        Text(team.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(team.colorValue)
                                    .cornerRadius(20)
                                }
                                
                                // Level and XP
                                VStack(spacing: 8) {
                                    HStack(spacing: 20) {
                                        StatItem(label: "Level", value: "\(user.level)")
                                        Divider()
                                            .frame(height: 30)
                                            .background(Color.gray)
                                        StatItem(label: "XP", value: "\(user.xp)")
                                        Divider()
                                            .frame(height: 30)
                                            .background(Color.gray)
                                        StatItem(label: "Captures", value: "\(user.captureCount)")
                                    }
                                    
                                    // XP Progress bar
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Progress to Level \(user.level + 1)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        ProgressView(value: user.xpProgress)
                                            .tint(user.team?.colorValue ?? .blue)
                                        
                                        Text("\(user.xpToNextLevel) XP to next level")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                            
                            // Stats Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Statistics")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                
                                StatRow(icon: "flag.fill", title: "Total Captures", value: "\(user.captureCount)")
                                StatRow(icon: "trophy.fill", title: "Total XP Earned", value: "\(user.xp)")
                                StatRow(icon: "calendar", title: "Member Since", value: formatDate(user.createdAt))
                                StatRow(icon: "envelope.fill", title: "Email", value: user.email)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            
                            // Settings Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Settings")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                
                                // Biometric Login Toggle
                                if BiometricAuthService.shared.isBiometricAvailable {
                                    Toggle(isOn: Binding(
                                        get: { BiometricAuthService.shared.isBiometricLoginEnabled },
                                        set: { enabled in
                                            if enabled {
                                                authViewModel.enableBiometricLogin()
                                            } else {
                                                authViewModel.disableBiometricLogin()
                                            }
                                        }
                                    )) {
                                        HStack {
                                            Image(systemName: BiometricAuthService.shared.biometricName == "Face ID" ? "faceid" : "touchid")
                                                .foregroundColor(.white)
                                            Text("Enable \(BiometricAuthService.shared.biometricName)")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .tint(user.team?.colorValue ?? .blue)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            
                            // Actions
                            VStack(spacing: 12) {
                                // Logout Button
                                Button(action: {
                                    showingLogoutAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square")
                                        Text("Logout")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.orange.opacity(0.8))
                                    .cornerRadius(12)
                                }
                                
                                // Delete Account Button
                                Button(action: {
                                    showingDeleteAccountAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete Account")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await authViewModel.refreshUser()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                Task {
                    do {
                        try await authViewModel.deleteAccount()
                    } catch {
                        print("Failed to delete account: \(error)")
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. All your data including captures, XP, and leaderboard stats will be permanently deleted.")
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}

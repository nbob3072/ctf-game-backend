import SwiftUI

struct FlagDetailView: View {
    let flag: Flag
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDefender: DefenderType?
    @State private var showingDefenderSelection = false
    @State private var captureSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1a1a2e")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Flag Header
                        VStack(spacing: 10) {
                            Text(flag.type.emoji)
                                .font(.system(size: 60))
                            
                            Text(flag.name)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text(flag.type.displayName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Distance
                        if let distance = flag.distanceMeters {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text(flag.formattedDistance + " away")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                        }
                        
                        Divider()
                            .background(Color.gray)
                            .padding(.horizontal)
                        
                        // Ownership Info
                        VStack(spacing: 15) {
                            if let ownerTeam = flag.ownerTeam {
                                VStack(spacing: 8) {
                                    Text("Controlled by")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text(Team.allTeams.first { $0.id == ownerTeam.id }?.emoji ?? "🚩")
                                            .font(.title2)
                                        
                                        Text(ownerTeam.name)
                                            .font(.title3.bold())
                                            .foregroundColor(Color(hex: ownerTeam.color))
                                    }
                                    
                                    if let owner = flag.ownerUsername {
                                        Text("Captured by \(owner)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                VStack(spacing: 8) {
                                    Text("⚪️")
                                        .font(.title)
                                    Text("Neutral Flag")
                                        .font(.title3.bold())
                                        .foregroundColor(.gray)
                                    Text("No team controls this flag")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Defender Info
                            if flag.hasDefender, let defender = flag.defender {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(defender.strengthLevel.emoji)
                                        Text("Defended")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(defender.name)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    // Strength bar
                                    HStack {
                                        Text("Strength:")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        ProgressView(value: Double(defender.strength), total: 100)
                                            .tint(Color.orange)
                                        
                                        Text("\(defender.strength)")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Expires in \(defender.formattedRemainingTime)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats
                        if let captures = flag.totalCaptures {
                            HStack(spacing: 30) {
                                StatBox(title: "Captures", value: "\(captures)")
                                StatBox(title: "XP Reward", value: "\(flag.type.xpReward)")
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if canCapture {
                                // Capture/Attack Button
                                Button(action: {
                                    showingDefenderSelection = true
                                }) {
                                    HStack {
                                        Image(systemName: isEnemyFlag ? "bolt.fill" : "flag.fill")
                                        Text(isEnemyFlag ? "Attack Flag" : "Capture Flag")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        isEnemyFlag ?
                                        Color.red :
                                        (authViewModel.currentUser?.team?.colorValue ?? Color.blue)
                                    )
                                    .cornerRadius(16)
                                }
                            } else if let distance = flag.distanceMeters, distance > (flag.captureRadius ?? 30) {
                                // Too far
                                VStack(spacing: 8) {
                                    Image(systemName: "location.slash")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    Text("Get within \(Int(flag.captureRadius ?? 30))m to capture")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(16)
                            } else if isOwnTeamFlag {
                                // Already owned by team
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    Text("Your team controls this flag")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingDefenderSelection) {
            DefenderSelectionView(flag: flag, onCapture: performCapture)
        }
        .alert("Success!", isPresented: $captureSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if let result = mapViewModel.lastCaptureResult {
                Text("You captured \(result.flagName) and earned \(result.xpEarned) XP!")
            }
        }
    }
    
    private var canCapture: Bool {
        guard let distance = flag.distanceMeters else { return false }
        let radius = flag.captureRadius ?? 30.0
        return distance <= radius && !isOwnTeamFlag
    }
    
    private var isOwnTeamFlag: Bool {
        guard let userTeamId = authViewModel.currentUser?.teamId,
              let flagTeamId = flag.ownerTeam?.id else {
            return false
        }
        return userTeamId == flagTeamId
    }
    
    private var isEnemyFlag: Bool {
        return flag.ownerTeam != nil && !isOwnTeamFlag
    }
    
    private func performCapture(defenderTypeId: Int?) {
        Task {
            do {
                try await mapViewModel.captureFlag(flag, withDefender: defenderTypeId)
                captureSuccess = true
            } catch {
                Logger.error("Capture failed: \(error)")
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DefenderSelectionView: View {
    let flag: Flag
    let onCapture: (Int?) -> Void
    @EnvironmentObject var mapViewModel: MapViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDefender: DefenderType?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a1a2e")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Deploy a Defender")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Protect your capture with a virtual defender")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Defender list
                    ScrollView {
                        VStack(spacing: 12) {
                            // Option: No defender
                            DefenderCard(
                                name: "No Defender",
                                strength: 0,
                                duration: "N/A",
                                isSelected: selectedDefender == nil
                            )
                            .onTapGesture {
                                selectedDefender = nil
                            }
                            
                            // Available defenders
                            ForEach(mapViewModel.defenderTypes) { defender in
                                DefenderCard(
                                    name: defender.name,
                                    strength: defender.strength,
                                    duration: defender.formattedDuration,
                                    isSelected: selectedDefender?.id == defender.id
                                )
                                .onTapGesture {
                                    selectedDefender = defender
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Capture button
                    Button(action: {
                        onCapture(selectedDefender?.id)
                        dismiss()
                    }) {
                        Text("Capture Flag")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct DefenderCard: View {
    let name: String
    let strength: Int
    let duration: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Strength: \(strength)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("Duration: \(duration)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

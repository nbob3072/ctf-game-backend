import SwiftUI

struct TeamSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTeam: Team?
    @State private var showingRegister = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1a1a2e")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Choose Your Team")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("This choice is permanent!")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.top, 50)
                
                // Team Cards
                VStack(spacing: 20) {
                    ForEach(Team.allTeams) { team in
                        TeamCard(
                            team: team,
                            isSelected: selectedTeam?.id == team.id
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedTeam = team
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if let team = selectedTeam {
                        appState.selectedTeam = team
                        showingRegister = true
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedTeam != nil ? selectedTeam!.colorValue : Color.gray)
                        .cornerRadius(16)
                        .opacity(selectedTeam != nil ? 1.0 : 0.5)
                }
                .disabled(selectedTeam == nil)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showingRegister) {
            RegisterView()
        }
    }
}

struct TeamCard: View {
    let team: Team
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Team Icon
            ZStack {
                Circle()
                    .fill(team.colorValue.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Text(team.emoji)
                    .font(.system(size: 30))
            }
            
            // Team Info
            VStack(alignment: .leading, spacing: 5) {
                Text(team.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Text(team.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if let motto = team.motto {
                    Text("\"\(motto)\"")
                        .font(.caption2.italic())
                        .foregroundColor(team.colorValue)
                }
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(team.colorValue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? team.colorValue : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct TeamSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelectionView()
            .environmentObject(AppState())
    }
}

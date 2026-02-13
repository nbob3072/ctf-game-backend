import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#0F2027") ?? .black, Color(hex: "#203A43") ?? .gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Team Badge (if selected)
                if let team = appState.selectedTeam {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(team.colorValue.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            Text(team.emoji)
                                .font(.system(size: 40))
                        }
                        
                        Text("Joining \(team.name)")
                            .font(.title3.bold())
                            .foregroundColor(team.colorValue)
                    }
                    .padding(.top, 20)
                }
                
                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // Form
                VStack(spacing: 15) {
                    // Username
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .textContentType(.username)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Username validation feedback
                    if !username.isEmpty {
                        let validation = UsernameValidator.validate(username)
                        HStack {
                            Image(systemName: validation.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(validation.isValid ? .green : .red)
                                .font(.caption)
                            
                            Text(validation.isValid ? "Username available" : (validation.errorMessage ?? "Invalid username"))
                                .font(.caption)
                                .foregroundColor(validation.isValid ? .green : .red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 5)
                    }
                    
                    // Email
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Password
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Confirm Password
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Password validation hints
                    VStack(alignment: .leading, spacing: 4) {
                        // Length requirement
                        if !password.isEmpty {
                            HStack {
                                Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password.count >= 8 ? .green : .red)
                                    .font(.caption)
                                
                                Text("At least 8 characters")
                                    .font(.caption)
                                    .foregroundColor(password.count >= 8 ? .green : .red)
                                
                                Spacer()
                            }
                        }
                        
                        // Password match indicator
                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                    .font(.caption)
                                
                                Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                                    .font(.caption)
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.horizontal, 30)
                
                // Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Register Button
                Button(action: register) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    appState.selectedTeam?.colorValue ?? Color(hex: "#E74C3C")!
                )
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .disabled(authViewModel.isLoading || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        let usernameValid = UsernameValidator.validate(username).isValid
        
        return usernameValid &&
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    private func register() {
        Task {
            do {
                try await authViewModel.register(
                    username: username,
                    email: email,
                    password: password,
                    teamId: appState.selectedTeam?.id
                )
            } catch {
                showingError = true
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AppState())
            .environmentObject(AuthViewModel())
    }
}

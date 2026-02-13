import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingError = false
    @State private var showBiometricEnrollment = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#0F2027") ?? .black, Color(hex: "#203A43") ?? .gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                VStack(spacing: 10) {
                    Text("🚩")
                        .font(.system(size: 70))
                    
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Log in to continue your conquest")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)
                
                // Form
                VStack(spacing: 15) {
                    // Email field
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
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                
                // Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 30)
                }
                
                // Biometric Login Button (if enabled)
                if authViewModel.canUseBiometric {
                    Button(action: loginWithBiometric) {
                        HStack {
                            Image(systemName: authViewModel.biometricName == "Face ID" ? "faceid" : "touchid")
                                .font(.title2)
                            Text("Log in with \(authViewModel.biometricName)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#3498DB"))
                    .cornerRadius(16)
                    .padding(.horizontal, 30)
                    .disabled(authViewModel.isLoading)
                    
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                // Password Login Button
                Button(action: login) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "#E74C3C"))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                .disabled(authViewModel.isLoading || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                
                // Register link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    Button("Sign Up") {
                        showingRegister = true
                    }
                    .foregroundColor(Color(hex: "#3498DB"))
                }
                .font(.subheadline)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingRegister) {
            TeamSelectionView()
                .environmentObject(appState)
        }
        .alert("Enable \(authViewModel.biometricName)?", isPresented: $showBiometricEnrollment) {
            Button("Enable") {
                authViewModel.enableBiometricLogin()
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("Log in quickly and securely using \(authViewModel.biometricName) instead of your password.")
        }
        .onAppear {
            // Auto-attempt biometric login if available and enabled
            if authViewModel.canUseBiometric {
                Task {
                    try? await authViewModel.loginWithBiometric()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func login() {
        Task {
            do {
                try await authViewModel.login(email: email, password: password)
                
                // Offer biometric enrollment after successful login
                if authViewModel.shouldOfferBiometricEnrollment {
                    showBiometricEnrollment = true
                }
            } catch {
                showingError = true
            }
        }
    }
    
    private func loginWithBiometric() {
        Task {
            do {
                try await authViewModel.loginWithBiometric()
            } catch {
                // If biometric fails, show error
                showingError = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
            .environmentObject(AuthViewModel())
    }
}

//
//  LoginView.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var usernameOrEmail = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo/Header
                        VStack(spacing: 10) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                            
                            Text("Welcome to Free Find")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Discover and donate items while saving the environment")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 50)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username or Email")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter username or email", text: $usernameOrEmail)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Login Button
                            Button(action: {
                                loginUser()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                        Text("Log In")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(usernameOrEmail.isEmpty || password.isEmpty || isLoading)
                            
                            // Demo accounts info
                            VStack(spacing: 8) {
                                Text("Demo Accounts:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 4) {
                                    Text("Username: demo | Password: demo123")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Username: testuser | Password: test123")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                            // Quick Login Buttons
                            HStack(spacing: 10) {
                                Button("Demo User") {
                                    usernameOrEmail = "demo"
                                    password = "demo123"
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                                
                                Button("Test User") {
                                    usernameOrEmail = "testuser"
                                    password = "test123"
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Sign Up Link
                        VStack(spacing: 10) {
                            Text("Don't have an account?")
                                .foregroundColor(.secondary)
                            
                            Button("Create Account") {
                                showingSignUp = true
                            }
                            .font(.headline)
                            .foregroundColor(.green)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView(authManager: authManager)
        }
        .alert("Login Failed", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            createDemoAccountsIfNeeded()
        }
    }
    
    private func loginUser() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = authManager.login(usernameOrEmail: usernameOrEmail, password: password)
            
            switch result {
            case .success(_):
                // Login successful - the authManager will handle the state change
                break
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
            isLoading = false
        }
    }
    
    private func createDemoAccountsIfNeeded() {
        // Create demo accounts if they don't exist
        let _ = authManager.createAccount(
            username: "demo",
            email: "demo@example.com",
            fullName: "Demo User",
            password: "demo123",
            location: "San Francisco, CA",
            bio: "I love finding and donating items to help the environment!"
        )
        
        let _ = authManager.createAccount(
            username: "testuser",
            email: "test@example.com",
            fullName: "Test User",
            password: "test123",
            location: "New York, NY",
            bio: "Environmental enthusiast and sustainability advocate."
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}

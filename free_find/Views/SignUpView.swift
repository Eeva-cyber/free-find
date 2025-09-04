//
//  SignUpView.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Join our community of eco-conscious donors")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Sign Up Form
                        VStack(spacing: 20) {
                            // Required Fields
                            VStack(alignment: .leading, spacing: 15) {
                                FormField(title: "Full Name", text: $fullName, placeholder: "Enter your full name")
                                
                                FormField(title: "Username", text: $username, placeholder: "Choose a username")
                                
                                FormField(title: "Email", text: $email, placeholder: "Enter your email address")
                                
                                FormField(title: "Password", text: $password, placeholder: "Create a password", isSecure: true)
                                
                                FormField(title: "Confirm Password", text: $confirmPassword, placeholder: "Confirm your password", isSecure: true)
                            }
                            
                            // Optional Fields
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Optional Information")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                                
                                FormField(title: "Location", text: $location, placeholder: "City, State (optional)")
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bio")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Tell us about yourself (optional)", text: $bio, axis: .vertical)
                                        .lineLimit(3...6)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            // Create Account Button
                            Button(action: {
                                createAccount()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                        Text("Create Account")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(!isFormValid || isLoading)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Account Creation", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successful") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !fullName.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@")
    }
    
    private func createAccount() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = authManager.createAccount(
                username: username,
                email: email,
                fullName: fullName,
                password: password,
                location: location.isEmpty ? nil : location,
                bio: bio.isEmpty ? nil : bio
            )
            
            switch result {
            case .success(_):
                alertMessage = "Account created successfully! You are now logged in."
                showingAlert = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
            isLoading = false
        }
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
            }
        }
    }
}

#Preview {
    SignUpView(authManager: AuthenticationManager())
}

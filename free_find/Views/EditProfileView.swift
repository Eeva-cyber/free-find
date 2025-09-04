//
//  EditProfileView.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Location", text: $location)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Profile Updated", isPresented: $showingAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = authManager.currentUser else { return }
        fullName = user.fullName
        email = user.email
        location = user.location ?? ""
        bio = user.bio ?? ""
    }
    
    private func saveProfile() {
        authManager.updateProfile(
            fullName: fullName,
            email: email,
            location: location.isEmpty ? nil : location,
            bio: bio.isEmpty ? nil : bio
        )
        
        alertMessage = "Your profile has been updated successfully!"
        showingAlert = true
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationManager())
}

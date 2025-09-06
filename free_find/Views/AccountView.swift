//
//  AccountView.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Stats Cards
                    StatsCardsView()
                    
                    // Profile Actions
                    ProfileActionsView(showingEditProfile: $showingEditProfile)
                    
                    // Account Settings
                    AccountSettingsView()
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Account")
            .background(Color.gray.opacity(0.1))
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(String(authManager.currentUser?.fullName.prefix(1) ?? "U"))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 5) {
                Text(authManager.currentUser?.fullName ?? "Unknown User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("@\(authManager.currentUser?.username ?? "unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let location = authManager.currentUser?.location {
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Home Address
                if let homeAddress = authManager.currentUser?.homeAddress {
                    HStack {
                        Image(systemName: "house")
                            .foregroundColor(.secondary)
                        Text(homeAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Suburb
                if let suburb = authManager.currentUser?.suburb {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.secondary)
                        Text(suburb)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let bio = authManager.currentUser?.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct StatsCardsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Your Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Donations",
                    value: "\(donationStore.myDonations.count)",
                    icon: "gift.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "CO₂ Saved",
                    value: String(format: "%.1f kg", donationStore.totalCO2Saved),
                    icon: "leaf.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Items Found",
                    value: "\(donationStore.donations.count - donationStore.myDonations.count)",
                    icon: "eye.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Member Since",
                    value: memberSinceText,
                    icon: "calendar.badge.clock",
                    color: .purple
                )
            }
        }
    }
    
    private var memberSinceText: String {
        guard let joinDate = authManager.currentUser?.joinDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: joinDate)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct ProfileActionsView: View {
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Profile")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "person.circle",
                    title: "Edit Profile",
                    action: { showingEditProfile = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ActionRow(
                    icon: "heart.circle",
                    title: "My Donations",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ActionRow(
                    icon: "bookmark.circle",
                    title: "Saved Items",
                    action: { }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

struct AccountSettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Settings")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "bell.circle",
                    title: "Notifications",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ActionRow(
                    icon: "shield.circle",
                    title: "Privacy",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ActionRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                ActionRow(
                    icon: "arrow.right.square",
                    title: "Logout",
                    titleColor: .red,
                    action: { showingLogoutAlert = true }
                )
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    var titleColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(titleColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthenticationManager())
        .environmentObject(DonationStore())
}

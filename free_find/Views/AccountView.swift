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
    @StateObject private var loyaltySystem = LoyaltySystem()
    @State private var showingEditProfile = false
    @State private var showingLoyaltyView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Loyalty Tier Card
                    LoyaltyTierCard()
                    
                    // Stats Cards
                    StatsCardsView()
                    
                    // Profile Actions
                    ProfileActionsView(showingEditProfile: $showingEditProfile, showingLoyaltyView: $showingLoyaltyView)
                    
                    // Account Settings
                    AccountSettingsView()
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Account")
            .background(Color.gray.opacity(0.1))
            .environmentObject(loyaltySystem)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingLoyaltyView) {
                LoyaltyView()
                    .environmentObject(authManager)
                    .environmentObject(donationStore)
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

struct LoyaltyTierCard: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    @EnvironmentObject var loyaltySystem: LoyaltySystem
    
    private var currentTier: LoyaltyTier {
        loyaltySystem.calculateTier(for: donationStore.myDonations.count)
    }
    
    private var tierColor: Color {
        switch currentTier.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        default: return .gray
        }
    }
    
    private var progressInfo: (nextTier: LoyaltyTier?, donationsNeeded: Int, progress: Double) {
        loyaltySystem.getProgressToNextTier(currentDonations: donationStore.myDonations.count)
    }
    
    private var availableRewardsCount: Int {
        guard let user = authManager.currentUser else { return 0 }
        return loyaltySystem.getAvailableRewards(for: user).count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Loyalty Status")
                    .font(.headline)
                
                Spacer()
                
                if availableRewardsCount > 0 {
                    Text("\(availableRewardsCount) rewards")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            VStack(spacing: 15) {
                // Current Tier Info
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [tierColor.opacity(0.3), tierColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: currentTier.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(currentTier.rawValue)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(tierColor)
                        
                        if let user = authManager.currentUser {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(user.loyaltyPoints) points")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        Text("\(donationStore.myDonations.count) donations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Progress to Next Tier
                if let nextTier = progressInfo.nextTier {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Next: \(nextTier.rawValue)")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(progressInfo.donationsNeeded) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(tierColor)
                                    .frame(width: geometry.size.width * progressInfo.progress, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
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
    @Binding var showingLoyaltyView: Bool
    
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
                    icon: "star.circle",
                    title: "Loyalty Rewards",
                    action: { showingLoyaltyView = true }
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
                
                // Development testing button - remove in production
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    Divider()
                        .padding(.leading, 50)
                    
                    ActionRow(
                        icon: "hammer.circle",
                        title: "Add Test Donations (Dev)",
                        action: { 
                            // This will only work in development builds
                        }
                    )
                }
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

//
//  LoyaltyView.swift
//  free_find
//
//  Created by jack ren on 9/6/25.
//

import SwiftUI

struct LoyaltyView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    @StateObject private var loyaltySystem = LoyaltySystem()
    @State private var showingRewardDetail = false
    @State private var selectedReward: LoyaltyReward?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Tier Section
                    CurrentTierCard()
                    
                    // Progress to Next Tier
                    ProgressToNextTierCard()
                    
                    // Available Rewards
                    AvailableRewardsSection()
                    
                    // Claimed Rewards
                    ClaimedRewardsSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Loyalty Rewards")
            .background(Color.gray.opacity(0.1))
            .environmentObject(loyaltySystem)
            .sheet(item: $selectedReward) { reward in
                RewardDetailView(reward: reward)
                    .environmentObject(authManager)
                    .environmentObject(loyaltySystem)
            }
        }
    }
}

struct CurrentTierCard: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    
    private var currentTier: LoyaltyTier {
        guard let user = authManager.currentUser else { return .newbie }
        return LoyaltySystem().calculateTier(for: donationStore.myDonations.count)
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
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Current Tier")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Tier Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [tierColor.opacity(0.3), tierColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: currentTier.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(currentTier.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(tierColor)
                    
                    Text(currentTier.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(tierColor)
                        Text("\(donationStore.myDonations.count) donations")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    if let user = authManager.currentUser {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(user.loyaltyPoints) points")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 2)
        }
    }
}

struct ProgressToNextTierCard: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var donationStore: DonationStore
    @EnvironmentObject var loyaltySystem: LoyaltySystem
    
    private var progressInfo: (nextTier: LoyaltyTier?, donationsNeeded: Int, progress: Double) {
        loyaltySystem.getProgressToNextTier(currentDonations: donationStore.myDonations.count)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Progress to Next Tier")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let nextTier = progressInfo.nextTier {
                VStack(spacing: 10) {
                    HStack {
                        Text("Next: \(nextTier.rawValue)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(progressInfo.donationsNeeded) more donations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * progressInfo.progress, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("\(donationStore.myDonations.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(nextTier.donationsRequired)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.purple)
                    
                    Text("Max Tier Reached!")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("You've reached the highest tier. You're a true legend!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
            }
        }
    }
}

struct AvailableRewardsSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var loyaltySystem: LoyaltySystem
    @Binding var selectedReward: LoyaltyReward?
    
    init() {
        self._selectedReward = .constant(nil)
    }
    
    var availableRewards: [LoyaltyReward] {
        guard let user = authManager.currentUser else { return [] }
        return loyaltySystem.getAvailableRewards(for: user)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Available Rewards")
                    .font(.headline)
                
                Spacer()
                
                if !availableRewards.isEmpty {
                    Text("\(availableRewards.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            if availableRewards.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "gift.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No rewards available yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Keep donating to unlock rewards!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(availableRewards) { reward in
                        RewardCard(reward: reward, isAvailable: true) {
                            selectedReward = reward
                        }
                    }
                }
            }
        }
    }
}

struct ClaimedRewardsSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var loyaltySystem: LoyaltySystem
    
    var claimedRewards: [LoyaltyReward] {
        guard let user = authManager.currentUser else { return [] }
        return loyaltySystem.getClaimedRewards(for: user)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Claimed Rewards")
                    .font(.headline)
                
                Spacer()
                
                if !claimedRewards.isEmpty {
                    Text("\(claimedRewards.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            if claimedRewards.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "gift")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No rewards claimed yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(claimedRewards) { reward in
                        RewardCard(reward: reward, isAvailable: false) { }
                    }
                }
            }
        }
    }
}

struct RewardCard: View {
    let reward: LoyaltyReward
    let isAvailable: Bool
    let onTap: () -> Void
    
    private var rewardColor: Color {
        switch reward.tier.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Reward Icon
                ZStack {
                    Circle()
                        .fill(rewardColor.opacity(isAvailable ? 1.0 : 0.3))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: reward.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(reward.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isAvailable ? .primary : .secondary)
                        
                        if reward.isSpecial {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(reward.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Label("\(reward.pointsRequired)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Label("\(reward.donationsRequired)", systemImage: "gift.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if isAvailable {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .opacity(isAvailable ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
    }
}

struct RewardDetailView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var loyaltySystem: LoyaltySystem
    @Environment(\.dismiss) private var dismiss
    @State private var showingClaimAlert = false
    @State private var claimSuccess = false
    
    let reward: LoyaltyReward
    
    private var canClaim: Bool {
        guard let user = authManager.currentUser else { return false }
        return user.totalDonations >= reward.donationsRequired &&
               user.loyaltyPoints >= reward.pointsRequired &&
               !user.claimedRewards.contains(reward.id)
    }
    
    private var rewardColor: Color {
        switch reward.tier.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Reward Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [rewardColor.opacity(0.3), rewardColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: reward.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        if reward.isSpecial {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "sparkles")
                                        .font(.title3)
                                        .foregroundColor(.yellow)
                                }
                                Spacer()
                            }
                            .frame(width: 120, height: 120)
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text(reward.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(reward.tier.rawValue + " Tier")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(rewardColor.opacity(0.2))
                            .foregroundColor(rewardColor)
                            .cornerRadius(8)
                    }
                    
                    Text(reward.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Requirements
                    VStack(spacing: 15) {
                        Text("Requirements")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            VStack {
                                Image(systemName: "gift.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("\(reward.donationsRequired)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Donations")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                Text("\(reward.pointsRequired)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Points")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if canClaim {
                        Button(action: { showingClaimAlert = true }) {
                            Text("Claim Reward")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(rewardColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else if let user = authManager.currentUser, user.claimedRewards.contains(reward.id) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Reward Claimed")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 10) {
                            Text("Requirements not met")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if let user = authManager.currentUser {
                                if user.totalDonations < reward.donationsRequired {
                                    Text("Need \(reward.donationsRequired - user.totalDonations) more donations")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                                if user.loyaltyPoints < reward.pointsRequired {
                                    Text("Need \(reward.pointsRequired - user.loyaltyPoints) more points")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Reward Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .alert("Claim Reward", isPresented: $showingClaimAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Claim") {
                    claimReward()
                }
            } message: {
                Text("Are you sure you want to claim this reward for \(reward.pointsRequired) points?")
            }
            .alert("Reward Claimed!", isPresented: $claimSuccess) {
                Button("Great!") {
                    dismiss()
                }
            } message: {
                Text("You've successfully claimed the \(reward.title) reward!")
            }
        }
    }
    
    private func claimReward() {
        guard var user = authManager.currentUser else { return }
        
        if loyaltySystem.claimReward(reward, for: &user) {
            authManager.currentUser = user
            claimSuccess = true
        }
    }
}

#Preview {
    LoyaltyView()
        .environmentObject(AuthenticationManager())
        .environmentObject(DonationStore())
}

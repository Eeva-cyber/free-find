//
//  UserAccount.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import Foundation

// MARK: - Loyalty System Models
enum LoyaltyTier: String, Codable, CaseIterable {
    case newbie = "Newbie"
    case helper = "Helper"
    case guardian = "Guardian"
    case champion = "Champion"
    case legend = "Legend"
    
    var donationsRequired: Int {
        switch self {
        case .newbie: return 0
        case .helper: return 5
        case .guardian: return 15
        case .champion: return 30
        case .legend: return 50
        }
    }
    
    var color: String {
        switch self {
        case .newbie: return "gray"
        case .helper: return "blue"
        case .guardian: return "green"
        case .champion: return "orange"
        case .legend: return "purple"
        }
    }
    
    var icon: String {
        switch self {
        case .newbie: return "leaf"
        case .helper: return "heart"
        case .guardian: return "shield"
        case .champion: return "star"
        case .legend: return "crown"
        }
    }
    
    var description: String {
        switch self {
        case .newbie: return "Welcome to the community!"
        case .helper: return "You're making a difference!"
        case .guardian: return "Protecting our environment!"
        case .champion: return "Leading by example!"
        case .legend: return "An inspiration to all!"
        }
    }
}

struct LoyaltyReward: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let donationsRequired: Int
    let pointsRequired: Int
    let tier: LoyaltyTier
    let icon: String
    let rewardType: RewardType
    let isSpecial: Bool
    
    enum RewardType: String, Codable {
        case badge = "badge"
        case title = "title"
        case feature = "feature"
        case discount = "discount"
    }
}

struct UserAccount: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var fullName: String
    var profileImageName: String?
    var joinDate: Date
    var totalDonations: Int
    var totalCO2Saved: Double
    var location: String?
    var bio: String?
    var homeAddress: String?
    var suburb: String?
    
    // Loyalty System Properties
    var loyaltyPoints: Int
    var currentTier: LoyaltyTier
    var claimedRewards: [String] // Array of claimed reward IDs
    
    init(username: String, email: String, fullName: String, location: String? = nil, bio: String? = nil, homeAddress: String? = nil, suburb: String? = nil) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.fullName = fullName
        self.profileImageName = nil
        self.joinDate = Date()
        self.totalDonations = 0
        self.totalCO2Saved = 0.0
        self.location = location
        self.bio = bio
        self.homeAddress = homeAddress
        self.suburb = suburb
        
        // Initialize loyalty system properties
        self.loyaltyPoints = 0
        self.currentTier = .newbie
        self.claimedRewards = []
    }
}

// MARK: - Authentication Manager
class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: UserAccount?
    
    private let userDefaultsKey = "SavedUserAccounts"
    private let currentUserKey = "CurrentLoggedInUser"
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Account Management
    func createAccount(username: String, email: String, fullName: String, password: String, location: String? = nil, bio: String? = nil) -> Result<UserAccount, AuthError> {
        // Check if username or email already exists
        if isUsernameTaken(username) {
            return .failure(.usernameTaken)
        }
        
        if isEmailTaken(email) {
            return .failure(.emailTaken)
        }
        
        // Create new account
        let newUser = UserAccount(username: username, email: email, fullName: fullName, location: location, bio: bio)
        
        // Save account
        saveAccount(newUser, password: password)
        
        // Log in the new user
        currentUser = newUser
        isLoggedIn = true
        saveCurrentUser()
        
        return .success(newUser)
    }
    
    func login(usernameOrEmail: String, password: String) -> Result<UserAccount, AuthError> {
        guard let accounts = loadSavedAccounts() else {
            return .failure(.invalidCredentials)
        }
        
        // Find user by username or email
        guard let accountData = accounts.first(where: { 
            $0.username.lowercased() == usernameOrEmail.lowercased() || 
            $0.email.lowercased() == usernameOrEmail.lowercased() 
        }) else {
            return .failure(.invalidCredentials)
        }
        
        // Verify password (in real app, this would be hashed)
        let storedPassword = UserDefaults.standard.string(forKey: "password_\(accountData.username)") ?? ""
        guard storedPassword == password else {
            return .failure(.invalidCredentials)
        }
        
        // Log in user
        currentUser = accountData
        isLoggedIn = true
        saveCurrentUser()
        
        return .success(accountData)
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func updateProfile(fullName: String, email: String, location: String?, bio: String?, homeAddress: String?, suburb: String?) {
        guard var user = currentUser else { return }
        
        user.fullName = fullName
        user.email = email
        user.location = location
        user.bio = bio
        user.homeAddress = homeAddress
        user.suburb = suburb
        
        currentUser = user
        saveCurrentUser()
        updateSavedAccount(user)
    }
    
    // MARK: - Statistics Update
    func updateUserStats(donationsCount: Int, co2Saved: Double) {
        guard var user = currentUser else { return }
        
        user.totalDonations = donationsCount
        user.totalCO2Saved = co2Saved
        
        // Update loyalty system
        user.loyaltyPoints = LoyaltySystem().calculatePoints(for: donationsCount)
        user.currentTier = LoyaltySystem().calculateTier(for: donationsCount)
        
        currentUser = user
        saveCurrentUser()
        updateSavedAccount(user)
    }
    
    // MARK: - Private Methods
    private func isUsernameTaken(_ username: String) -> Bool {
        guard let accounts = loadSavedAccounts() else { return false }
        return accounts.contains { $0.username.lowercased() == username.lowercased() }
    }
    
    private func isEmailTaken(_ email: String) -> Bool {
        guard let accounts = loadSavedAccounts() else { return false }
        return accounts.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    private func saveAccount(_ account: UserAccount, password: String) {
        var accounts = loadSavedAccounts() ?? []
        accounts.append(account)
        
        // Save accounts
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        
        // Save password separately (in real app, this would be securely hashed)
        UserDefaults.standard.set(password, forKey: "password_\(account.username)")
    }
    
    private func updateSavedAccount(_ account: UserAccount) {
        var accounts = loadSavedAccounts() ?? []
        if let index = accounts.firstIndex(where: { $0.username == account.username }) {
            accounts[index] = account
            
            if let encoded = try? JSONEncoder().encode(accounts) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
        }
    }
    
    private func loadSavedAccounts() -> [UserAccount]? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let accounts = try? JSONDecoder().decode([UserAccount].self, from: data) else {
            return nil
        }
        return accounts
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser,
              let encoded = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(encoded, forKey: currentUserKey)
    }
    
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(UserAccount.self, from: data) else {
            return
        }
        currentUser = user
        isLoggedIn = true
    }
    
    // MARK: - Development Helper
    func addSampleDonationsForTesting() {
        // This is for testing the loyalty system
        guard var user = currentUser else { return }
        
        // Simulate having made some donations for testing
        let sampleDonationsCount = 12 // This should put user at "Guardian" tier
        user.totalDonations = sampleDonationsCount
        user.totalCO2Saved = Double(sampleDonationsCount) * 2.5 // Sample CO2 savings
        
        // Update loyalty system
        user.loyaltyPoints = LoyaltySystem().calculatePoints(for: sampleDonationsCount)
        user.currentTier = LoyaltySystem().calculateTier(for: sampleDonationsCount)
        
        currentUser = user
        saveCurrentUser()
        updateSavedAccount(user)
    }
}

// MARK: - Authentication Errors
enum AuthError: LocalizedError {
    case usernameTaken
    case emailTaken
    case invalidCredentials
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "Username is already taken"
        case .emailTaken:
            return "Email is already registered"
        case .invalidCredentials:
            return "Invalid username/email or password"
        case .networkError:
            return "Network connection failed"
        }
    }
}

// MARK: - Loyalty System Manager
class LoyaltySystem: ObservableObject {
    @Published var availableRewards: [LoyaltyReward] = []
    
    init() {
        setupRewards()
    }
    
    private func setupRewards() {
        availableRewards = [
            // Helper Tier Rewards (5 donations)
            LoyaltyReward(
                id: "helper_badge",
                title: "Helper Badge",
                description: "Your first milestone! Thanks for helping the community.",
                donationsRequired: 5,
                pointsRequired: 50,
                tier: .helper,
                icon: "heart.fill",
                rewardType: .badge,
                isSpecial: false
            ),
            LoyaltyReward(
                id: "early_access",
                title: "Early Access Features",
                description: "Get early access to new app features and updates.",
                donationsRequired: 5,
                pointsRequired: 50,
                tier: .helper,
                icon: "star.circle.fill",
                rewardType: .feature,
                isSpecial: true
            ),
            
            // Guardian Tier Rewards (15 donations)
            LoyaltyReward(
                id: "guardian_badge",
                title: "Guardian Badge",
                description: "You're a true guardian of sustainability!",
                donationsRequired: 15,
                pointsRequired: 150,
                tier: .guardian,
                icon: "shield.fill",
                rewardType: .badge,
                isSpecial: false
            ),
            LoyaltyReward(
                id: "priority_notifications",
                title: "Priority Notifications",
                description: "Get notified first about new items in your area.",
                donationsRequired: 15,
                pointsRequired: 150,
                tier: .guardian,
                icon: "bell.badge.fill",
                rewardType: .feature,
                isSpecial: true
            ),
            
            // Champion Tier Rewards (30 donations)
            LoyaltyReward(
                id: "champion_badge",
                title: "Champion Badge",
                description: "You're a champion of the environment!",
                donationsRequired: 30,
                pointsRequired: 300,
                tier: .champion,
                icon: "star.fill",
                rewardType: .badge,
                isSpecial: false
            ),
            LoyaltyReward(
                id: "custom_profile",
                title: "Custom Profile Theme",
                description: "Unlock special profile themes and customizations.",
                donationsRequired: 30,
                pointsRequired: 300,
                tier: .champion,
                icon: "paintbrush.fill",
                rewardType: .feature,
                isSpecial: true
            ),
            
            // Legend Tier Rewards (50 donations)
            LoyaltyReward(
                id: "legend_badge",
                title: "Legend Badge",
                description: "You're a legend! An inspiration to everyone.",
                donationsRequired: 50,
                pointsRequired: 500,
                tier: .legend,
                icon: "crown.fill",
                rewardType: .badge,
                isSpecial: false
            ),
            LoyaltyReward(
                id: "legend_title",
                title: "Legend Title",
                description: "Display 'Legend' title on your profile.",
                donationsRequired: 50,
                pointsRequired: 500,
                tier: .legend,
                icon: "crown.fill",
                rewardType: .title,
                isSpecial: true
            ),
            LoyaltyReward(
                id: "moderator_features",
                title: "Community Moderator",
                description: "Help moderate the community and review donations.",
                donationsRequired: 50,
                pointsRequired: 500,
                tier: .legend,
                icon: "person.badge.shield.checkmark.fill",
                rewardType: .feature,
                isSpecial: true
            )
        ]
    }
    
    func calculateTier(for donationCount: Int) -> LoyaltyTier {
        let sortedTiers = LoyaltyTier.allCases.sorted { $0.donationsRequired > $1.donationsRequired }
        return sortedTiers.first { donationCount >= $0.donationsRequired } ?? .newbie
    }
    
    func calculatePoints(for donationCount: Int) -> Int {
        return donationCount * 10 // 10 points per donation
    }
    
    func getProgressToNextTier(currentDonations: Int) -> (nextTier: LoyaltyTier?, donationsNeeded: Int, progress: Double) {
        let currentTier = calculateTier(for: currentDonations)
        let allTiers = LoyaltyTier.allCases.sorted { $0.donationsRequired < $1.donationsRequired }
        
        guard let currentIndex = allTiers.firstIndex(of: currentTier),
              currentIndex < allTiers.count - 1 else {
            return (nil, 0, 1.0) // Already at max tier
        }
        
        let nextTier = allTiers[currentIndex + 1]
        let donationsNeeded = nextTier.donationsRequired - currentDonations
        let progress = Double(currentDonations) / Double(nextTier.donationsRequired)
        
        return (nextTier, donationsNeeded, progress)
    }
    
    func getAvailableRewards(for user: UserAccount) -> [LoyaltyReward] {
        return availableRewards.filter { reward in
            user.totalDonations >= reward.donationsRequired &&
            user.loyaltyPoints >= reward.pointsRequired &&
            !user.claimedRewards.contains(reward.id)
        }
    }
    
    func getClaimedRewards(for user: UserAccount) -> [LoyaltyReward] {
        return availableRewards.filter { reward in
            user.claimedRewards.contains(reward.id)
        }
    }
    
    func claimReward(_ reward: LoyaltyReward, for user: inout UserAccount) -> Bool {
        guard user.totalDonations >= reward.donationsRequired,
              user.loyaltyPoints >= reward.pointsRequired,
              !user.claimedRewards.contains(reward.id) else {
            return false
        }
        
        user.claimedRewards.append(reward.id)
        user.loyaltyPoints -= reward.pointsRequired
        return true
    }
}

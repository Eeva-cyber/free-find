//
//  UserAccount.swift
//  free_find
//
//  Created by jack ren on 9/4/25.
//

import Foundation

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

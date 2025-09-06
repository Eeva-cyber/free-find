//
//  DonationStore.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import Foundation

class DonationStore: ObservableObject {
    @Published var donations: [DonationItem] = []
    
    // Reference to auth manager for updating user stats
    weak var authManager: AuthenticationManager?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var donationsFile: URL {
        documentsPath.appendingPathComponent("donations.json")
    }
    
    init() {
        loadDonations()
    }
    
    func setAuthManager(_ authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func addDonation(_ donation: DonationItem) {
        donations.append(donation)
        saveDonations()
        updateUserStats()
    }
    
    func updateDonation(_ donation: DonationItem) {
        if let index = donations.firstIndex(where: { $0.id == donation.id }) {
            donations[index] = donation
            saveDonations()
            updateUserStats()
        }
    }
    
    func deleteDonation(_ donation: DonationItem) {
        donations.removeAll { $0.id == donation.id }
        saveDonations()
        updateUserStats()
    }
    
    private func updateUserStats() {
        // Update user stats in AuthenticationManager
        authManager?.updateUserStats(donationsCount: myDonations.count, co2Saved: totalCO2Saved)
    }
    
    private func saveDonations() {
        do {
            let data = try JSONEncoder().encode(donations)
            try data.write(to: donationsFile)
        } catch {
            print("Failed to save donations: \(error)")
        }
    }
    
    private func loadDonations() {
        do {
            let data = try Data(contentsOf: donationsFile)
            donations = try JSONDecoder().decode([DonationItem].self, from: data)
        } catch {
            // File doesn't exist or is corrupted, start with empty array
            donations = []
        }
    }
    
    // Helper to get available donations (for discovery)
    func availableDonations() -> [DonationItem] {
        return donations.filter { $0.status == .available }
    }
    
    // Helper to get user's own donations
    var myDonations: [DonationItem] {
        // For now, we'll consider all donations as user's own donations
        // In a real app, this would filter by the current user's ID
        return donations
    }
    
    // Helper to calculate total CO2 saved
    var totalCO2Saved: Double {
        return donations.reduce(0) { total, donation in
            total + (donation.estimatedCO2Savings ?? 0.0)
        }
    }
}

//
//  MyDonationsView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct MyDonationsView: View {
    @EnvironmentObject var donationStore: DonationStore
    @State private var selectedStatus: DonationStatus? = nil
    
    // Colors matching HomeView design
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let homeBackground = Color(red: 0.98, green: 0.98, blue: 0.96) // #F9F9F5
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12) // #1F1F1F
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91) // #E8F5E9
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    header
                    
                    // Main Content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // My Impact Stats Card
                            MyDonationsStatsCard()
                                .environmentObject(donationStore)
                            
                            // Status Filter Section
                            statusFilterSection
                            
                            // Donations List
                            donationsSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Space for bottom navigation
                    }
                    .background(homeBackground)
                }
            }
            .navigationBarHidden(true)
            .background(homeBackground)
        }
    }
    
    private var header: some View {
        HStack {
            Text("My Donations")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(darkText)
            
            Spacer()
            
            Button(action: {
                // Handle add donation
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(darkText)
                    .frame(width: 40, height: 40)
                    .background(Color.clear)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(homeBackground)
    }
    
    private var statusFilterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Filter by Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkText)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    StatusFilterButton(
                        title: "All",
                        count: donationStore.donations.count,
                        isSelected: selectedStatus == nil,
                        action: { selectedStatus = nil }
                    )
                    
                    StatusFilterButton(
                        title: "Available",
                        count: donationStore.donations.filter { $0.status == .available }.count,
                        isSelected: selectedStatus == .available,
                        action: { selectedStatus = .available }
                    )
                    
                    StatusFilterButton(
                        title: "Claimed",
                        count: donationStore.donations.filter { $0.status == .claimed }.count,
                        isSelected: selectedStatus == .claimed,
                        action: { selectedStatus = .claimed }
                    )
                    
                    StatusFilterButton(
                        title: "Picked Up",
                        count: donationStore.donations.filter { $0.status == .pickedUp }.count,
                        isSelected: selectedStatus == .pickedUp,
                        action: { selectedStatus = .pickedUp }
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var donationsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Items")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkText)
                
                Spacer()
                
                Text("\(filteredDonations.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if filteredDonations.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDonations) { donation in
                        MyDonationItemCard(donation: donation)
                            .environmentObject(donationStore)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 50))
                .foregroundColor(primaryGreen.opacity(0.6))
            
            Text("No donations yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(darkText)
            
            Text("Start sharing items with your community!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Navigate to donate view
            }) {
                Text("Donate Your First Item")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(primaryGreen)
                    .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var filteredDonations: [DonationItem] {
        if let selectedStatus = selectedStatus {
            return donationStore.donations.filter { $0.status == selectedStatus }
        } else {
            return donationStore.donations
        }
    }
    
    private func deleteDonations(at offsets: IndexSet) {
        for offset in offsets {
            let donation = filteredDonations[offset]
            donationStore.deleteDonation(donation)
        }
    }
}

// MARK: - My Donations Stats Card
struct MyDonationsStatsCard: View {
    @EnvironmentObject var donationStore: DonationStore
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91)
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    private var totalDonations: Int {
        donationStore.donations.count
    }
    
    private var totalCO2Saved: Double {
        donationStore.donations.compactMap { $0.estimatedCO2Savings }.reduce(0, +)
    }
    
    private var availableItems: Int {
        donationStore.donations.filter { $0.status == .available }.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Impact")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(darkText)
                    
                    Text("Your contribution to the community")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "heart.circle.fill")
                    .font(.title2)
                    .foregroundColor(primaryGreen)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalDonations)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryGreen)
                    
                    Text("Total Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(CO2EstimationService.formatCO2Savings(totalCO2Saved))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryGreen)
                    
                    Text("CO2 Saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(availableItems)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryGreen)
                    
                    Text("Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(lightGreenBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(primaryGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Status Filter Button
struct StatusFilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .white : primaryGreen)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? primaryGreen : Color.white)
            .foregroundColor(isSelected ? .white : Color.primary)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - My Donation Item Card
struct MyDonationItemCard: View {
    let donation: DonationItem
    @EnvironmentObject var donationStore: DonationStore
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91)
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(donation.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(darkText)
                        .lineLimit(1)
                    
                    Text(donation.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Display photos
                if !donation.photos.isEmpty {
                    TappablePhotoDisplay(photoFilenames: donation.photos, maxDisplayCount: 1)
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    StatusBadge(status: donation.status)
                    
                    // Action buttons based on status
                    if donation.status == .available {
                        Menu {
                            Button("Mark as Claimed") {
                                updateDonationStatus(donation, to: .claimed)
                            }
                            Button("Mark as Picked Up") {
                                updateDonationStatus(donation, to: .pickedUp)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .foregroundColor(primaryGreen)
                        }
                    } else if donation.status == .claimed {
                        Button(action: {
                            updateDonationStatus(donation, to: .pickedUp)
                        }) {
                            Text("Complete")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(primaryGreen)
                                .cornerRadius(15)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Tags row
            HStack(spacing: 8) {
                // Category tag
                Text(donation.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                
                // Condition tag
                Text(donation.condition.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
                
                // CO2 Savings tag
                if let co2Savings = donation.estimatedCO2Savings, co2Savings > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                        Text(CO2EstimationService.formatCO2Savings(co2Savings))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(lightGreenBackground)
                    .foregroundColor(primaryGreen)
                    .cornerRadius(6)
                }
                
                Spacer()
            }
            
            // Location and time info
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(donation.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(timeRemaining(until: donation.pickupTimeEnd))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(timeRemainingColor(until: donation.pickupTimeEnd))
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Available: \(formatDateRange(start: donation.pickupTimeStart, end: donation.pickupTimeEnd))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func updateDonationStatus(_ donation: DonationItem, to status: DonationStatus) {
        var updatedDonation = donation
        updatedDonation.status = status
        donationStore.updateDonation(updatedDonation)
    }
    
    private func timeRemaining(until date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval < 0 {
            return "Expired"
        } else if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m left"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours)h left"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d left"
        }
    }
    
    private func timeRemainingColor(until date: Date) -> Color {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval < 0 {
            return .red
        } else if timeInterval < 3600 { // Less than 1 hour
            return .orange
        } else {
            return .secondary
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if Calendar.current.isDate(start, inSameDayAs: end) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateStyle = .short
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            
            return "\(dayFormatter.string(from: start)) \(timeFormatter.string(from: start))-\(timeFormatter.string(from: end))"
        } else {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

struct MyDonationRowView: View {
    let donation: DonationItem
    @EnvironmentObject var donationStore: DonationStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(donation.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(donation.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(donation.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        
                        Text(donation.condition.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                        
                        // CO2 Savings Badge
                        if let co2Savings = donation.estimatedCO2Savings, co2Savings > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "leaf.fill")
                                    .font(.caption2)
                                Text(CO2EstimationService.formatCO2Savings(co2Savings))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.1))
                            .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                            .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: donation.status)
                    
                    if donation.status == .available {
                        Menu {
                            Button("Mark as Claimed") {
                                updateDonationStatus(donation, to: .claimed)
                            }
                            Button("Mark as Picked Up") {
                                updateDonationStatus(donation, to: .pickedUp)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.blue)
                        }
                    } else if donation.status == .claimed {
                        Button("Mark Picked Up") {
                            updateDonationStatus(donation, to: .pickedUp)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                Text(donation.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(timeRemaining(until: donation.pickupTimeEnd))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func updateDonationStatus(_ donation: DonationItem, to status: DonationStatus) {
        var updatedDonation = donation
        updatedDonation.status = status
        donationStore.updateDonation(updatedDonation)
    }
    
    private func timeRemaining(until date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval < 0 {
            return "Expired"
        } else if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m left"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours)h left"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d left"
        }
    }
}

struct StatusBadge: View {
    let status: DonationStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .available:
            return Color.green.opacity(0.2)
        case .claimed:
            return Color.orange.opacity(0.2)
        case .pickedUp:
            return Color.gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .available:
            return .green
        case .claimed:
            return .orange
        case .pickedUp:
            return .gray
        }
    }
}

struct StatusButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

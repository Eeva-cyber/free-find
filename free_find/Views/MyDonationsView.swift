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
    
    var body: some View {
        NavigationView {
            VStack {
                // Status Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") {
                            selectedStatus = nil
                        }
                        .buttonStyle(StatusButtonStyle(isSelected: selectedStatus == nil))
                        
                        Button("Available") {
                            selectedStatus = .available
                        }
                        .buttonStyle(StatusButtonStyle(isSelected: selectedStatus == .available))
                        
                        Button("Claimed") {
                            selectedStatus = .claimed
                        }
                        .buttonStyle(StatusButtonStyle(isSelected: selectedStatus == .claimed))
                        
                        Button("Picked Up") {
                            selectedStatus = .pickedUp
                        }
                        .buttonStyle(StatusButtonStyle(isSelected: selectedStatus == .pickedUp))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Donations List
                if filteredDonations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No donations yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Start sharing items with your community!")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredDonations) { donation in
                            MyDonationRowView(donation: donation)
                        }
                        .onDelete(perform: deleteDonations)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Donations")
        }
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
                                Text(CO2EstimationHelper.formatCO2Savings(co2Savings))
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
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(6)
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
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    MyDonationsView()
        .environmentObject(DonationStore())
}

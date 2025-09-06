//
//  DiscoverView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var donationStore: DonationStore
    @State private var searchText = ""
    @State private var selectedCategory: ItemCategory? = nil
    
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
                            // Search and Filter Section
                            searchAndFilterSection
                            
                            // Stats Card
                            DiscoverStatsCard()
                                .environmentObject(donationStore)
                            
                            // Items Grid
                            itemsSection
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
            Text("Discover")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(darkText)
            
            Spacer()
            
            Button(action: {
                // Handle search
            }) {
                Image(systemName: "magnifyingglass")
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
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search items...", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterButton(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var itemsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Available Items")
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
                        DiscoverItemCard(donation: donation)
                            .environmentObject(donationStore)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 50))
                .foregroundColor(primaryGreen.opacity(0.6))
            
            Text("No items found")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(darkText)
            
            Text("Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var filteredDonations: [DonationItem] {
        let availableDonations = donationStore.availableDonations()
        
        return availableDonations.filter { donation in
            let matchesSearch = searchText.isEmpty || 
                donation.title.localizedCaseInsensitiveContains(searchText) ||
                donation.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || donation.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
}

// MARK: - Discover Stats Card
struct DiscoverStatsCard: View {
    @EnvironmentObject var donationStore: DonationStore
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91)
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    private var availableItems: Int {
        donationStore.availableDonations().count
    }
    
    private var totalCO2Available: Double {
        donationStore.availableDonations().compactMap { $0.estimatedCO2Savings }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available to Discover")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(darkText)
                    
                    Text("Items ready for pickup")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.title2)
                    .foregroundColor(primaryGreen)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(availableItems)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryGreen)
                    
                    Text("Items Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(CO2EstimationService.formatCO2Savings(totalCO2Available))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryGreen)
                    
                    Text("CO2 Impact")
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

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? primaryGreen : Color.white)
                .foregroundColor(isSelected ? .white : Color.primary)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Discover Item Card
struct DiscoverItemCard: View {
    let donation: DonationItem
    @EnvironmentObject var donationStore: DonationStore
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20)
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91)
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and photos
            HStack(alignment: .top, spacing: 12) {
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
                
                Button(action: {
                    // Handle claim action
                }) {
                    Text("Claim")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(primaryGreen)
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
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

struct DonationRowView: View {
    let donation: DonationItem
    
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
                    Button("Claim") {
                        // Will implement claiming later
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Text(donation.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Available: \(formatDateRange(start: donation.pickupTimeStart, end: donation.pickupTimeEnd))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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

struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(red: 0.95, green: 0.95, blue: 0.95))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

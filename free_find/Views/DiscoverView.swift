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
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search items...", text: $searchText)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button("All") {
                                selectedCategory = nil
                            }
                            .buttonStyle(CategoryButtonStyle(isSelected: selectedCategory == nil))
                            
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                                .buttonStyle(CategoryButtonStyle(isSelected: selectedCategory == category))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                // Items List
                List(filteredDonations) { donation in
                    DonationRowView(donation: donation)
                        .onTapGesture {
                            // Will implement detailed view later
                        }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Discover")
        }
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
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    DiscoverView()
        .environmentObject(DonationStore())
}

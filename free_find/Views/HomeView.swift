//
//  HomeView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var donationStore: DonationStore
    @State private var selectedCategory: ItemCategory?
    
    // Colors matching your HTML design
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let homeBackground = Color(red: 0.98, green: 0.98, blue: 0.96) // #F9F9F5
    private let darkText = Color(red: 0.12, green: 0.12, blue: 0.12) // #1F1F1F
    private let lightGreenBackground = Color(red: 0.91, green: 0.96, blue: 0.91) // #E8F5E9
    
    // Sample category data matching your HTML design
    private let featuredCategories: [CategoryInfo] = [
        CategoryInfo(
            category: .clothing,
            imageName: "clothing_sample",
            icon: "tshirt.fill",
            color: Color(red: 0.18, green: 0.49, blue: 0.20)
        ),
        CategoryInfo(
            category: .furniture,
            imageName: "furniture_sample", 
            icon: "bed.double.fill",
            color: Color(red: 0.18, green: 0.49, blue: 0.20)
        ),
        CategoryInfo(
            category: .electronics,
            imageName: "electronics_sample",
            icon: "tv.fill",
            color: Color(red: 0.18, green: 0.49, blue: 0.20)
        )
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    header
                    
                    // Main Content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // CO2 Impact Summary Card
                            CO2ImpactCard()
                                .environmentObject(donationStore)
                            
                            ForEach(featuredCategories, id: \.category) { categoryInfo in
                                CategoryCard(
                                    categoryInfo: categoryInfo,
                                    onTap: {
                                        selectedCategory = categoryInfo.category
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Space for bottom navigation
                    }
                    .background(Color(red: 0.98, green: 0.98, blue: 0.96))
                }
            }
            .navigationBarHidden(true)
            .background(Color(red: 0.98, green: 0.98, blue: 0.96))
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
                .environmentObject(donationStore)
        }
    }
    
    private var header: some View {
        HStack {
            Text("FreeFind")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12)) // #1F1F1F
            
            Spacer()
            
            Button(action: {
                // Handle notifications
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .frame(width: 40, height: 40)
                    .background(Color.clear)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.98, green: 0.98, blue: 0.96))
    }
}

// MARK: - CO2 Impact Card
struct CO2ImpactCard: View {
    @EnvironmentObject var donationStore: DonationStore
    
    private var totalCO2Saved: Double {
        donationStore.donations.compactMap { $0.estimatedCO2Savings }.reduce(0, +)
    }
    
    private var donationCount: Int {
        donationStore.donations.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Environmental Impact")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                    
                    Text("Total CO2 saved through donations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(CO2EstimationHelper.formatCO2Savings(totalCO2Saved))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                    
                    Text("CO2 Saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(donationCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                    
                    Text("Items Donated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if totalCO2Saved > 0 {
                Text(CO2EstimationHelper.getCO2SavingsMessage(totalCO2Saved))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.91, green: 0.96, blue: 0.91)) // Light green background
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.2), lineWidth: 1)
        )
    }
}

struct CategoryInfo {
    let category: ItemCategory
    let imageName: String
    let icon: String
    let color: Color
}

struct CategoryCard: View {
    let categoryInfo: CategoryInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Image section
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.91, green: 0.96, blue: 0.91), // #E8F5E9
                                    Color(red: 0.85, green: 0.93, blue: 0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 87) // 52% of 168px
                    
                    // Placeholder for image - replace with actual AsyncImage when you have URLs
                    Image(systemName: categoryInfo.icon)
                        .font(.system(size: 40, weight: .regular))
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20).opacity(0.6))
                }
                
                // Content section
                HStack {
                    HStack(spacing: 16) {
                        // Icon background
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.91, green: 0.96, blue: 0.91)) // #E8F5E9
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: iconForCategory(categoryInfo.category))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                        }
                        
                        // Category name
                        Text(categoryInfo.category.rawValue)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .frame(height: 81) // 48% of 168px
            }
        }
        .buttonStyle(CardButtonStyle())
        .frame(height: 168)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func iconForCategory(_ category: ItemCategory) -> String {
        switch category {
        case .clothing:
            return "tshirt"
        case .furniture:
            return "bed.double"
        case .electronics:
            return "tv"
        case .books:
            return "book"
        case .toys:
            return "gamecontroller"
        case .kitchenware:
            return "fork.knife"
        case .sports:
            return "sportscourt"
        case .other:
            return "cube.box"
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Category detail view for when a category is tapped
struct CategoryDetailView: View {
    let category: ItemCategory
    @EnvironmentObject var donationStore: DonationStore
    @Environment(\.dismiss) private var dismiss
    
    private var categoryItems: [DonationItem] {
        donationStore.donations.filter { $0.category == category && $0.status == .available }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if categoryItems.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: iconForCategory(category))
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.gray)
                        
                        Text("No \(category.rawValue.lowercased()) items available")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text("Be the first to donate \(category.rawValue.lowercased()) items to your community!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Items list
                    List(categoryItems) { item in
                        ItemRowView(item: item)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func iconForCategory(_ category: ItemCategory) -> String {
        switch category {
        case .clothing: return "tshirt"
        case .furniture: return "bed.double"
        case .electronics: return "tv"
        case .books: return "book"
        case .toys: return "gamecontroller"
        case .kitchenware: return "fork.knife"
        case .sports: return "sportscourt"
        case .other: return "cube.box"
        }
    }
}

// Simple item row view
struct ItemRowView: View {
    let item: DonationItem
    
    var body: some View {
        HStack {
            // Placeholder image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(item.location)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    // CO2 Savings Display
                    if let co2Savings = item.estimatedCO2Savings, co2Savings > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "leaf.fill")
                                .font(.caption2)
                            Text(CO2EstimationHelper.formatCO2Savings(co2Savings))
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.20))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(item.condition.rawValue)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// Extension to make ItemCategory identifiable for sheet presentation
extension ItemCategory: Identifiable {
    public var id: String { self.rawValue }
}

#Preview {
    HomeView()
        .environmentObject(DonationStore())
}

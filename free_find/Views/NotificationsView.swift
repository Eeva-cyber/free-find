//
//  NotificationsView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct NotificationsView: View {
    @State private var selectedFilter: NotificationFilter = .all
    @State private var notifications: [NotificationItem] = sampleNotifications
    
    // Colors matching your HTML design
    private let backgroundColor = Color(red: 0.976, green: 0.969, blue: 0.961) // #F9F7F5
    private let cardBackground = Color.white
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let textPrimary = Color(red: 0.15, green: 0.23, blue: 0.31) // slate-800
    private let textSecondary = Color(red: 0.374, green: 0.4, blue: 0.424) // gray-600
    private let textLight = Color(red: 0.635, green: 0.643, blue: 0.655) // gray-500
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Filter tabs
            filterTabs
            
            // Main content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredNotifications) { notification in
                        NotificationCard(notification: notification)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100) // Space for tab bar
            }
            .background(backgroundColor)
            
            Spacer()
        }
        .background(backgroundColor)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 0) {
            Text("Notifications")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(textPrimary)
                .padding(.top, 32)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
    
    // MARK: - Filter Tabs
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(backgroundColor)
    }
    
    // MARK: - Computed Properties
    private var filteredNotifications: [NotificationItem] {
        switch selectedFilter {
        case .all:
            return notifications
        case .pickups:
            return notifications.filter { $0.type == .pickupRequest }
        case .newNearYou:
            return notifications.filter { $0.type == .newDonation }
        }
    }
}

// MARK: - Filter Tab Component
struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let textSecondary = Color(red: 0.334, green: 0.4, blue: 0.467) // slate-700
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(height: 36)
                .background(isSelected ? primaryGreen : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Notification Card Component
struct NotificationCard: View {
    let notification: NotificationItem
    
    private let cardBackground = Color.white
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let textPrimary = Color(red: 0.15, green: 0.23, blue: 0.31) // slate-800
    private let textSecondary = Color(red: 0.374, green: 0.4, blue: 0.424) // gray-600
    private let textLight = Color(red: 0.635, green: 0.643, blue: 0.655) // gray-500
    private let grayBackground = Color(red: 0.96, green: 0.96, blue: 0.96) // gray-100
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Thumbnail image
                AsyncImage(url: URL(string: notification.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Type label
                    Text(notification.type.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(textLight)
                    
                    // Main title
                    Text(notification.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textPrimary)
                    
                    // Subtitle
                    Text(notification.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(textSecondary)
                    
                    // Action buttons
                    actionButtons
                }
                
                Spacer()
            }
            .padding(16)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        switch notification.type {
        case .pickupRequest:
            HStack(spacing: 8) {
                Button(action: {
                    // Handle confirm pickup
                }) {
                    Text("Confirm Pickup")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    // Handle message
                }) {
                    Text("Message")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(grayBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.top, 8)
            
        case .newDonation:
            Button(action: {
                // Handle view donation
            }) {
                Text("View")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(grayBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Data Models
enum NotificationFilter: CaseIterable {
    case all
    case pickups
    case newNearYou
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .pickups: return "Pickups"
        case .newNearYou: return "New near you"
        }
    }
}

enum NotificationType {
    case pickupRequest
    case newDonation
    
    var displayName: String {
        switch self {
        case .pickupRequest: return "Pickup Request"
        case .newDonation: return "New Donation Near You"
        }
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let subtitle: String
    let imageURL: String
    let timestamp: Date
}

// MARK: - Sample Data
let sampleNotifications: [NotificationItem] = [
    NotificationItem(
        type: .pickupRequest,
        title: "Sophia Carter",
        subtitle: "Tomorrow, 10 AM - 12 PM",
        imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBq-1dyNE_-4B8lqJ_q-KI-0YI0tc58htRBnTMQHaLVjDiEJDBTmG8c5M90rzaIqo2VF0NDJoh19hM44fXtkI9tbJI-J4dUZegTY3XLEWgttdVH3KZVWOJxB5SXqw8UwnI2j5lp3uOwjVnnV7pmEVFE50IT7VHsQdzDnMsbbH0HL-N5nJxB0YTGjHibk3fLOzskMSRThNuYnupsMfEghh3XDOrP5yPGlbXhmNZl14IqMdI3KKJbIuCZEsmoCFjrGf6_Pdq5LdM9uNwZ",
        timestamp: Date()
    ),
    NotificationItem(
        type: .pickupRequest,
        title: "Ethan Bennett",
        subtitle: "Tomorrow, 2 PM - 4 PM",
        imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuB_a1D6QQywgv8waJ8hto4jlMysVDfIBmfM8t2_IZI59CFaPlqlHq5mQoMTahe2s1qkwvnUMLM_03Q-WbRrva1xXMrQCWhYqfOtGiosBaKpcKXY02eA1gJiBgBrQ7WP75CpWdV7N2oENmhQBcxuVEYiUfcSkrTWgztYqnn-S0clgw4Eo5QBdUtm2ofK6hMrNvGgwpb9-wE499kHqwmk6w0NrYrRSw9cFKKvvpSqQEaMzRdxSRA-CEoZrjFs97JC_5kS6VQo_vtEBl9D",
        timestamp: Date()
    ),
    NotificationItem(
        type: .newDonation,
        title: "Vintage Lamp",
        subtitle: "1.2 miles away",
        imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDsMs0WXecgPUcheaJ_UDxNK__vD9hDhzfMHJ-kwwLgbKeu1jnrSKzNiBFkTXadCAihI7ZMidb35fxO_o2tFiJunX_RSipFHWnpHIZFkWgQWP-ooAm52SUnVzNHWm6-TftxJUnvKpYvEoD4Fv2Z1Y687WdtKhIE9RiavGp6ou5i1v0iDRDLCkiATwXt5xH-hijDm_FR_mNr9iGIo4E3sbkyMNfQs1GFy1MpgSLUu1nublXnJZ0T2LcNK5UgcxKbgG5-ujO99qDuayvl",
        timestamp: Date()
    ),
    NotificationItem(
        type: .newDonation,
        title: "Children's Books",
        subtitle: "0.8 miles away",
        imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDMXs7T8IAK3hT8oHCQy6XerllzNa0FFIUIWX6xaKMJYNCEMzZ1aOSIDgJesfT1Vb-JfrsoavSGnLxZh9F22562htD_xojhzsCyAFAnMqSUQK-n4RG2kSwDuSYavbPtQZnl_JVnriy5eLfV8MKaTwmnOonWwwAtntQGBwYn5SqZtnplh-lrPAW_NbjxUE4bTJk9F-P5I1w-ScRRdZ_7C-ZerKqlugKRfCc7I0HcTf5mbW9w0XxmifD4VLMbWyIEVbxT7YVXkQ6dixYc",
        timestamp: Date()
    )
]

#Preview {
    NotificationsView()
}

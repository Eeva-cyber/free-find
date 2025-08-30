//
//  DonationItem.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import Foundation

struct DonationItem: Codable, Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var category: ItemCategory
    var condition: ItemCondition
    var photos: [String] // Store photo file names
    var location: String
    var pickupTimeStart: Date
    var pickupTimeEnd: Date
    var donorName: String
    var donorPhone: String
    var status: DonationStatus
    var createdAt: Date
    
    init(title: String, description: String, category: ItemCategory, condition: ItemCondition, location: String, pickupTimeStart: Date, pickupTimeEnd: Date, donorName: String, donorPhone: String) {
        self.title = title
        self.description = description
        self.category = category
        self.condition = condition
        self.photos = []
        self.location = location
        self.pickupTimeStart = pickupTimeStart
        self.pickupTimeEnd = pickupTimeEnd
        self.donorName = donorName
        self.donorPhone = donorPhone
        self.status = .available
        self.createdAt = Date()
    }
}

enum ItemCategory: String, CaseIterable, Codable {
    case furniture = "Furniture"
    case clothing = "Clothing"
    case electronics = "Electronics"
    case books = "Books"
    case toys = "Toys"
    case kitchenware = "Kitchenware"
    case sports = "Sports & Outdoors"
    case other = "Other"
}

enum ItemCondition: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor - Still Usable"
}

enum DonationStatus: String, Codable {
    case available = "Available"
    case claimed = "Claimed"
    case pickedUp = "Picked Up"
}

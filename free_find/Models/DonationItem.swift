//
//  DonationItem.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import Foundation

struct DonationItem: Codable, Identifiable {
    var id = UUID()
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
    var estimatedCO2Savings: Double? // CO2 savings in kg (optional, can be populated from backend)
    
    init(title: String, description: String, category: ItemCategory, condition: ItemCondition, location: String, pickupTimeStart: Date, pickupTimeEnd: Date, donorName: String, donorPhone: String) {
        self.id = UUID()
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
        self.estimatedCO2Savings = nil // Will be populated from backend or fallback
    }
    
    /// Get base CO2 footprint for item categories (in kg CO2e)
    private func getCategoryCO2Footprint(_ category: ItemCategory) -> Double {
        switch category {
        case .electronics:
            return 150.0 // Laptops, phones, etc. have high carbon footprint
        case .furniture:
            return 80.0 // Wooden furniture, sofas, etc.
        case .clothing:
            return 25.0 // Average clothing item
        case .kitchenware:
            return 15.0 // Dishes, utensils, small appliances
        case .sports:
            return 20.0 // Sports equipment
        case .toys:
            return 10.0 // Plastic/wooden toys
        case .books:
            return 2.5 // Paper books
        case .other:
            return 15.0 // Average miscellaneous item
        }
    }
    
    /// Get condition multiplier - better condition means higher reuse potential
    private func getConditionMultiplier(_ condition: ItemCondition) -> Double {
        switch condition {
        case .excellent:
            return 1.0 // Full potential savings
        case .good:
            return 0.85 // 85% of potential savings
        case .fair:
            return 0.65 // 65% of potential savings
        case .poor:
            return 0.4 // 40% of potential savings (still usable)
        }
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

// MARK: - CO2 Estimation Helper Functions
struct CO2EstimationHelper {
    /// Fallback local CO2 estimation (used when backend is unavailable)
    static func getLocalCO2Estimate(category: ItemCategory, condition: ItemCondition) -> Double {
        let baseCO2 = getCategoryCO2Footprint(category)
        let conditionMultiplier = getConditionMultiplier(condition)
        let savingsPercentage: Double = 0.8 // 80% average savings
        
        return baseCO2 * conditionMultiplier * savingsPercentage
    }
    
    /// Get base CO2 footprint for item categories (in kg CO2e) - Fallback values
    private static func getCategoryCO2Footprint(_ category: ItemCategory) -> Double {
        switch category {
        case .electronics:
            return 150.0 // Laptops, phones, etc. have high carbon footprint
        case .furniture:
            return 80.0 // Wooden furniture, sofas, etc.
        case .clothing:
            return 25.0 // Average clothing item
        case .kitchenware:
            return 15.0 // Dishes, utensils, small appliances
        case .sports:
            return 20.0 // Sports equipment
        case .toys:
            return 10.0 // Plastic/wooden toys
        case .books:
            return 2.5 // Paper books
        case .other:
            return 15.0 // Average miscellaneous item
        }
    }
    
    /// Get condition multiplier - better condition means higher reuse potential
    private static func getConditionMultiplier(_ condition: ItemCondition) -> Double {
        switch condition {
        case .excellent:
            return 1.0 // Full potential savings
        case .good:
            return 0.85 // 85% of potential savings
        case .fair:
            return 0.65 // 65% of potential savings
        case .poor:
            return 0.4 // 40% of potential savings (still usable)
        }
    }
    /// Format CO2 savings for display
    static func formatCO2Savings(_ co2Kg: Double) -> String {
        if co2Kg >= 1.0 {
            return String(format: "%.1f kg", co2Kg)
        } else {
            let grams = co2Kg * 1000
            return String(format: "%.0f g", grams)
        }
    }
    
    /// Get a contextual message about the CO2 savings
    static func getCO2SavingsMessage(_ co2Kg: Double) -> String {
        let formattedSavings = formatCO2Savings(co2Kg)
        
        if co2Kg >= 100 {
            return "🌍 Amazing! You've saved approximately \(formattedSavings) of CO2 emissions - that's like taking a car off the road for several days!"
        } else if co2Kg >= 50 {
            return "🌱 Great impact! You've saved approximately \(formattedSavings) of CO2 emissions - equivalent to planting a tree!"
        } else if co2Kg >= 10 {
            return "♻️ Nice work! You've saved approximately \(formattedSavings) of CO2 emissions by choosing to donate instead of discard."
        } else {
            return "🌿 Every bit helps! You've saved approximately \(formattedSavings) of CO2 emissions - small actions make a big difference!"
        }
    }
}

//
//  CO2EstimationService.swift
//  free_find
//
//  Created by GitHub Copilot on 9/4/25.
//

import Foundation

struct CO2EstimationService {
    
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

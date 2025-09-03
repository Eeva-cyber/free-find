//
//  AppConfiguration.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import Foundation

struct AppConfiguration {
    // Development flags
    static let isDevelopment = true
    static let skipWelcomeScreen = false // Set to false to always show welcome
    static let skipLoadingScreen = false // Set to false to always show loading
    
    // Animation durations
    static let loadingDuration: TimeInterval = 3.0
    static let splashDuration: TimeInterval = 2.0
    static let transitionDuration: TimeInterval = 0.8
    
    // App colors
    struct Colors {
        static let primary = "6B3C13" // #6B3C13 - brown for loading/welcome
        static let primaryGreen = "2E7D32" // #2E7D32 - green for home page
        static let background = "FAF5EF" // #FAF5EF - cream for loading/welcome
        static let homeBackground = "F9F9F5" // #F9F9F5 - light green-gray for home
        static let secondary = "8B5A32"
        static let darkText = "1F1F1F" // #1F1F1F - main text color
        static let lightBackground = "E8F5E9" // #E8F5E9 - light green backgrounds
    }
    
    // UserDefaults keys
    struct UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let appVersion = "appVersion"
    }
    
    // Reset UserDefaults for testing (call this if you want to reset the app state)
    static func resetAppState() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasLaunchedBefore)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        print("App state reset - will show welcome screen on next launch")
    }
}

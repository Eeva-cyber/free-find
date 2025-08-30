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
    static let skipWelcomeScreen = false // Set to true during development if you want to skip the welcome
    static let skipLoadingScreen = false // Set to true during development if you want to skip loading
    
    // Animation durations
    static let loadingDuration: TimeInterval = 3.0
    static let splashDuration: TimeInterval = 2.0
    static let transitionDuration: TimeInterval = 0.8
    
    // App colors
    struct Colors {
        static let primary = "6B3C13" // #6B3C13
        static let background = "FAF5EF" // #FAF5EF
        static let secondary = "8B5A32"
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

//
//  MainAppView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct MainAppView: View {
    @State private var showingLoadingView = !AppConfiguration.skipLoadingScreen
    @State private var showingWelcomeView = false
    @StateObject private var donationStore = DonationStore()
    @StateObject private var authManager = AuthenticationManager()
    
    private var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: AppConfiguration.UserDefaultsKeys.hasLaunchedBefore) && !AppConfiguration.skipWelcomeScreen
    }
    
    var body: some View {
        ZStack {
            if showingLoadingView {
                LoadingView {
                    withAnimation(.easeInOut(duration: AppConfiguration.transitionDuration)) {
                        showingLoadingView = false
                        if isFirstLaunch {
                            showingWelcomeView = true
                        }
                    }
                }
                .transition(.opacity)
            } else if showingWelcomeView {
                WelcomeView {
                    withAnimation(.easeInOut(duration: AppConfiguration.transitionDuration)) {
                        showingWelcomeView = false
                        UserDefaults.standard.set(true, forKey: AppConfiguration.UserDefaultsKeys.hasLaunchedBefore)
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            } else {
                if authManager.isLoggedIn {
                    ContentView()
                        .environmentObject(donationStore)
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Connect DonationStore to AuthenticationManager for loyalty updates
            donationStore.setAuthManager(authManager)
            
            // For development: Uncomment this line to reset app state and always show welcome screen
            // AppConfiguration.resetAppState()
        }
    }
}

#Preview {
    MainAppView()
}

//
//  WelcomeView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    @State private var currentPage = 0
    @State private var dragOffset: CGSize = .zero
    
    private let pages = [
        WelcomePage(
            icon: "heart.fill",
            title: "Welcome to FreeFind",
            subtitle: "Share and discover free items in your community",
            description: "Connect with neighbors to give away items you no longer need and find treasures others are sharing."
        ),
        WelcomePage(
            icon: "plus.circle.fill",
            title: "Share Your Items",
            subtitle: "Easily donate items you no longer need",
            description: "Take photos, add descriptions, and let your community know about items you'd like to share."
        ),
        WelcomePage(
            icon: "magnifyingglass",
            title: "Discover Treasures",
            subtitle: "Find amazing free items near you",
            description: "Browse through items shared by your neighbors and discover things you've been looking for."
        ),
        WelcomePage(
            icon: "leaf.fill",
            title: "Help the Environment",
            subtitle: "Reduce waste through sharing",
            description: "By sharing and reusing items, we're building a more sustainable community together."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.98, green: 0.96, blue: 0.94) // #FAF5EF
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top area with pages
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            WelcomePageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    #if os(iOS)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    #endif
                    .frame(maxHeight: geometry.size.height * 0.75)
                    
                    // Bottom section with button
                    VStack(spacing: 20) {
                        // Page indicator (custom)
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? 
                                          Color(red: 0.42, green: 0.24, blue: 0.07) : 
                                          Color(red: 0.42, green: 0.24, blue: 0.07).opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        
                        // Continue button
                        Button(action: onContinue) {
                            HStack {
                                Text("Get Started")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.42, green: 0.24, blue: 0.07))
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 32)
                        
                        // Skip button
                        Button("Skip for now") {
                            onContinue()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07).opacity(0.7))
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

struct WelcomePage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

struct WelcomePageView: View {
    let page: WelcomePage
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .regular))
                .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07))
                .scaleEffect(animateIcon ? 1.0 : 0.8)
                .opacity(animateIcon ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateIcon)
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07))
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateText)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07).opacity(0.8))
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: animateText)
                
                // Description
                Text(page.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateText)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            animateIcon = true
            animateText = true
        }
        .onDisappear {
            animateIcon = false
            animateText = false
        }
    }
}

#Preview {
    WelcomeView {
        print("Continue tapped!")
    }
}

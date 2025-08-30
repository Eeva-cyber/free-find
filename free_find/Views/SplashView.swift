//
//  SplashView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.94), // #FAF5EF
                    Color(red: 0.96, green: 0.94, blue: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)
            
            VStack {
                // Main logo
                Text("FF")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07)) // #6B3C13
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // App name
                Text("FreeFind")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07).opacity(0.8))
                    .tracking(2)
                    .opacity(logoOpacity)
                    .offset(y: logoOpacity == 1.0 ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: logoOpacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Background fade in
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Logo animation
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
    }
}

#Preview {
    SplashView {
        print("Splash completed!")
    }
}

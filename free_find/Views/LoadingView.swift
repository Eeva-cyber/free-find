//
//  LoadingView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var progress: Double = 0.0
    @State private var isLoading = true
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var progressBarOpacity: Double = 0.0
    
    let onLoadingComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color matching your HTML design
                Color(red: 0.98, green: 0.96, blue: 0.94) // #FAF5EF
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // "FF" Logo with animations
                    Text("FF")
                        .e(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07)) // #6B3C13
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Progress Bar Container
                    VStack(spacing: 16) {
                        // Progress Bar
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.white)
                                .frame(width: min(geometry.size.width * 0.6, 300), height: 14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color(red: 0.42, green: 0.24, blue: 0.07), lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            // Progress fill with gradient
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.42, green: 0.24, blue: 0.07),
                                            Color(red: 0.52, green: 0.34, blue: 0.17)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: (min(geometry.size.width * 0.6, 300)) * progress,
                                    height: 10
                                )
                                .offset(x: 2) // Small offset to account for border
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                        .opacity(progressBarOpacity)
                        
                        // Loading text with subtle animation
                        HStack(spacing: 2) {
                            Text("loading")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07))
                                .tracking(1.2) // Letter spacing
                            
                            // Animated dots
                            HStack(spacing: 1) {
                                ForEach(0..<3, id: \.self) { index in
                                    Text(".")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(red: 0.42, green: 0.24, blue: 0.07))
                                        .opacity(animatedDotOpacity(for: index))
                                        .animation(
                                            .easeInOut(duration: 0.6)
                                                .repeatForever()
                                                .delay(Double(index) * 0.2),
                                            value: isLoading
                                        )
                                }
                            }
                        }
                        .opacity(progressBarOpacity)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func animatedDotOpacity(for index: Int) -> Double {
        let baseTime = Date().timeIntervalSince1970
        let offset = Double(index) * 0.3
        return 0.3 + 0.7 * abs(sin(baseTime * 2 + offset))
    }
    
    private func startLoadingAnimation() {
        // Logo entrance animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Progress bar entrance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                progressBarOpacity = 1.0
            }
        }
        
        // Start progress animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Simulate loading progress with more realistic timing
            let totalDuration = AppConfiguration.isDevelopment ? 2.0 : AppConfiguration.loadingDuration
            let updateInterval = 0.08
            let totalUpdates = totalDuration / updateInterval
            let incrementPerUpdate = 1.0 / totalUpdates
            
            let timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
                withAnimation(.easeOut(duration: 0.2)) {
                    progress += incrementPerUpdate
                    
                    if progress >= 1.0 {
                        progress = 1.0
                        timer.invalidate()
                        
                        // Small delay before transitioning
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onLoadingComplete()
                        }
                    }
                }
            }
            
            // Fallback completion after maximum time
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 2.0) {
                timer.invalidate()
                if progress < 1.0 {
                    onLoadingComplete()
                }
            }
        }
    }
}

// Extension to support custom fonts if you want to add Poppins later
extension Font {
    static func poppins(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}

#Preview {
    LoadingView {
        print("Loading completed!")
    }
}

//
//  BackendTestView.swift
//  free_find
//
//  Created for Backend Testing
//

import SwiftUI

struct BackendTestView: View {
    @State private var healthStatus = "Unknown"
    @State private var isLoading = false
    @State private var testResults = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Backend Health")
                            .font(.headline)
                        
                        HStack {
                            Text("Status:")
                            Text(healthStatus)
                                .foregroundColor(healthStatus == "Healthy" ? .green : .red)
                            
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        Button("Check Health") {
                            Task {
                                await checkBackendHealth()
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI Text Analysis Test")
                            .font(.headline)
                        
                        Button("Test AI Analysis") {
                            Task {
                                await testTextAnalysis()
                            }
                        }
                        .disabled(isLoading)
                        
                        if !testResults.isEmpty {
                            ScrollView {
                                Text(testResults)
                                    .font(.caption)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Backend Test")
        }
        .onAppear {
            Task {
                await checkBackendHealth()
            }
        }
    }
    
    private func checkBackendHealth() async {
        isLoading = true
        
        do {
            print("🏥 Testing backend health...")
            let isHealthy = try await BackendService.shared.checkHealth()
            await MainActor.run {
                healthStatus = isHealthy ? "Healthy" : "Unhealthy"
                isLoading = false
                print("✅ Backend health check successful: \(isHealthy)")
            }
        } catch {
            print("❌ Backend health check failed: \(error)")
            await MainActor.run {
                healthStatus = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func testTextAnalysis() async {
        isLoading = true
        testResults = "Testing..."
        
        do {
            let result = try await BackendService.shared.analyzeText(
                "I want to donate a wooden chair in good condition",
                task: "categorize this donation item"
            )
            
            await MainActor.run {
                testResults = "SUCCESS!\n\nAnalysis: \(result.analysis ?? "No analysis")"
                isLoading = false
            }
        } catch {
            await MainActor.run {
                testResults = "ERROR: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    BackendTestView()
}

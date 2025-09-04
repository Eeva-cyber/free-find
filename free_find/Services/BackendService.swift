//
//  BackendService.swift
//  free_find
//
//  Created for Free Find Backend Integration
//

import Foundation
import SwiftUI

// MARK: - Response Models
struct AnalysisResponse: Codable {
    let success: Bool
    let task: String
    let result: AnalysisResult
    let error: String?
}

struct AnalysisResult: Codable {
    let category: String?
    let title: String?
    let description: String?
    let condition: String?
    let confidence: Double?
    let rawResponse: String?
    let note: String?
    let analysis: String?
}

struct CO2EstimationResponse: Codable {
    let success: Bool
    let result: CO2EstimationResult
    let error: String?
}

struct CO2EstimationResult: Codable {
    let co2Savings: Double
    let unit: String
    let confidence: Double?
    let explanation: String?
    let methodology: String?
}

// MARK: - Backend Service
class BackendService {
    static let shared = BackendService()
    
    // Configure your backend URL here
    private let baseURL = "http://34.129.197.247:8080" // Your GCP instance external IP
    
    private init() {}
    
    // MARK: - Health Check
    func checkHealth() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw BackendError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BackendError.serverError
        }
        
        return true
    }
    
    // MARK: - Image Analysis
    func analyzeImage(_ image: UIImage, task: String = "categorize") async throws -> AnalysisResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BackendError.imageProcessingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "image": base64Image,
            "task": task
        ]
        
        guard let url = URL(string: "\(baseURL)/analyze-image") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30 // 30 second timeout for AI processing
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(AnalysisResponse.self, from: data) {
                throw BackendError.apiError(errorResponse.error ?? "Unknown error")
            }
            throw BackendError.serverError
        }
        
        let analysisResponse = try JSONDecoder().decode(AnalysisResponse.self, from: data)
        
        if !analysisResponse.success {
            throw BackendError.apiError(analysisResponse.error ?? "Analysis failed")
        }
        
        return analysisResponse.result
    }
    
    // MARK: - Text Analysis
    func analyzeText(_ text: String, task: String = "analyze") async throws -> AnalysisResult {
        let requestBody: [String: Any] = [
            "text": text,
            "task": task
        ]
        
        guard let url = URL(string: "\(baseURL)/analyze-text") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(AnalysisResponse.self, from: data) {
                throw BackendError.apiError(errorResponse.error ?? "Unknown error")
            }
            throw BackendError.serverError
        }
        
        let analysisResponse = try JSONDecoder().decode(AnalysisResponse.self, from: data)
        
        if !analysisResponse.success {
            throw BackendError.apiError(analysisResponse.error ?? "Analysis failed")
        }
        
        return analysisResponse.result
    }
    
    // MARK: - Helper Methods
    func mapCategoryToItemCategory(_ category: String?) -> ItemCategory {
        guard let category = category else { return .other }
        
        switch category.lowercased() {
        case "furniture":
            return .furniture
        case "clothing":
            return .clothing
        case "electronics":
            return .electronics
        case "books":
            return .books
        case "toys":
            return .toys
        case "kitchenware":
            return .kitchenware
        case "sports & outdoors", "sports":
            return .sports
        default:
            return .other
        }
    }
    
    func mapConditionToItemCondition(_ condition: String?) -> ItemCondition {
        guard let condition = condition else { return .good }
        
        switch condition.lowercased() {
        case "new", "like new", "excellent":
            return .excellent
        case "good":
            return .good
        case "fair":
            return .fair
        case "poor":
            return .poor
        default:
            return .good
        }
    }
    
    // MARK: - CO2 Estimation
    func estimateCO2Savings(category: String, condition: String, title: String? = nil, description: String? = nil) async throws -> CO2EstimationResult {
        let requestBody: [String: Any] = [
            "category": category,
            "condition": condition,
            "title": title ?? "",
            "description": description ?? "",
            "task": "estimate_co2"
        ]
        
        guard let url = URL(string: "\(baseURL)/estimate-co2") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15 // 15 second timeout for CO2 estimation
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(CO2EstimationResponse.self, from: data) {
                throw BackendError.apiError(errorResponse.error ?? "Unknown error")
            }
            throw BackendError.serverError
        }
        
        let co2Response = try JSONDecoder().decode(CO2EstimationResponse.self, from: data)
        
        if !co2Response.success {
            throw BackendError.apiError(co2Response.error ?? "CO2 estimation failed")
        }
        
        return co2Response.result
    }
}

// MARK: - Error Types
enum BackendError: LocalizedError {
    case invalidURL
    case networkError
    case serverError
    case imageProcessingFailed
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL"
        case .networkError:
            return "Network connection failed"
        case .serverError:
            return "Server error occurred"
        case .imageProcessingFailed:
            return "Failed to process image"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}

// MARK: - Usage Example in your Views
/*
// Example usage in your DonateView or similar:

// 1. Analyze an image to get suggested donation details
func analyzeItemImage(_ image: UIImage) async {
    do {
        let result = try await BackendService.shared.analyzeImage(image)
        
        DispatchQueue.main.async {
            // Update your form with AI suggestions
            if let title = result.title {
                self.itemTitle = title
            }
            if let description = result.description {
                self.itemDescription = description
            }
            if let category = result.category {
                self.selectedCategory = BackendService.shared.mapCategoryToItemCategory(category)
            }
            if let condition = result.condition {
                self.selectedCondition = BackendService.shared.mapConditionToItemCondition(condition)
            }
        }
    } catch {
        print("Error analyzing image: \(error)")
        // Handle error in UI
    }
}

// 2. Check if backend is available
func checkBackendHealth() async {
    do {
        let isHealthy = try await BackendService.shared.checkHealth()
        print("Backend is healthy: \(isHealthy)")
    } catch {
        print("Backend health check failed: \(error)")
    }
}
*/

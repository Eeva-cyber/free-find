//
//  DonateView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI
import PhotosUI

struct DonateView: View {
    @EnvironmentObject var donationStore: DonationStore
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = ItemCategory.other
    @State private var selectedCondition = ItemCondition.good
    @State private var location = ""
    @State private var pickupStartDate = Date()
    @State private var pickupEndDate = Date().addingTimeInterval(24 * 60 * 60) // Default to next day
    @State private var donorName = ""
    @State private var donorPhone = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var showingSuccessAlert = false
    
    // AI Analysis states
    @State private var isAnalyzing = false
    @State private var showingAnalysisError = false
    @State private var analysisErrorMessage = ""
    @State private var aiSuggestionApplied = false
    @State private var debugMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                }
                
                Section("Photos") {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Add Photos (\(selectedPhotos.count)/5)")
                            
                            if isAnalyzing {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .onChange(of: selectedPhotos) { oldPhotos, newPhotos in
                        debugMessage = "Photos changed: \(newPhotos.count) photos selected"
                        print("🔄 Photos changed: \(newPhotos.count) photos")
                        Task {
                            await loadImages(from: newPhotos)
                        }
                    }
                    
                    if !selectedPhotos.isEmpty {
                        HStack {
                            Text("\(selectedPhotos.count) photo(s) selected")
                                .foregroundColor(.secondary)
                            
                            if aiSuggestionApplied {
                                Spacer()
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.blue)
                                    Text("AI Enhanced")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    if isAnalyzing {
                        HStack {
                            Image(systemName: "brain")
                                .foregroundColor(.blue)
                            Text("AI is analyzing your photo...")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    // Debug message
                    if !debugMessage.isEmpty {
                        Text("Debug: \(debugMessage)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    // Show AI analysis button if we have images but haven't analyzed
                    if !loadedImages.isEmpty && !isAnalyzing && !aiSuggestionApplied {
                        Button(action: {
                            debugMessage = "Manual analysis triggered"
                            print("🔄 Manual analysis button pressed")
                            Task {
                                await analyzeFirstImage()
                            }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Get AI Suggestions")
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section("Pickup Information") {
                    TextField("Pickup Location", text: $location)
                        .textContentType(.fullStreetAddress)
                    
                    DatePicker("Available From", 
                             selection: $pickupStartDate, 
                             in: Date()..., 
                             displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Available Until", 
                             selection: $pickupEndDate, 
                             in: pickupStartDate..., 
                             displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Contact Information") {
                    TextField("Your Name", text: $donorName)
                        .textContentType(.name)
                    
                    TextField("Your Phone Number", text: $donorPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section {
                    Button("Post Donation") {
                        postDonation()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Donate Item")
        }
        .alert("Success!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                clearForm()
            }
        } message: {
            Text("Your item has been posted! Others can now discover and claim it.")
        }
        .alert("AI Analysis Error", isPresented: $showingAnalysisError) {
            Button("OK") { }
        } message: {
            Text(analysisErrorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && 
        !description.isEmpty && 
        !location.isEmpty && 
        !donorName.isEmpty && 
        !donorPhone.isEmpty &&
        pickupEndDate > pickupStartDate
    }
    
    private func postDonation() {
        let donation = DonationItem(
            title: title,
            description: description,
            category: selectedCategory,
            condition: selectedCondition,
            location: location,
            pickupTimeStart: pickupStartDate,
            pickupTimeEnd: pickupEndDate,
            donorName: donorName,
            donorPhone: donorPhone
        )
        
        donationStore.addDonation(donation)
        showingSuccessAlert = true
    }
    
    private func clearForm() {
        title = ""
        description = ""
        selectedCategory = .other
        selectedCondition = .good
        location = ""
        pickupStartDate = Date()
        pickupEndDate = Date().addingTimeInterval(24 * 60 * 60)
        donorName = ""
        donorPhone = ""
        selectedPhotos = []
        loadedImages = []
        aiSuggestionApplied = false
    }
    
    // MARK: - AI Analysis Functions
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        print("🖼️ Loading \(items.count) images...")
        debugMessage = "Loading \(items.count) images..."
        
        loadedImages = []
        
        for (index, item) in items.enumerated() {
            do {
                print("📷 Loading image \(index + 1)/\(items.count)")
                if let data = try await item.loadTransferable(type: Data.self) {
                    print("✅ Image data loaded: \(data.count) bytes")
                    if let image = UIImage(data: data) {
                        print("✅ UIImage created successfully")
                        await MainActor.run {
                            loadedImages.append(image)
                            debugMessage = "Loaded \(loadedImages.count) images"
                        }
                    } else {
                        print("❌ Failed to create UIImage from data")
                    }
                } else {
                    print("❌ Failed to load image data")
                }
            } catch {
                print("❌ Error loading image: \(error)")
                await MainActor.run {
                    debugMessage = "Error loading image: \(error.localizedDescription)"
                }
            }
        }
        
        print("🎯 Total images loaded: \(loadedImages.count)")
        
        // Auto-analyze the first image when loaded
        if !loadedImages.isEmpty && !aiSuggestionApplied {
            print("🚀 Starting automatic analysis...")
            await analyzeFirstImage()
        } else {
            print("⏭️ Skipping analysis - no images or already analyzed")
        }
    }
    
    private func analyzeFirstImage() async {
        guard let firstImage = loadedImages.first, !isAnalyzing else {
            print("❌ Cannot analyze: no image or already analyzing")
            return
        }
        
        print("🧠 Starting AI analysis...")
        
        await MainActor.run {
            isAnalyzing = true
            debugMessage = "Analyzing image with AI..."
        }
        
        do {
            print("📡 Sending image to backend...")
            let result = try await BackendService.shared.analyzeImage(firstImage)
            print("✅ AI analysis successful: \(result)")
            
            await MainActor.run {
                // Apply AI suggestions to the form
                if let aiTitle = result.title, title.isEmpty {
                    title = aiTitle
                    print("📝 Set title: \(aiTitle)")
                }
                
                if let aiDescription = result.description, description.isEmpty {
                    description = aiDescription
                    print("📄 Set description: \(aiDescription)")
                }
                
                if let aiCategory = result.category {
                    selectedCategory = BackendService.shared.mapCategoryToItemCategory(aiCategory)
                    print("📂 Set category: \(aiCategory) -> \(selectedCategory)")
                }
                
                if let aiCondition = result.condition {
                    selectedCondition = BackendService.shared.mapConditionToItemCondition(aiCondition)
                    print("⭐ Set condition: \(aiCondition) -> \(selectedCondition)")
                }
                
                aiSuggestionApplied = true
                isAnalyzing = false
                debugMessage = "AI analysis complete! 🎉"
            }
        } catch {
            print("❌ AI analysis failed: \(error)")
            await MainActor.run {
                analysisErrorMessage = "Failed to analyze image: \(error.localizedDescription)\n\nMake sure you're connected to the internet and the backend is running."
                showingAnalysisError = true
                isAnalyzing = false
                debugMessage = "Analysis failed: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    DonateView()
        .environmentObject(DonationStore())
}

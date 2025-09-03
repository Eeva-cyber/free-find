//
//  DonateView.swift
//  free_find
//
//  Created by jack ren on 8/30/25.
//

import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

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
    
    // Location states
    @State private var isLoadingLocation = false
    @State private var userLocation: CLLocation?
    @State private var locationManager = LocationManager()
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingMap = false
    
    // Colors matching modern design
    private let backgroundColor = Color(red: 0.976, green: 0.969, blue: 0.961) // #F9F7F5
    private let cardBackground = Color.white
    private let primaryGreen = Color(red: 0.18, green: 0.49, blue: 0.20) // #2E7D32
    private let textPrimary = Color(red: 0.15, green: 0.23, blue: 0.31) // slate-800
    private let textSecondary = Color(red: 0.374, green: 0.4, blue: 0.424) // gray-600
    private let inputBackground = Color(red: 0.96, green: 0.96, blue: 0.94) // #f5f5f0
    
    // MARK: - Map Annotations
    private var mapAnnotations: [MapAnnotation] {
        if let userLocation = userLocation {
            return [MapAnnotation(coordinate: userLocation.coordinate)]
        }
        return []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Main content
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Photo upload card
                    photoUploadCard
                    
                    // Item details card
                    itemDetailsCard
                    
                    // Pickup information card
                    pickupInfoCard
                    
                    // Contact information card
                    contactInfoCard
                    
                    // Submit button
                    submitButton
                    
                    // Debug message
                    if !debugMessage.isEmpty {
                        Text(debugMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100) // Space for tab bar
            }
            .background(backgroundColor)
            
            Spacer()
        }
        .background(backgroundColor)
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
        .onChange(of: selectedPhotos) { oldPhotos, newPhotos in
            debugMessage = "Photos changed: \(newPhotos.count) photos selected"
            print("🔄 Photos changed: \(newPhotos.count) photos")
            Task {
                await loadImages(from: newPhotos)
            }
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            if let newLocation = newLocation {
                Task {
                    await convertLocationToAddress(newLocation)
                }
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 0) {
            Text("Donate an Item")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(textPrimary)
                .padding(.top, 32)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
    
    // MARK: - Photo Upload Card
    private var photoUploadCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Photos")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                // Photo upload area
                VStack(spacing: 16) {
                    if loadedImages.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.gray.opacity(0.4))
                            
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
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(primaryGreen)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(primaryGreen, lineWidth: 2)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 120)
                        .background(Color.gray.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        )
                    } else {
                        // Show uploaded images
                        VStack(alignment: .leading, spacing: 12) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    
                                    // Add more photos button
                                    if loadedImages.count < 5 {
                                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                                            VStack {
                                                Image(systemName: "plus")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 80, height: 80)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            
                            // AI status
                            if aiSuggestionApplied {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(primaryGreen)
                                    Text("AI Enhanced")
                                        .font(.caption)
                                        .foregroundColor(primaryGreen)
                                }
                            } else if isAnalyzing {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("AI is analyzing your photo...")
                                        .foregroundColor(primaryGreen)
                                        .font(.caption)
                                }
                            } else if !loadedImages.isEmpty && !aiSuggestionApplied {
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
                                    .font(.caption)
                                    .foregroundColor(primaryGreen)
                                }
                            }
                        }
                    }
                }
                
                // Debug message
                if !debugMessage.isEmpty {
                    Text("Debug: \(debugMessage)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Item Details Card
    private var itemDetailsCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Item Details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                VStack(spacing: 16) {
                    // Title field
                    ModernTextField(
                        title: "Item Title",
                        text: $title,
                        placeholder: "e.g., Vintage Armchair"
                    )
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        TextField("Describe your item...", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Category picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Condition picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Condition")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        Picker("Condition", selection: $selectedCondition) {
                            ForEach(ItemCondition.allCases, id: \.self) { condition in
                                Text(condition.rawValue).tag(condition)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(20)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Pickup Info Card
    private var pickupInfoCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pickup Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                VStack(spacing: 16) {
                    // Location field with current location button
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pickup Location")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        HStack(spacing: 12) {
                            TextField("Enter pickup address", text: $location)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button(action: {
                                getCurrentLocation()
                            }) {
                                HStack(spacing: 6) {
                                    if isLoadingLocation {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 14))
                                    }
                                    Text(isLoadingLocation ? "Loading..." : "Current")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(primaryGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .disabled(isLoadingLocation)
                            
                            Button(action: {
                                showingMap.toggle()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: showingMap ? "eye.slash" : "map")
                                        .font(.system(size: 14))
                                    Text(showingMap ? "Hide" : "Map")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    // Map view with pin
                    if showingMap && (!location.isEmpty || userLocation != nil) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pickup Location on Map")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(textSecondary)
                            
                            Map(coordinateRegion: $mapRegion, annotationItems: mapAnnotations) { annotation in
                                MapMarker(coordinate: annotation.coordinate, tint: .init(primaryGreen))
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Date pickers
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available From")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        DatePicker("Available From", 
                                 selection: $pickupStartDate, 
                                 in: Date()..., 
                                 displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Until")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textSecondary)
                        
                        DatePicker("Available Until", 
                                 selection: $pickupEndDate, 
                                 in: pickupStartDate..., 
                                 displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(20)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Contact Info Card
    private var contactInfoCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contact Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                
                VStack(spacing: 16) {
                    ModernTextField(
                        title: "Your Name",
                        text: $donorName,
                        placeholder: "Enter your name"
                    )
                    
                    ModernTextField(
                        title: "Phone Number",
                        text: $donorPhone,
                        placeholder: "Enter your phone number"
                    )
                }
            }
            .padding(20)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            postDonation()
        }) {
            Text("Post Donation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(primaryGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
        .padding(.top, 8)
    }
    
    // MARK: - Modern Text Field Component
    private struct ModernTextField: View {
        let title: String
        @Binding var text: String
        let placeholder: String
        
        private let textSecondary = Color(red: 0.374, green: 0.4, blue: 0.424) // gray-600
        private let inputBackground = Color(red: 0.96, green: 0.96, blue: 0.94) // #f5f5f0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textSecondary)
                
                TextField(placeholder, text: $text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        !title.isEmpty && 
        !description.isEmpty && 
        !location.isEmpty && 
        !donorName.isEmpty && 
        !donorPhone.isEmpty &&
        pickupEndDate > pickupStartDate
    }
    
    // MARK: - Form Submission
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
    
    // MARK: - Location Functions
    private func getCurrentLocation() {
        isLoadingLocation = true
        debugMessage = "Getting current location..."
        
        locationManager.requestLocation()
    }
    
    private func convertLocationToAddress(_ location: CLLocation) async {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                await MainActor.run {
                    // Create a readable address string
                    var addressComponents: [String] = []
                    
                    if let streetNumber = placemark.subThoroughfare {
                        addressComponents.append(streetNumber)
                    }
                    if let streetName = placemark.thoroughfare {
                        addressComponents.append(streetName)
                    }
                    if let city = placemark.locality {
                        addressComponents.append(city)
                    }
                    if let state = placemark.administrativeArea {
                        addressComponents.append(state)
                    }
                    if let zipCode = placemark.postalCode {
                        addressComponents.append(zipCode)
                    }
                    
                    self.location = addressComponents.joined(separator: ", ")
                    self.isLoadingLocation = false
                    
                    // Update map region to center on the new location
                    self.mapRegion = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    
                    debugMessage = "Location updated: \(self.location)"
                    print("📍 Location set to: \(self.location)")
                }
            }
        } catch {
            await MainActor.run {
                isLoadingLocation = false
                debugMessage = "Failed to get address: \(error.localizedDescription)"
                print("❌ Geocoding error: \(error)")
            }
        }
    }
    
    // MARK: - Form Reset
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
    
    // MARK: - Photo Loading
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

// MARK: - Map Annotation
struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        guard authorizationStatus != .denied else { return }
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    DonateView()
        .environmentObject(DonationStore())
}

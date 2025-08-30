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
    @State private var showingSuccessAlert = false
    
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
                        }
                    }
                    
                    if !selectedPhotos.isEmpty {
                        Text("\(selectedPhotos.count) photo(s) selected")
                            .foregroundColor(.secondary)
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
    }
}

#Preview {
    DonateView()
        .environmentObject(DonationStore())
}

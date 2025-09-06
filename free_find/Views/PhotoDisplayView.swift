//
//  PhotoDisplayView.swift
//  free_find
//
//  Created by GitHub Copilot on 9/6/25.
//

import SwiftUI
import UIKit

struct PhotoDisplayView: View {
    let photoFilenames: [String]
    let maxDisplayCount: Int
    
    @State private var loadedImages: [UIImage] = []
    @State private var isLoading = true
    
    init(photoFilenames: [String], maxDisplayCount: Int = 3) {
        self.photoFilenames = photoFilenames
        self.maxDisplayCount = maxDisplayCount
    }
    
    var body: some View {
        Group {
            if isLoading {
                // Loading placeholder
                HStack(spacing: 8) {
                    ForEach(0..<min(maxDisplayCount, photoFilenames.count), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.7)
                            )
                    }
                }
            } else if loadedImages.isEmpty {
                // No photos fallback
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundColor(.gray)
                    )
            } else {
                // Display loaded photos
                HStack(spacing: 8) {
                    ForEach(Array(loadedImages.prefix(maxDisplayCount).enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    }
                    
                    // Show count if there are more photos
                    if loadedImages.count > maxDisplayCount {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("+\(loadedImages.count - maxDisplayCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .onAppear {
            loadPhotos()
        }
    }
    
    private func loadPhotos() {
        guard !photoFilenames.isEmpty else {
            isLoading = false
            return
        }
        
        Task {
            let images = PhotoStorageService.shared.loadPhotos(filenames: photoFilenames)
            
            await MainActor.run {
                self.loadedImages = images
                self.isLoading = false
            }
        }
    }
}

// Full screen photo gallery view
struct PhotoGalleryView: View {
    let photoFilenames: [String]
    @Binding var isPresented: Bool
    
    @State private var loadedImages: [UIImage] = []
    @State private var currentIndex: Int = 0
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading photos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if loadedImages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No photos available")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Photo viewer
                    TabView(selection: $currentIndex) {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    // Photo counter
                    if loadedImages.count > 1 {
                        Text("\(currentIndex + 1) of \(loadedImages.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
        .onAppear {
            loadPhotos()
        }
    }
    
    private func loadPhotos() {
        guard !photoFilenames.isEmpty else {
            isLoading = false
            return
        }
        
        Task {
            let images = PhotoStorageService.shared.loadPhotos(filenames: photoFilenames)
            
            await MainActor.run {
                self.loadedImages = images
                self.isLoading = false
            }
        }
    }
}

// Compact photo display with tap to expand
struct TappablePhotoDisplay: View {
    let photoFilenames: [String]
    let maxDisplayCount: Int
    
    @State private var showingGallery = false
    
    init(photoFilenames: [String], maxDisplayCount: Int = 3) {
        self.photoFilenames = photoFilenames
        self.maxDisplayCount = maxDisplayCount
    }
    
    var body: some View {
        Button(action: {
            if !photoFilenames.isEmpty {
                showingGallery = true
            }
        }) {
            PhotoDisplayView(photoFilenames: photoFilenames, maxDisplayCount: maxDisplayCount)
                .onAppear {
                    // Trigger photo loading when view appears
                }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingGallery) {
            PhotoGalleryView(photoFilenames: photoFilenames, isPresented: $showingGallery)
        }
    }
}

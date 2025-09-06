//
//  PhotoStorageService.swift
//  free_find
//
//  Created by GitHub Copilot on 9/6/25.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

class PhotoStorageService {
    static let shared = PhotoStorageService()
    
    private init() {}
    
    private var photosDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDir = documentsPath.appendingPathComponent("ItemPhotos")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: photosDir.path) {
            try? FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return photosDir
    }
    
    /// Save a photo to disk and return the filename
    func savePhoto(_ image: UIImage, for itemId: UUID) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            return nil
        }
        
        let filename = "\(itemId.uuidString)_\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Photo saved: \(filename)")
            return filename
        } catch {
            print("❌ Failed to save photo: \(error)")
            return nil
        }
    }
    
    /// Save multiple photos and return their filenames
    func savePhotos(_ images: [UIImage], for itemId: UUID) -> [String] {
        var savedFilenames: [String] = []
        
        for image in images {
            if let filename = savePhoto(image, for: itemId) {
                savedFilenames.append(filename)
            }
        }
        
        print("💾 Saved \(savedFilenames.count) out of \(images.count) photos for item \(itemId)")
        return savedFilenames
    }
    
    /// Load a photo from disk
    func loadPhoto(filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("❌ Photo file not found: \(filename)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to load photo data: \(filename)")
            return nil
        }
        
        guard let image = UIImage(data: imageData) else {
            print("❌ Failed to create UIImage from data: \(filename)")
            return nil
        }
        
        return image
    }
    
    /// Load multiple photos from filenames
    func loadPhotos(filenames: [String]) -> [UIImage] {
        var loadedImages: [UIImage] = []
        
        for filename in filenames {
            if let image = loadPhoto(filename: filename) {
                loadedImages.append(image)
            }
        }
        
        print("📷 Loaded \(loadedImages.count) out of \(filenames.count) photos")
        return loadedImages
    }
    
    /// Delete a photo from disk
    func deletePhoto(filename: String) -> Bool {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑️ Photo deleted: \(filename)")
            return true
        } catch {
            print("❌ Failed to delete photo: \(error)")
            return false
        }
    }
    
    /// Delete multiple photos
    func deletePhotos(filenames: [String]) {
        for filename in filenames {
            _ = deletePhoto(filename: filename)
        }
    }
    
    /// Clean up orphaned photos (photos that don't belong to any existing donation)
    func cleanupOrphanedPhotos(existingDonations: [DonationItem]) {
        let allStoredPhotoFilenames = getAllStoredPhotoFilenames()
        let usedPhotoFilenames = Set(existingDonations.flatMap { $0.photos })
        let orphanedFilenames = allStoredPhotoFilenames.filter { !usedPhotoFilenames.contains($0) }
        
        if !orphanedFilenames.isEmpty {
            print("🧹 Cleaning up \(orphanedFilenames.count) orphaned photos")
            deletePhotos(filenames: Array(orphanedFilenames))
        }
    }
    
    /// Get all photo filenames stored on disk
    private func getAllStoredPhotoFilenames() -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: photosDirectory.path)
            return files.filter { $0.hasSuffix(".jpg") }
        } catch {
            print("❌ Failed to list photos directory: \(error)")
            return []
        }
    }
    
    /// Get the file size of stored photos in MB
    func getStorageUsage() -> Double {
        let photoFilenames = getAllStoredPhotoFilenames()
        var totalSize: Int64 = 0
        
        for filename in photoFilenames {
            let fileURL = photosDirectory.appendingPathComponent(filename)
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }
        
        return Double(totalSize) / (1024 * 1024) // Convert to MB
    }
}

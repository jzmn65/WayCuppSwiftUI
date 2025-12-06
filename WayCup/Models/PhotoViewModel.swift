//
//  PhotoViewModel.swift
//  SnacktacularUI
//
//  Created by Jazmine Singh on 11/9/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class PhotoViewModel {

    static func saveImage(photo: Photo, data: Data) async {
        // Make sure the review has an id
        var reviewID = photo.id
        if reviewID == nil {
            reviewID = UUID().uuidString
            photo.id = reviewID
        }
        
        guard let reviewID = reviewID else { return }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Generate unique filename for the photo
        let photoID = UUID().uuidString
        let path = "reviews/\(reviewID)/\(photoID).jpg"
        
        let storageref = storage.child(path)
        
        do {
            // Upload photo
            let _ = try await storageref.putDataAsync(data, metadata: metadata)
            
            // Get download URL
            let url = try await storageref.downloadURL()
            
            // Append URL to review.photoURLs
            photo.imageURLString.append(url.absoluteString)
            
            // Update Firestore review document with new photoURLs
            let db = Firestore.firestore()
            try await db.collection("photo").document(reviewID).updateData([
                "imageURLString": photo.imageURLString
            ])
            
            print("Saved photo to Storage & updated Firestore: \(url.absoluteString)")
            
        } catch {
            print("ERROR saving photo to Storage/Firestore: \(error.localizedDescription)")
        }
    }
}

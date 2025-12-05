//
//  PhotoModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit

class PhotoModel {

    static func uploadProfileImage(_ image: UIImage, for userID: String) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("ERROR: could not convert UIImage to JPEG data")
            return
        }

        let storageRef = Storage.storage().reference()
        let path = "profileImages/\(userID).jpg"       // each user gets ONE file
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        do {
            // Upload to Firebase Storage
            _ = try await fileRef.putDataAsync(imageData, metadata: metadata)

            // Get the download URL
            let url = try await fileRef.downloadURL()
            let urlString = url.absoluteString
            print("Profile photo URL: \(urlString)")

            // Update Firestore user profile
            let db = Firestore.firestore()
            try await db.collection("profiles")
                .document(userID)
                .updateData(["photoURL": urlString])

        } catch {
            print("ERROR uploading profile image: \(error.localizedDescription)")
        }
    }
}

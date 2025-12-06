//
//  PostViewModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


@MainActor

class PostViewModel {
    static func savePost(review: Review) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let newReview = review
        newReview.userID = currentUser.uid // map post to this user
        newReview.date = Date()

        do {
            let _ = try Firestore.firestore()
                .collection("reviews")
                .addDocument(from: newReview)
            print("Post saved for user \(currentUser.uid)")
        } catch {
            print("Error saving post: \(error)")
        }
    }

    static func deletePost(review: Review){
        let db = Firestore.firestore()
        guard let id = review.id else {
            print("No review.id")
            return
        }
        
        Task {
            do {
                try await db.collection("review").document(id).delete()
            } catch {
                print("could not delete")
            }
        }
    }
}



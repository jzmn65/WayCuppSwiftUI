//
//  CommentViewModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.


import SwiftUI
import Foundation
import FirebaseFirestore


@MainActor
@Observable

class CommentViewModel {
    var comments: [Comment] = []
    private let db = Firestore.firestore()
    
    func fetchComments(reviewID: String?) {
        guard let reviewID = reviewID, !reviewID.isEmpty else {
            print("Invalid reviewID, cannot fetch comments")
            return
        }

        db.collection("reviews")
            .document(reviewID)
            .collection("comments")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching comments: \(error)")
                    return
                }

                self.comments = snapshot?.documents.compactMap { document in
                    try? document.data(as: Comment.self)
                } ?? []
            }
    }

    
    func addComment(text: String, reviewID: String?, username: String) {
        guard let reviewID = reviewID, !reviewID.isEmpty else {
            print("Invalid reviewID, cannot add comment")
            return
        }

        let newComment = Comment(
            reviewID: reviewID,
            username: username,
            text: text,
            date: Date()
        )

        do {
            _ = try db.collection("reviews")
                .document(reviewID)
                .collection("comments")
                .addDocument(from: newComment)
        } catch {
            print("Error saving comment: \(error)")
        }
    }

}

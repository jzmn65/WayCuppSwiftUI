//
//  PostViewModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import Foundation
import FirebaseFirestore


@Observable
class PostViewModel {
    static func savePost(review: Review) async -> String? {
        let db = Firestore.firestore()
        
        if let id = review.id {
            do {
                try db.collection("review").document(id).setData(from: review)
                print("Data updated succesfully")
                return id
                
            } catch {
                print("Could not update data in 'review' \(error.localizedDescription)")
                return id
            }
        } else {
            do {
                let docRef = try db.collection("review").addDocument(from: review)
                print("Data added succesfully")
                return docRef.documentID
            } catch {
                print("Could not add data in 'review' \(error.localizedDescription)")
                return nil
            }
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


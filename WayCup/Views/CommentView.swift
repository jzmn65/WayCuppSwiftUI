//
//  CommentView.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/4/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct CommentView: View {
    let reviewID: String
       
       @State private var comments: [Comment] = []
       @State private var newCommentText = ""
       @State private var isLoading = false
       
       var body: some View {
           VStack {
               if isLoading {
                   ProgressView("Loading Comments...")
               } else {
                   List(comments) { comment in
                       VStack(alignment: .leading, spacing: 4) {
                           Text("@\(comment.username)")
                               .font(.headline)
                           Text(comment.text)
                           Text(comment.date.formatted(date: .abbreviated, time: .shortened))
                               .font(.caption)
                               .foregroundStyle(.secondary)
                       }
                   }
               }

               // Add a comment
               HStack {
                   TextField("Add a comment...", text: $newCommentText)
                       .textFieldStyle(.roundedBorder)
                   
                   Button("Send") {
                       Task { await submitComment() }
                   }
                   .disabled(newCommentText.isEmpty)
                   .buttonStyle(.glassProminent)
                   .tint(.darkBrown)
               }
               .padding()
           }
           .task {
               await loadComments()
           }
       }
   }

   extension CommentView {
       
       func loadComments() async {
           do {
               let db = Firestore.firestore()
               
               let snapshot = try await db.collection("reviews")
                   .document(reviewID)
                   .collection("comments")
                   .order(by: "date")
                   .getDocuments()
               
               let loaded = snapshot.documents.compactMap { try? $0.data(as: Comment.self) }
               
               await MainActor.run {
                   self.comments = loaded
                   self.isLoading = false
               }
               
           } catch {
               print("Error loading comments: \(error)")
           }
       }
       
       func submitComment() async {
           let db = Firestore.firestore()

           guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

           let comment = Comment(
               reviewID: reviewID,                               // FIX: required
               userID: Auth.auth().currentUser?.uid ?? "unknown",
               username: Auth.auth().currentUser?.email ?? "User",
               text: newCommentText,
               date: Date()
           )

           do {
               // Save to Firestore
               _ = try db.collection("reviews")
                   .document(reviewID)
                   .collection("comments")
                   .addDocument(from: comment)

               // Update UI instantly
               await MainActor.run {
                   comments.append(comment)
                   newCommentText = ""
               }

           } catch {
               print("Error adding comment: \(error)")
           }
       }
   }

#Preview {
    NavigationStack {
            CommentView(reviewID: "preview")
        }
}

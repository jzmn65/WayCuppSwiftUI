//
//  PostListView.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

struct PostListView: View {
    
    @FirestoreQuery(collectionPath: "profile") var profile: [Profile]
    @FirestoreQuery(collectionPath: "reviews") var reviews: [Review]
    @FirestoreQuery(collectionPath: "photo") var pics: [Photo]
    @State private var allProfiles: [Profile] = []
    @State private var allReviews: [Review] = []
    @State private var allPhotos: [Photo] = []
    @State private var reviewPhotos: [String: [Photo]] = [:]
    
    @State var photos: Photo
    @State private var photoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Image("coffeeCup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                        Text("WayCupp")
                            .font(.custom("Caprasimo-Regular", size: 35.0))
                            .foregroundStyle(Color.darkBrown)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Recent Activity")
                            .font(.custom("Caprasimo-Regular", size: 25.0))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    List(allReviews, id: \.id) { review in
                        Group{
                            VStack(alignment: .leading, spacing: 4) {
                                Text(review.place)
                                    .font(.headline)
                                Text(review.order)
                                    .font(.subheadline)
                                Text(review.review)
                                    .font(.body)
                                Text("⭐️ \(review.stars) - \(review.longFormattedDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.paper)
                }
            }
            .task {
                await fetchReviews()
            }
        }
    }
    func fetchReviews() async {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("reviews").getDocuments()
            let loadedReviews = snapshot.documents.compactMap { try? $0.data(as: Review.self) }
            
            await MainActor.run {
                self.allReviews = loadedReviews
            }
        } catch {
            print("Error fetching reviews: \(error)")
        }
    }
}
        
    #Preview {
//        let mockReview = [Review(
//            id: "1",
//            place: "Blue Bottle Coffee",
//            order: "Iced Latte",
//            review: "Great espresso and vibes.",
//            stars: 4,
//            latitude: 42.3601,
//            longitude: -71.0589
//        )]
//        
//        let mockProfile = [Profile(
//            id: "123",
//            username: "Jazmine",
//            photoURL: nil
//        )]
//        let mockPhotos = [Photo(
//            id: "1",
//            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/330px-Pizza-3007395.jpg",
//            reviewer: "Jazmine"
//        )]
        
        NavigationStack {
            PostListView(photos: Photo())
        }
    }

//
//  PostDisplayView.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit
import FirebaseAuth

struct PostDisplayView: View {
    @FirestoreQuery(collectionPath: "photo") var pics: [Photo]
    @State var photos: Photo
    var review: Review
    @State var profile: Profile 
    @State var commentVM = CommentViewModel()
    @State private var newCommentText = ""
    @State private var showComments = false
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false
    
    @State var liked = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let mapDimension = 750.0
    
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(latitude: review.latitude,
                                                longitude: review.longitude)
        
        return .region(
            MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: mapDimension,
                longitudinalMeters: mapDimension
            )
        )
    }
    
    var body: some View {
        ZStack{
            Color.paper
                .ignoresSafeArea()
            
            VStack {
                
                VStack{
                    HStack{
                        
                        if let photoURL = profile.photoURL, let url = URL(string: photoURL) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(profile.username) @ \(review.place)")
                            .font(.default)
                        Spacer()
                        Text("\(review.longFormattedDate)")
                            .foregroundStyle(.darkBrown)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(pics) { pic in
                                let url = URL(string: pic.imageURLString)
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 210, height: 210)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 210)
                .foregroundStyle(.darkBrown)
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack {
                        Text("Like")
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .foregroundStyle(.babyPink)
                            .onTapGesture { liked = true }
                        
                        Button {
                            showComments.toggle()
                        } label: {
                            Label("Comment", systemImage: "plus")
                        }
                        .buttonStyle(.borderless)
                        .tint(.darkBrown)
                        
                        Spacer()
                        
                        HStack {
                            ForEach(0..<review.stars, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                            }
                            ForEach(0..<(5 - review.stars), id: \.self) { _ in
                                Image(systemName: "star")
                                    .foregroundStyle(.darkBrown)
                            }
                        }
                    }
                    
                    
                    if showComments {
                        CommentView(reviewID: review.id ?? "")
                            .frame(maxWidth: .infinity)        // full width
                            .padding(.vertical, 4)
                    }
                    
                    ForEach(commentVM.comments) { comment in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(comment.username)
                                .font(.subheadline)
                                .bold()
                            
                            Text(comment.text)
                                .font(.body)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                Spacer()
                Spacer()
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order:")
                            .font(.title3)
                            .bold()
                        Text(review.order)
                            .font(.title3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Review:")
                            .font(.title3)
                            .bold()
                        Text(review.review)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading) // makes the VStack take full width
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    
                    Spacer()
                    
                }
                .multilineTextAlignment(.leading)
                Spacer()
                
            }
            .padding()
            // MARK: Map
            Map(position: .constant(mapCameraPosition)) {
                Marker(
                    review.place.isEmpty ? "Location" : review.place,
                    coordinate: CLLocationCoordinate2D(latitude: review.latitude,
                                                       longitude: review.longitude)
                )
                
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            //.frame(height: 250)
            
        }
        .onAppear {
            commentVM.fetchComments(reviewID: review.id ?? "")
            if let userID = profile.id {
                Task {
                    await loadFullProfile(for: userID)
                }
            }
        }
        
        .navigationBarBackButtonHidden()
        .task {
            $pics.path = "photo/\(photos.id ?? "")/pics"
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProfilePageView(profile: profile, locationManager: LocationManager())
                } label: {
                    Text("Done")
                }
            }
        }
        
    }
    func loadFullProfile(for userID: String) async {
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("profiles").document(userID).getDocument()
            
            await MainActor.run {
                if let name = doc.get("name") as? String {
                    profile.name = name
                }
                if let username = doc.get("username") as? String {
                    profile.username = username
                }
                if let favOrder = doc.get("favOrder") as? String {
                    profile.currentFavOrder = favOrder
                }
                if let photoURL = doc.get("photoURL") as? String {
                    profile.photoURL = photoURL
                }
            }
        } catch {
            print("Error fetching profile info: \(error)")
        }
    }
}


#Preview {
    NavigationStack {
        PostDisplayView(
            photos: Photo(id: "1", imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/330px-Pizza-3007395.jpg", reviewer: "Jazmine"),
            review: Review(
                id: "test123",
                userID: "user1",
                place: "Test Cafe",
                order: "Latte",
                review: "Really good coffee!",
                stars: 4,
                latitude: 42.3601,
                longitude: -71.0589,
                date: Date()
            ),
            profile: Profile(
                id: "user1",
                username: "TestUser",
                currentFavOrder: "Iced Latte",
                photoURL: nil
            )
        )
    }
}

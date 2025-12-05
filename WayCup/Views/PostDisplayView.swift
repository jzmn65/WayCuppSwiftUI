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


struct PostDisplayView: View {
    
    var review: Review
    var profile: Profile // Passed in from previous view
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
                        Image(systemName: profile.photoURL ?? "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30)
                            .clipShape(Circle())
                            .clipped()
                        
                        Text("\(profile.username) @ \(review.place)")
                            .font(.default)
                        Spacer()
                        Text("\(review.longFormattedDate)")
                            .foregroundStyle(.darkBrown)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if let photoURLs = review.photoURLs, !photoURLs.isEmpty {
                                // Remote photos
                                ForEach(photoURLs, id: \.self) { urlString in
                                    if let url = URL(string: urlString) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 150, height: 150)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 150, height: 150)
                                                    .cornerRadius(5)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 150, height: 150)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            } else if let imagesData = review.imagesData, !imagesData.isEmpty {
                                // Local in-memory photos
                                ForEach(imagesData, id: \.self) { data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(5)
                                    }
                                }
                            } else {
                                // Placeholder if no photos
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(5)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 170)
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
        }
        .onAppear {
            commentVM.fetchComments(reviewID: review.id ?? "")
        }
        
        // MARK: Navigation / Save Buttons
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") { dismiss() }
            }
            
        }
        
    }
    
}

#Preview {
    NavigationStack {
        PostDisplayView(
            review: Review(
                id: "test123",
                userID: "user1",
                place: "Test Cafe",
                order: "Latte",
                review: "Really good coffee!",
                stars: 4,
                latitude: 42.3601,
                longitude: -71.0589,
                photoURLs: nil,
                imagesData: nil,
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

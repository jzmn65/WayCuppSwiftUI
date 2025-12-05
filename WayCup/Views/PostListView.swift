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
    let reviews: [Review]
    var profile: Profile
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            ZStack{
                Color.paper
                    .ignoresSafeArea()
                
                VStack{
                   HStack {
                        Image("coffeeCup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                        Text("WayCupp")
                            .font(.custom("Caprasimo-Regular", size: 35.0)) //diff font
                            .foregroundStyle(Color.darkBrown)
                            .bold()
                       Spacer()
                    }
                   .padding(.horizontal)
                    Spacer()
                    Spacer()
                    Spacer()
                    HStack{
                        Text("Recent Activity")
                            .font(.custom("Caprasimo-Regular", size: 25.0))
                        Spacer()
                    }
                    .padding(.horizontal)
                    List(reviews) { review in
                        NavigationLink {
                            PostDisplayView(review: review, profile: profile)

                        } label: {
                            HStack {
                                if let urls = review.photoURLs, !urls.isEmpty {
                                    ForEach(urls, id: \.self) { urlString in
                                        if let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)

                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipped()
                                                        .cornerRadius(8)

                                                case .failure(_):
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 100)
                                                        .foregroundColor(.gray)

                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // no photos — show placeholder
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }

                                
                                Spacer()
                                
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(profile.username) @ \(review.place)")
                                        .font(.headline)
                                    Text("\(review.longFormattedDate)")
                                        .foregroundStyle(.secondary)
                                    Text(review.order)
                                        .font(.headline)
                                    
                                    
                                    
                                }
                                .padding(.vertical, 4)
                                Spacer()
                            }
                        }
                        
                        .scrollContentBackground(.hidden)
                        .listRowBackground(Color.paper)
                        
                    }
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: 2)
                            .padding(.horizontal)
                }
                
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.paper)
                
            }
        }
    }
}

#Preview {
    let mockReview = Review(
        id: "1",
        place: "Blue Bottle Coffee",
        order: "Iced Latte",
        review: "Great espresso and vibes.",
        stars: 4,
        latitude: 42.3601,
        longitude: -71.0589,
        photoURLs: nil,       // or a real URL string
    )

    let mockProfile = Profile(
        id: "123",
        username: "Jazmine",
        photoURL: nil
    )

    NavigationStack {
        PostListView(
            reviews: [mockReview],
            profile: mockProfile
        )
    }
}


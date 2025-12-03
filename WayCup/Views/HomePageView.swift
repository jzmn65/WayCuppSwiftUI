//
//  ContentView.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

struct HomePageView: View {
    @State var review: Review = Review.preview
    @State private var sheetIsPresented = false
    @State private var showPostList = false
    @State private var reviews: [Review] = []
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude)
        return .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
    }
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Spacer()
            HStack {
                Image("coffeeCup")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75)
                Text("WayCupp")
                    .font(.largeTitle) //diff font
                    .foregroundStyle(Color.darkBrown)
                    .bold()
                
                Spacer()
                
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                }
                .buttonStyle(.glassProminent)
                .tint(.coffee)
            }
            .padding()
            
            NavigationStack {
                        HStack(spacing: 20) {

                            // Add a review, then immediately show sheet
                            Button{
                                let newReview = Review(
                                    place: "Starbucks",
                                    address: "123 Main St",
                                    order: "Iced Latte",
                                    review: "Solid drink",
                                    latitude: 33.0,
                                    longitude: -96.0,
                                    likeCount: 0
                                )
                                
                                reviews.append(newReview)
                                showPostList = true
                            }label: {
                                    Label("Add Review", systemImage: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.coffee)

                            // Option to just view all reviews
                            Button{
                                showPostList = true
                            } label: {
                                Label("Cafe Lookup", systemImage: "location.magnifyingglass")
                            }
                            .buttonStyle(.bordered)
                            .tint(.darkBrown)

                        }
                        .sheet(isPresented: $showPostList) {
                            PostListView(reviews: reviews)
                }
            }

            Spacer()
            Map(position: .constant(mapCameraPosition)) {
                Marker(review.place, coordinate: CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude))
                
            }
            Button("See Posts", systemImage: "cup.and.saucer") {
                showPostList = true
            }
            .buttonStyle(.bordered)
            .tint(.darkBrown)
            
        }
        .background(.paper)
        .padding(.top)
        .padding(.bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack{
        HomePageView()
    }
}

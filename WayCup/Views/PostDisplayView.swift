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
    
    @State var review: Review = Review.preview
    @State var profile: ProfileModel = ProfileModel.preview // Passed in from previous view
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
                        Text("\(profile.username) @ \(review.place)")
                            .font(.default)
                        Spacer()
                        Text("\(review.longFormattedDate)")
                            .foregroundStyle(.darkBrown)
                    }
                    .padding(.horizontal)
                    
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                            Image(systemName: review.photoURL ?? "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
    //                            .overlay {
    //                                RoundedRectangle(cornerRadius: 5)
    //                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
    //                            }
                            Image(systemName: review.photoURL ?? "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                            Image(systemName: review.photoURL ?? "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        }
                    }
                    .foregroundStyle(.darkBrown)
                    Spacer()
                    
                    HStack{
                        Text("Like")
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .foregroundStyle(.babyPink)
                            .onTapGesture {
                                liked = true
                                
                            }
                        Button("Comment") {
                            //TODO:
                        }
                        .buttonStyle(.borderless)
                        .tint(.darkBrown)
                        Spacer()
                        Image(systemName: "star.fill")
                        Image(systemName: "star.fill")
                        Image(systemName: "star.fill")
                        Image(systemName: "star.leadinghalf.filled")
                        Image(systemName: "star")
                        Image(systemName: "star")

                    }
                    
                    Spacer()
                    VStack(alignment: .leading){
                    
                            
//                        Text("\(review.address)")
//                            .font(.subheadline)
                        Text("Order: \(review.order) @ \(review.place)")
                            .font(.subheadline)
                        Text("Review: \(review.review)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                    }
                    Spacer()
                    Spacer()
                    
                    
                    Spacer()
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
        
        // MARK: Navigation / Save Buttons
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            
        }

        
//         MARK: Photo Sheet
   
//        .fullScreenCover(isPresented: $photoSheetIsPresented) {
//            PhotoView(review: review)
//        }

    }
    
}

#Preview {
    NavigationStack {
        PostDisplayView()
    }
}

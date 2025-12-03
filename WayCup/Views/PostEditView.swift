//
//  PostView.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit


struct PostEditView: View {
    
    @State var review: Review = Review.preview        // Passed in from previous view
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false
    @State private var alertMessage = "Cannot add a Photo until you save the Spot"
    
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
                
                // MARK: Text fields
                Group {
                    TextField("Name", text: $review.place)
                        .font(.title)
                        .autocorrectionDisabled()
                    
                    TextField("Address", text: $review.address)
                        .font(.title2)
                        .autocorrectionDisabled()
                    TextField("Order", text: $review.order)
                        .font(.title2)
                        .autocorrectionDisabled()
                    TextField("Review", text: $review.review)
                        .font(.title2)
                        .autocorrectionDisabled()
                }
                .textFieldStyle(.roundedBorder)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
                .padding(.horizontal)
                Spacer()
                Spacer()
                
                
                // MARK: Photo Button
            
                Button {
                    if review.id == nil {
                        showingAlert.toggle()
                    } else {
                        photoSheetIsPresented.toggle()
                    }
                } label: {
                    Image(systemName: "camera.fill")
                    Text("Photos")
                }
                .bold()
                .buttonStyle(.borderedProminent)
                .tint(.darkBrown)
                
                Spacer()
                Spacer()
                
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    savePost()
                }
            }
        }
        
        // MARK: Alert
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        
//         MARK: Photo Sheet
   
//        .fullScreenCover(isPresented: $photoSheetIsPresented) {
//            PhotoView(review: review)
//        }

    }
    
    // MARK: Save Function
    func savePost() {
        Task {
            guard let id = await PostViewModel.savePost(review: review) else {
                print("ERROR: Saving post")
                return
            }
            review.id = id
            print("Saved post with id: \(id)")
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        PostEditView()
    }
}

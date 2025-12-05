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
import PhotosUI

struct PostEditView: View {
    
    // MARK: - Inputs
    @State var review: Review
    @State var currentProfile = Profile() // Pass this in if needed
    
    // MARK: - Map & Search
    @State var placeVM = PlaceLookUpViewModel()
    @State private var showSearchField = false
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    private let mapDimension = 750.0
    
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude)
        return .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: mapDimension, longitudinalMeters: mapDimension))
    }
    
    // MARK: - Photos
    @State private var photoSheetIsPresented = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage = Image(systemName: "photo")
    @State private var photoData = Data()
    
    // MARK: - Navigation
    @State private var navigateToPostDisplay = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // Hidden NavigationLink for programmatic navigation
                NavigationLink(
                    destination: PostDisplayView(review: review, profile: currentProfile),
                    isActive: $navigateToPostDisplay
                ) {
                    EmptyView()
                }
                
                // MARK: Cafe Text Field + Search
                TextField("Cafe", text: $review.place)
                    .font(.title)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5), lineWidth: 2))
                    .padding(.horizontal)
                
                Button {
                    showSearchField = true
                } label: {
                    Label("Cafe Lookup", systemImage: "location.magnifyingglass")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.darkBrown)
                
                if showSearchField {
                    TextField("Search cafes…", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onChange(of: searchText) { _, newValue in
                            searchTask?.cancel()
                            guard !newValue.isEmpty else {
                                placeVM.places.removeAll()
                                return
                            }
                            searchTask = Task {
                                do {
                                    try await Task.sleep(for: .milliseconds(300))
                                    if Task.isCancelled { return }
                                    try await placeVM.search(text: newValue, region: searchRegion)
                                } catch {
                                    if !Task.isCancelled {
                                        print("ERROR: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }

                    
                    List(placeVM.places) { place in
                        Text(place.name)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                review.place = place.name
                                review.latitude = place.latitude
                                review.longitude = place.longitude
                                showSearchField = false
                                searchText = ""
                                placeVM.places.removeAll()
                            }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                }
                
                // MARK: Order & Review
                Group {
                    TextField("Order", text: $review.order)
                        .font(.title2)
                        .autocorrectionDisabled()
                    TextField("Review", text: $review.review)
                        .font(.title2)
                        .autocorrectionDisabled()
                }
                .textFieldStyle(.roundedBorder)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5), lineWidth: 2))
                .padding(.horizontal)
                
                // MARK: Stars
                StarSelectionView(rating: review.stars)
                
                // MARK: Photo Picker
                Button("Choose Photos", systemImage: "camera.fill") {
                    photoSheetIsPresented = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.darkBrown)
                .padding(.horizontal)
                .photosPicker(isPresented: $photoSheetIsPresented, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let image = try? await newValue?.loadTransferable(type: Image.self) {
                            selectedImage = image
                        }
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }
                
                // MARK: Map
                Map(position: .constant(mapCameraPosition)) {
                    Marker(
                        review.place.isEmpty ? "Location" : review.place,
                        coordinate: CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude)
                    )
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .frame(height: 250)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await savePost()
                            navigateToPostDisplay = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Save Function
    func savePost() async {
        guard let id = await PostViewModel.savePost(review: review) else {
            print("ERROR: Saving post")
            return
        }
        review.id = id
        print("Saved post with id: \(id)")
    }
}

#Preview {
    NavigationStack {
        PostEditView(
            review: Review(
                id: UUID().uuidString,
                userID: "",
                place: "",
                order: "",
                review: "",
                stars: 0,
                latitude: 37.7749,
                longitude: -122.4194,
                photoURLs: nil
            )
        )
    }
}

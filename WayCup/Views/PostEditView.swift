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
    
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    @State var review: Review
    @State var currentProfile = Profile()
    @FirestoreQuery(collectionPath: "photo") var pics: [Photo]
    @State var photos: Photo
    var placeVM = PlaceLookUpViewModel()
    var postVM = PostViewModel()
    var locationManager = LocationManager()
        
    @State private var annotations: [Annotation] = []
    @State private var showSearchField = false
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion: MKCoordinateRegion
    
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
    
    init(review: Review) {
        _review = State(initialValue: review)
        _searchRegion = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        self.photos = Photo(id: "defaultID", imageURLString: "")
        
    }
    
    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // Hidden NavigationLink for programmatic navigation
                NavigationLink(
                    destination: PostDisplayView(photos: photos, review: review, profile: currentProfile),
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
                        .onChange(of: searchText) { oldValue, newValue in
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
                                annotations = [Annotation(name: place.name, address: "", coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))]
                                searchRegion.center = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                                
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
                Button {
                    photoSheetIsPresented = true
                } label: {
                    Label("Choose Photos", systemImage: "camera.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.darkBrown)
                .padding(.horizontal)
                .photosPicker(isPresented: $photoSheetIsPresented, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = Image(uiImage: uiImage)
                            photoData = data
                        }
                    }
                }
                
                // MARK: Map
                Map(coordinateRegion: $searchRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                    MapMarker(coordinate: annotation.coordinate)
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
                            await PostViewModel.savePost(review: review)
                            navigateToPostDisplay = true
                        }
                    }
                }
            }
        }
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
            )
        )
    }
}

//
//  ContentView.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MapKit

struct HomePageView: View {
    @Environment(\.dismiss) private var dismiss
    let locationManager: LocationManager
    var review: Review
    @State private var showPostList = false
    @State private var reviews: [Review] = []
    @State private var currentProfile = Profile()
    @State private var profileLoaded = false
    @State var placeVM = PlaceLookUpViewModel()
    @State private var showSearchField = false
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude)
        return .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
    }
    var body: some View {
        ZStack{
            Color.paper
                .ignoresSafeArea()
            NavigationStack{
                Spacer()
                Spacer()
                Spacer()
                VStack {
                    HStack{
                        NavigationLink {
                            if Auth.auth().currentUser != nil {
                                ProfilePageView(profile: currentProfile, locationManager: locationManager) }
                            else {
                                LoginView()
                            }
                        } label: {
                            HStack {
                                Image("coffeeCup")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75)
                                Text("WayCupp")
                                    .font(.custom("Caprasimo-Regular", size: 35.0))
                                    .foregroundStyle(Color.darkBrown) .bold()
                            }
                        }
                        Spacer()
                        Group{
                            if isLoggedIn {
                                Button("Log Out") {
                                    do {
                                        try Auth.auth().signOut()
                                        isLoggedIn = false
                                    }
                                    catch {
                                        print("Error signing out: \(error.localizedDescription)")
                                    }
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.coffee)
                            }
                            else {
                                NavigationLink(destination: LoginView()) {
                                    Text("Log In")
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.coffee)
                            }
                        }
                            .navigationBarBackButtonHidden(true)
                    }
                    .padding()
                }
                VStack{
                    HStack(spacing: 20) {
                        NavigationLink(destination: PostEditView(review: review)) {
                            Label("Quick Post", systemImage: "plus")
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.coffee) // Option to just view all reviews
                        Button{ showSearchField = true
                        } label: {
                            Label("Cafe Lookup", systemImage: "location.magnifyingglass")
                        }
                        .buttonStyle(.bordered)
                        .tint(.darkBrown)
                    }
                    if showSearchField {
                        TextField("Search cafes…", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onChange(of: searchText) { oldValue, newValue in
                                searchTask?.cancel()
                                guard !newValue.isEmpty else {
                                    placeVM.places.removeAll()
                                    return
                                }
                                searchTask = Task {
                                    do {
                                        try await Task.sleep(for: .milliseconds(300))
                                        if Task.isCancelled {
                                            return
                                        }
                                        if searchText == newValue {
                                            try await placeVM.search(text: newValue, region: searchRegion)
                                        }
                                    } catch {
                                        if !Task.isCancelled { print("ERROR: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                    }
                    if showSearchField {
                        List(placeVM.places) { place in
                            Text(place.name)
                        } //.frame(height: 200)
                        .listStyle(.plain)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                Map(position: .constant(mapCameraPosition))
                { Marker(review.place, coordinate: CLLocationCoordinate2D(latitude: review.latitude, longitude: review.longitude)) }
                
                Button("See Posts", systemImage: "cup.and.saucer") {
                    showPostList = true
                }
                .buttonStyle(.bordered)
                .tint(.darkBrown)
                .sheet(isPresented: $showPostList) {
                    NavigationStack {
                        PostListView(reviews: reviews, profile: currentProfile)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    Button("", systemImage: "chevron.down") {
                                        showPostList = false }
                                }
                            }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(.paper)
            .padding(.top)
            .padding(.bottom)
            .ignoresSafeArea()
        }
    }
    func logOut(){
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    func loadCurrentProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let doc = try await Firestore.firestore().collection("profiles").document(uid).getDocument()
            if let p = try? doc.data(as: Profile.self) {
                await MainActor.run {
                    self.currentProfile = p
                    self.profileLoaded = true
                }
            }
        } catch {
            print("Error loading profile:", error)
        }
    }
}

#Preview {
    NavigationStack {
        HomePageView(
            locationManager: LocationManager(),
            review: Review(
                id: "123",
                userID: "test",
                place: "Test Cafe",
                order: "Latte",
                review: "Great!",
                stars: 5,
                latitude: 37.7749,
                longitude: -122.4194,
                date: Date()
            )
        )
    }
}


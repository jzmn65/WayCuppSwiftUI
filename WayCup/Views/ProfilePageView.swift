//
//  ProfilePageView.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore


struct ProfilePageView: View {
    init(profile: Profile, locationManager: LocationManager) {
        self._profile = State(initialValue: profile)
        self.locationManager = locationManager
    }

    @State var profile: Profile
    let locationManager: LocationManager
    @State var reviews: [Review] = []
    @State private var postCount = 0
    @State private var profilePicture: PhotosPickerItem?
    @State private var pickerIsPresented = false
    @State private var name = ""
    @State private var favOrder = ""
    @State private var username = ""
    @State private var showingEditPopUp = false
    @State private var selectedImage: Image?
    @State private var uiImage: UIImage?
    @State private var imageData = Data()
    
    @Environment(\.dismiss) var dismiss
    
    private var userReviews: [Review] {
        reviews.filter { $0.userID == username }
    }
    
    var body: some View {
        
        ZStack{
            Color.paper
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack{
                        
                        NavigationLink(destination: HomePageView(locationManager: LocationManager(), review: Review(),placeVM: PlaceLookUpViewModel())) {
                            Image("coffeeCup")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75)
                            Text("WayCupp")
                                .font(.custom("Caprasimo-Regular", size: 35.0)) //diff font
                                .foregroundStyle(Color.darkBrown)
                                .bold()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    Divider()
                    // MARK: Top Section
                    HStack(alignment: .top) {
                        
                        // Profile photo
                        Group{
                            VStack{
                                if let selectedImage {
                                    selectedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110)
                                        .clipShape(Circle())
                                        .clipped()
                                } else {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                                
                                // PICKER BUTTON
                                Button("Choose Photo") {
                                    pickerIsPresented = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.coffee)
                                .padding()
                            }
                            .photosPicker(isPresented: $pickerIsPresented, selection: $profilePicture)
                            .onChange(of: profilePicture) { oldValue, newValue in
                                Task {
                                    do {
                                        if let swiftUIImage = try await newValue?.loadTransferable(type: Image.self) {
                                            selectedImage = swiftUIImage
                                        }
                                        
                                        guard let data = try await newValue?.loadTransferable(type: Data.self),
                                              let uiImage = UIImage(data: data),
                                              let userID = Auth.auth().currentUser?.uid else { return }
                                        
                                        // Auto upload
                                        await ProfilePhotoViewModel.uploadProfileImage(uiImage, for: userID)
                                        
                                        dismiss()
                                        
                                    } catch {
                                        print("ERROR loading selected photo: \(error.localizedDescription)")
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        
                        Spacer()
                        
                        // Middle section - Name, @username, Edit button
                        VStack(alignment: .center, spacing: 8) {
                            Spacer()
                            Text(profile.name)
                                .font(.title2)
                                .bold()
                            
                            Text("@\(profile.username)")
                                .font(.subheadline)
                                .foregroundColor(.darkBrown)
                            
                            Button("EDIT") {
                                showingEditPopUp = true
                            }
                            .alert("Edit Profile", isPresented: $showingEditPopUp) {
                                TextField("Name", text: $name)
                                TextField("Username", text: $username)
                                TextField("Favorite Order", text: $favOrder)

                                Button("Save") {
                                    Task {
                                        await updateNameInFirestore()
                                        await updateUsernameInFirestore()
                                        await updateFavOrderInFirestore()
                                    }
                                }

                                Button("Cancel", role: .cancel) { }
                            }

                            
                            .padding(.vertical, 6)
                            .padding(.horizontal, 24)
                            .background(Color(.coffee))
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                            Spacer()
                            Spacer()
                            
                            
                        }
                        Spacer()
                    }
                    
                    
                    
                    // MARK: Activity Area
                    HStack(alignment: .center){
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Favorite Order")
                                .font(.title3)
                                .bold()
                            
                            
                            Text(profile.currentFavOrder)
                                .font(.subheadline)
                                .foregroundColor(.darkBrown)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Activity")
                                .font(.title3)
                                .bold()
                            
                            Text("\(self.postCount) drinks reviewed")
                                .font(.subheadline)
                                .foregroundColor(.darkBrown)
                            
                            HStack {
                                Text("followers: \(profile.followers)")
                                Text("following: \(profile.following)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.darkBrown)
                        }
                        Spacer()
                        
                        
                        //                    Button("QUICK POST") {}
                        //                        .padding(.vertical, 8)
                        //                        .padding(.horizontal, 24)
                        //                        .background(Color(.coffee))
                        //                        .foregroundStyle(.white)
                        //                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.vertical)
                    
                    // MARK: 5 Star Orders
                    Text("5 Star Orders")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(userReviews) { review in
                                if review.stars == 5 {
                                    ReviewCardView(review: review)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    Text("Recent Orders")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(userReviews) { review in
                                ReviewCardView(review: review)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadCurrentUsername()
            loadReviews()
            Task{
                if let uid = profile.id {
                    self.postCount = await fetchPostCount(for: uid)
                }
            }
            
        }
    }
    
    // MARK: Firestore loading functions
    func loadCurrentUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { doc, _ in
            self.username = doc?.data()?["username"] as? String ?? ""
        }
    }
    
    func loadReviews() {
        Firestore.firestore().collection("reviews").getDocuments { snapshot, _ in
            Task { @MainActor in
                let loaded = snapshot?.documents.compactMap { try? $0.data(as: Review.self) } ?? []
                self.reviews = loaded
            }
        }
    }
    
    func fetchPostCount(for userID: String) async -> Int {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("reviews")
                .whereField("userID", isEqualTo: userID)
                .getDocuments()
            
            return snapshot.documents.count
        } catch {
            print("Error fetching posts: \(error)")
            return 0
        }
    }

    
    func updateNameInFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try await Firestore.firestore()
                .collection("profiles")
                .document(userId)
                .setData(["name": name], merge: true)

            profile.name = name  // update local model
        } catch {
            print("Error updating name: \(error)")
        }
    }



    
    func updateUsernameInFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

            do {
                try await Firestore.firestore()
                    .collection("profiles")
                    .document(userId)
                    .setData(["username": username], merge: true)

                profile.username = username  // update local model
            } catch {
                print("Error updating name: \(error)")
            }
        }

    func updateFavOrderInFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

            do {
                try await Firestore.firestore()
                    .collection("profiles")
                    .document(userId)
                    .setData(["favOrder": favOrder], merge: true)

                profile.currentFavOrder = favOrder  // update local model
            } catch {
                print("Error updating name: \(error)")
            }
        }
}

// MARK: Reusable Review Card
struct ReviewCardView: View {
    let review: Review
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let urls = review.photoURLs, !urls.isEmpty {
                    ForEach(urls, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(10)
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.gray)
                                case .empty:
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                } else {
                    // no photos — placeholder
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 130) // ensure proper height
    }
}


extension Profile {
    static let mock = Profile(
        id: "123",
        name: "Jazmine",
        username: "jazmine123",
        currentFavOrder: "Iced Latte",
        photoURL: nil,
        followers: 20,
        following: 18
    )
}

extension Review {
    static let mock = Review(
        id: "1",
        userID: "jazmine123",
        place: "Blue Bottle",
        order: "Mocha",
        review: "Delicious",
        stars: 5,
        latitude: 42.0,
        longitude: -71.0,
        photoURLs: nil
    )
}

#Preview {
    ProfilePageView(
        profile: .mock,
        locationManager: LocationManager()
    )
}


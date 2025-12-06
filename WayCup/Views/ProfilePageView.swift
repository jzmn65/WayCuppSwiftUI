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
        self.photos = Photo(id: "defaultID", imageURLString: "")
    }

    @State var profile: Profile
    @State var photos: Photo
    let locationManager: LocationManager
    @State var reviews: [Review] = []
    @FirestoreQuery(collectionPath: "photo") var pics: [Photo]
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
                        
                        NavigationLink(destination: HomePageView(locationManager: LocationManager(), review: Review(),photos: photos, profile: Profile(), placeVM: PlaceLookUpViewModel())) {
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
                                    ReviewCardView(review: review, photos: photos)
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
                                ReviewCardView(review: review, photos: photos)
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
        .task {
            $pics.path = "photo/\(photos.id ?? "")/pics"
        }
        .onAppear {
            loadCurrentUsername()
            loadReviews()
            Task{
                if let uid = profile.id {
                    self.postCount = await fetchPostCount(for: uid)
                }
                await loadProfileImage()
                await fetchName()
                await fetchUserame()
                await fetchProfilePhoto()
                await fetchFavOrder()
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
      
      func fetchName() async {
          guard let userID = Auth.auth().currentUser?.uid else { return }

              do {
                  let doc = try await Firestore.firestore()
                      .collection("profiles")
                      .document(userID)
                      .getDocument()

                  if let name = doc.get("name") as? String {
                      await MainActor.run {
                          self.profile.name = name
                      }
                  }

              } catch {
                  print("Error fetching name:", error)
              }
      }
      func fetchUserame() async {
          guard let userID = Auth.auth().currentUser?.uid else { return }

              do {
                  let doc = try await Firestore.firestore()
                      .collection("profiles")
                      .document(userID)
                      .getDocument()

                  if let username = doc.get("username") as? String {
                      await MainActor.run {
                          self.profile.username = username
                      }
                  }

              } catch {
                  print("Error fetching name:", error)
              }
      }
    func fetchFavOrder() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

            do {
                let doc = try await Firestore.firestore()
                    .collection("profiles")
                    .document(userID)
                    .getDocument()

                if let currentFavOrder = doc.get("currentFavOrder") as? String {
                    await MainActor.run {
                        self.profile.currentFavOrder = currentFavOrder
                    }
                }

            } catch {
                print("Error fetching currentFavOrder:", error)
            }
    }
      func fetchProfilePhoto() async {
          guard let userID = Auth.auth().currentUser?.uid else { return }

              do {
                  let doc = try await Firestore.firestore()
                      .collection("profiles")
                      .document(userID)
                      .getDocument()

                  if let profilePicture = doc.get("profilePicture") as? String {
                      await MainActor.run {
                          self.profile.photoURL = profilePicture
                      }
                  }

              } catch {
                  print("Error fetching name:", error)
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
      
      func loadProfileImage() async {
          guard let urlString = profile.photoURL,
                let url = URL(string: urlString) else { return }

          do {
              let (data, _) = try await URLSession.shared.data(from: url)
              if let uiImage = UIImage(data: data) {
                  await MainActor.run {
                      self.selectedImage = Image(uiImage: uiImage)
                  }
              }
          } catch {
              print("Error loading profile image:", error)
          }
      }


  }

// MARK: Reusable Review Card
struct ReviewCardView: View {
    let review: Review
    @State var photos: Photo
    @FirestoreQuery(collectionPath: "photo") var pics: [Photo]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
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
        .frame(height: 130) // ensure proper height
        .task {
            $pics.path = "photo/\(photos.id ?? "")/pics"
        }
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
    )
}

#Preview {
    ProfilePageView(
        profile: .mock,
        locationManager: LocationManager()
    )
}


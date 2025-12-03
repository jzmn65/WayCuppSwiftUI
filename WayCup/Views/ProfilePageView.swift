//
//  ProfilePageView.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth


struct ProfilePageView: View {
    @State var profile: ProfileModel = ProfileModel.preview
    @State private var profilePicture: PhotosPickerItem?
    @State private var pickerIsPresented = false
    @State private var selectedImage: Image?
    @State private var uiImage: UIImage?
    @State private var imageData = Data()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
            ZStack{
                Color.paper
                    .ignoresSafeArea()
                ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
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
                                        // Load Image (SwiftUI type)
                                        if let swiftUIImage = try await newValue?.loadTransferable(type: Image.self) {
                                            selectedImage = swiftUIImage
                                        }
                                        
                                        // Load Data (for Firebase upload)
                                        guard let data = try await newValue?.loadTransferable(type: Data.self) else {
                                            print("ERROR: Could not load image data")
                                            return
                                        }
                                        
                                        self.imageData = data
                                        self.uiImage = UIImage(data: data)
                                        
                                    } catch {
                                        print("ERROR loading selected photo: \(error.localizedDescription)")
                                    }
                                }
                            }
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Cancel") {
                                        dismiss()
                                    }
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Save") {
                                        Task {
                                            if let uiImage = uiImage,
                                               let userID = Auth.auth().currentUser?.uid {
                                                
                                                await ProfilePhotoViewModel.uploadProfileImage(uiImage, for: userID)
                                            }
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            .navigationTitle("Profile Picture")
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
                            
                            Button("EDIT") {}
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
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Activity")
                                .font(.title3)
                                .bold()
                            
                            Text("\(profile.drinksReviewed) drinks reviewed")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            //                            HStack {
                            //                                Text("followers: \(profile.followers)")
                            //                                Text("following: \(profile.following)")
                            //                            }
                            //                            .font(.subheadline)
                            //                            .foregroundColor(.gray)
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
                        .padding(.horizontal)
                    
                    Divider().padding(.vertical, 4)
                    
                    // MARK: Recent Orders
                    Text("Recent Orders")
                        .font(.title3)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        //                        HStack(spacing: 20) {
                        //                            ForEach(profile.recentOrderImageNames, id: \.self) { img in
                        //                                Image(img)
                        //                                    .resizable()
                        //                                    .scaledToFill()
                        //                                    .frame(width: 220, height: 240)
                        //                                    .clipped()
                        //                                    .cornerRadius(10)
                        //                                    .shadow(radius: 3)
                        //                            }
                        //                        }
                        //                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            }
    }
}

#Preview {
    ProfilePageView()
}

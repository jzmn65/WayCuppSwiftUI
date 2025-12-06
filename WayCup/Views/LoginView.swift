//
//  ContentView.swift
//  SnacktacularUI
//
//  Created by Jazmine Singh on 11/2/25.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct LoginView: View {
    enum Field {
        case email, password
    }

    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonDisabled = true
    @State private var presentSheet = false
    @FocusState private var focusField: Field?
    

    var body: some View {
        ZStack{
            Color.paper
                .ignoresSafeArea()
            VStack {
                Image("launchscreen")
                    .resizable()
                    .scaledToFit()

                VStack {
                    TextField("email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($focusField, equals: .email)
                        .onSubmit { focusField = .password }
                        .onChange(of: email) {
                            enableButtons()
                        }
                        

                    SecureField("password", text: $password)
                        .submitLabel(.done)
                        .focused($focusField, equals: .password)
                        .onSubmit { focusField = nil } // to dismiss keyboard
                        .onChange(of: password) {
                            enableButtons()
                        }
                }
                
                .textFieldStyle(.roundedBorder)
                
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
                .padding()

                HStack {
                    Button("Sign Up") { register() }
                    Button("Log In") { login() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.coffee)
                .font(.title2)
                .padding(.top)
                .disabled(buttonDisabled)
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                print("Log in successful")
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            HomePageView(locationManager: LocationManager(), review: Review(), photos: Photo(), profile: Profile(), placeVM: PlaceLookUpViewModel())
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("SIGNUP ERROR: \(error.localizedDescription)")
                alertMessage = "SIGNUP ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("Registration Success")
                presentSheet = true
            }
        }
    }

    func enableButtons() {
        let emailIsGood = email.count > 6 && email.contains("@")
        let passwordIsGood = password.count > 6
        buttonDisabled = !(emailIsGood && passwordIsGood)
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("LOGIN ERROR: \(error.localizedDescription)")
                alertMessage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("Login Success")
                presentSheet = true
            }
        }
    }
}

#Preview {
    LoginView()
}

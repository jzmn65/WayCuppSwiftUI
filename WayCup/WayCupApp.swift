//
//  WayCupApp.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import SwiftUI
import FirebaseCore



class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}


@main
struct WayCupApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    @StateObject var locationManager = LocationManager()
//    @StateObject var review = Review()
//    @StateObject var placeVM = PlaceLookUpViewModel()
//    @StateObject var profileVM = ProfileViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            HomePageView(locationManager: LocationManager(), review: Review(), photos: Photo(), profile: Profile(), placeVM: PlaceLookUpViewModel())
        }
//        
//        .environmentObject(locationManager)
//        .environmentObject(review)
//        .environmentObject(placeVM)
//        .environmentObject(profileVM)
    }
}

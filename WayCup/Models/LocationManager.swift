//
//  LocationManager.swift
//  LocationAndPlaceLookUp
//
//  Created by Jazmine Singh on 11/9/25.
//

import Foundation
import MapKit

@Observable

class LocationManager: NSObject, CLLocationManagerDelegate {
    // *** CRITICALLY IMPORTANT *** always add info.plist message for Privacy - location when in Use Usage Description
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var locationUpdated: ((CLLocation) -> Void)?
    
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getRegionAroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else { return nil}
        
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
    }
    
}

// Delegate methods that Apple has created and will call

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        locationUpdated?(newLocation)
        
        //manager.startUpdatingLocation() ** uncomment this line when you only want to get the location one, not repeatedly 
    }
    
    func locationManager(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManager authorization granted")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location manager authorization denied.")
            errorMessage = "LocationManager access denied"
            manager.startUpdatingLocation()
        case .notDetermined:
            print("LocationManager authorization not determined")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("ERROR LocationManager: \(errorMessage ?? "n/a")")
    }
    
}

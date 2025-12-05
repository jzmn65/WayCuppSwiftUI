//
//  Place.swift
//  SnacktacularUI
//
//  Created by Jazmine Singh on 11/24/25.
//

import Foundation
import MapKit
import Contacts

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    init(location: CLLocation) async {
        // Use the new MKReverseGeocodingRequest
        do {
            let request = MKReverseGeocodingRequest(location: location)
            guard let mapItem = try await request?.mapItems.first else {
                self.init(mapItem: MKMapItem())
                return
            }
            self.init(mapItem: mapItem)
        } catch {
            print("😡🌎 GEOCODING ERROR: \(error.localizedDescription)")
            self.init(mapItem: MKMapItem())
        }
    }

    
    var name: String {
        self.mapItem.name ?? ""    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.location.coordinate.latitude
    }
    
    var longitude: Double {
        self.mapItem.location.coordinate.longitude
    }
    
    var address: String {
        print("mapItem.address?.shortAddress: \(mapItem.address?.shortAddress ?? "")")
        return mapItem.address?.shortAddress ?? ""
    }
}
extension CNPostalAddress {
    var formatted: String {
        CNPostalAddressFormatter.string(from: self, style: .mailingAddress)
            .replacingOccurrences(of: "\n", with: ", ")
    }
}

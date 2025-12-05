//
//  Review.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Review: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var place: String
    var address: String
    var order: String
    var review: String
    var stars: Int
    var latitude: Double
    var longitude: Double
    var photoURLs: [String]? = nil      // Firebase URLs
    var imagesData: [Data]? = nil       // Local in-memory images
    var date: Date
    var likeCount: Int
    
    var dictionary: [String: Any] {
        return [
            "userID": userID,
            "place": place,
            "address": address,
            "order": order,
            "review": review,
            "stars": stars,
            "latitude": latitude,
            "longitude": longitude,
            "photoURLs": photoURLs as Any,
            "date": date,
            "likeCount": likeCount
        ]
    }
    
    init(
        id: String? = nil,
        userID: String = "",
        place: String = "",
        address: String = "",
        order: String = "",
        review: String = "",
        stars: Int = 0,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        photoURLs: [String]? = nil,
        imagesData: [Data]? = nil,
        date: Date = Date(),
        likeCount: Int = 0
    ) {
        self.id = id
        self.userID = userID
        self.place = place
        self.address = address
        self.order = order
        self.review = review
        self.stars = stars
        self.latitude = latitude
        self.longitude = longitude
        self.photoURLs = photoURLs
        self.imagesData = imagesData
        self.date = date
        self.likeCount = likeCount
    }
}

extension Review {
    var longFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

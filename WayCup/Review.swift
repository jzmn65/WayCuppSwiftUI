//
//  Review.swift
//  WayCup
//
//  Created by Jazmine Singh on 11/30/25.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var place = ""
    var address = ""
    var order = ""
    var review = ""
    //var stars = ""
    var latitude = 0.0
    var longitude = 0.0
    var photoURL: String?
    var date = Date()
    var likeCount = 0
    
    init(id: String? = nil, place: String = "", address: String = "", order: String = "", review: String = "", latitude: Double = 0.0, longitude: Double = 0.0, photoURL: String? = nil, date: Date = Date(), likeCount: Int) {
        self.id = id
        self.place = place
        self.address = address
        self.order = order
        self.review = review
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.date = date
        self.likeCount = likeCount
    }
    
}

extension Review {
    static var preview: Review {
        let newReview = Review(id: "1", place: "MudLeaf", address: "3100 Independence Pkwy #300, Plano, TX 75075", order: "Matcha Latte", review: "Pretty good, but way too expensive", latitude: 33.040750072004116, longitude: -96.7508581145170, photoURL: nil, date: Date(), likeCount:0)
        return newReview
    }
}

extension Review {
    var longFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

    


//
//  ProfileModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/1/25.
//

import Foundation
import FirebaseFirestore

struct Profile: Identifiable, Codable {
    @DocumentID var id: String?
        var name: String
        var username: String
        var currentFavOrder: String
        var drinksReviewed: Int
        var photoURL: String?
        var followers: Int
        var following: Int
        
        init(id: String? = nil,
             name: String = "",
             username: String = "",
             currentFavOrder: String = "",
             drinksReviewed: Int = 0,
             photoURL: String? = nil,
             followers: Int = 0,
             following: Int = 0) {
            
            self.id = id
            self.name = name
            self.username = username
            self.currentFavOrder = currentFavOrder
            self.drinksReviewed = drinksReviewed
            self.photoURL = photoURL
            self.followers = followers
            self.following = following
        }
    }

//    extension Profile {
//        static var preview: Profile {
//            Profile(
//                id: "1",
//                name: "Jazmine",
//                username: "jazminesingh",
//                currentFavOrder: "matcha latte",
//                drinksReviewed: 12,
//                photoURL: nil,
//                followers: 100,
//                following: 50
//            )
//        }
//    }

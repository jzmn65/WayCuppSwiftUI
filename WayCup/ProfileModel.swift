//
//  ProfileModel.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/1/25.
//

import Foundation
import FirebaseFirestore

struct ProfileModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name = ""
    var username = ""
    var currentFavOrder = ""
    var drinksReviewed = 0
    var photoURL: String?

    
}

extension ProfileModel {
    static var preview: ProfileModel {
        let newProfile = ProfileModel(id: "1", name: "Jazmine", username: "jazminesingh", currentFavOrder: "matcha latte", drinksReviewed: 0,photoURL: nil)
        return newProfile
    }
}


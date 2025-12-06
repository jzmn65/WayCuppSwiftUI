////
////  Photo.swift
////  SnacktacularUI
////
////  Created by Jazmine Singh on 11/9/25.
////
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" // This will hold the URL for loading the image
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    
    init(id: String? = nil, imageURLString: String = "", reviewer: String = (Auth.auth().currentUser?.email ?? "")) {
        self.id = id
        self.imageURLString = imageURLString
        self.reviewer = reviewer
    }
}



extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/330px-Pizza-3007395.jpg",
            reviewer: "little@caesars.com",
        )
        return newPhoto
    }
}

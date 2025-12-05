//
//  Comment.swift
//  WayCup
//
//  Created by Jazmine Singh on 12/3/25.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var reviewID: String
    var userID: String
    var username: String
    var text: String
    var date: Date
    
    var dictionary: [String: Any] {
        return [
            "reviewID": reviewID,
            "userID": userID,
            "username": username,
            "text": text,
            "date": date
        ]
    }
    
    init(
        id: String? = nil,
        reviewID: String = "",
        userID: String = "",
        username: String = "",
        text: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.reviewID = reviewID
        self.userID = userID
        self.username = username
        self.text = text
        self.date = date
    }
}

extension Comment {
    static var preview: Comment {
        Comment(
            id: "1",
            reviewID: "1",
            userID: "1",
            username: "Jazmine",
            text: "Love this drink!",
            date: Date()
        )
    }
}

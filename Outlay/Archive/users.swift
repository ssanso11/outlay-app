//
//  users.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/15/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Firebase
import ImageSlideshow
import Mapbox

class User: NSObject {
    var email: String?
    var name: String?
    var profilePicture: URL?
    init(email: String, name: String, profilePicture: URL) {
        self.email = email
        self.name = name
        self.profilePicture = profilePicture
    }
}
class UserWithoutEmail: NSObject {
    var name: String?
    var profilePicture: String?
    init(name: String, profilePicture: String) {
        self.name = name
        self.profilePicture = profilePicture
    }
}


struct Images {
    var mainImages: [ImageSource]?
    init(mainImages: [ImageSource]) {
        self.mainImages = mainImages
    }
}

struct Post {
    

    var postText: String!
    var postLinks: String!
    var postDate: NSNumber!
    var postId: String!
    var postLikes: Int!
    var postImageUrl: [URL]?
    var peopleWhoLikePost: [String]?
    
    init(postText: String, postLinks: String, postDate: NSNumber, postId: String, postImageUrl: [URL]) {
        self.postText = postText
        self.postLinks = postLinks
        self.postDate = postDate
        self.postId = postId
        self.postImageUrl = postImageUrl
    }
    

}




extension DataSnapshot {
    func child(_ pathString: String) -> DataSnapshot {
        return childSnapshot(forPath: pathString)
    }
    var snapshots: [DataSnapshot] {
        return children.allObjects.compactMap({ $0 as? DataSnapshot })
    }
    //var date: Date? { return double.flatMap({ $0 / 1000 }) }
    var double: Double? { return value as? Double }
    var string: String? { return value as? String }
    var url: URL? { return string.flatMap({ URL(string: $0) }) }
    var urls: [URL] { return snapshots.compactMap({ $0.url }) }
}

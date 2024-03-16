//
//  UserProfile.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

struct UserProfileResponse : Response {
    let status : String
    let profile : UserProfile
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case profile = "data"
    }
}

struct UserProfile: Codable {
    let username: String
    let profilePictureUrl: String
    let name: String
    let age: Int
    let profession: String
    let totalPostsPosted: Int
    let followersCount: Int
    let followingCount: Int
    let coverPicUrl : String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case profilePictureUrl = "profilePictureUrl"
        case name = "name"
        case age = "age"
        case profession = "profession"
        case totalPostsPosted = "totalPostsPosted"
        case followersCount = "followersCount"
        case followingCount = "followingCount"
        case coverPicUrl = "coverPicUrl"
    }
}



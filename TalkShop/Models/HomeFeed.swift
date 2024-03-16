//
//  HomeFeed.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

protocol Response : Decodable { }

struct HomeFeedResponse : Response {
    let status : String
    let response : [HomeFeedPosts]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case response = "data"
    }
}

struct HomeFeedPosts : Codable, Hashable {
    let videoPostId : String
    let thumbnailURL : String
    let videoURL : String
    let userName : String
    let name : String
    let profession : String
    let postDescription : String
    var likesCount : Int
    var isStreamLiked : Bool
    let commentsCount : Int
    let profileThumbnail : String
    
    enum CodingKeys: String, CodingKey {
        case videoPostId = "postId"
        case thumbnailURL = "thumbnail_url"
        case videoURL = "videoUrl"
        case userName = "username"
        case profession = "profession"
        case postDescription = "description"
        case likesCount = "likes"
        case commentsCount = "totalComments"
        case name = "name"
        case isStreamLiked = "isLiked"
        case profileThumbnail = "profile_thumbnail_url"
    }
}
    


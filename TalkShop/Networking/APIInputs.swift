//
//  APIInputs.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

enum APIInputs : APIConfiguration {
    case userLogin
    case getHomeFeed
    case getTrendingFeed
    case openFeedPost
    case getUserProfile(username : String)
    case getUserProfilePosts(username : String)
    
    var path: String {
        switch self {
        case .userLogin:
            return Constants.APIPath.login
            
        case .getHomeFeed:
            return Constants.APIPath.homeFeed
            
        case .getTrendingFeed:
            return Constants.APIPath.trendingFeed
            
        case .openFeedPost:
            return ""
            
        case .getUserProfile:
            return Constants.APIPath.userProfile
            
        case .getUserProfilePosts:
            return Constants.APIPath.userProfilePosts
        }
    }
    
    var method : String {
        switch self {
        default :
            return "GET"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .userLogin:
            return [
                "deviceid" : Constants.deviceid
            ]
            
        case .getUserProfile(let userName):
            return [
                "username" : userName
            ]
            
        case .getUserProfilePosts(let userName):
            return [
                "username" : userName
            ]
            
        default :
            return [:]
        }
    }
}


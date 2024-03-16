//
//  RequestGenerator.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

class RequestGenerator : APIManager {
    static var call = RequestGenerator()
    
    func userLogin() -> URLRequest {
        let request = try! asURLRequest(.userLogin)
        return request
    }
    
    func getHomeFeed () -> URLRequest {
        let request = try! asURLRequest(.getHomeFeed)
        return request
    }
    
    func getTrendingFeed () -> URLRequest {
        let request = try! asURLRequest(.getTrendingFeed)
        return request
    }
    
    func getUserProfile (userName : String) -> URLRequest {
        let request = try! asURLRequest(.getUserProfile(username: userName))
        return request
    }
    
    func getUserProfilePosts (userName : String) -> URLRequest {
        let request = try! asURLRequest(.getUserProfilePosts(username: userName))
        return request
        
    }
    
    /// It will generate the baseURL and will be passed for construction of URL
    /// - Parameter apiInput: which type of API input it is
    /// - Returns: it returns the URLRequest
    func asURLRequest(_ apiInput : APIInputs) throws -> URLRequest {
        var baseURLString : String
        
        switch apiInput {
        case .userLogin,
                .getHomeFeed,
                .getUserProfile,
                .getUserProfilePosts,
                .getTrendingFeed:
            baseURLString = APIManager.baseSocialURL
            
        default:
            baseURLString = APIManager.baseSocialURL
        }
        
        return try constructURLRequest(with: baseURLString, apiInput: apiInput)
    }
}

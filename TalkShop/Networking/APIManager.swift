//
//  APIManager.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

typealias APIResult<T> = Swift.Result<T, Error>

class APIManager {
    typealias CompletionHandler<T> = ((APIResult<T>) -> Void)

    static let baseSocialURL  = "\(TalkShopConfig.APIBaseURL)/\(Constants.APIPath.social)"
    
    /// Login
    static func login<T: Response>(completion: @escaping CompletionHandler<T>) {
        let urlRequest = RequestGenerator.call.userLogin()
        RequestManager.send.startRequest(request: urlRequest, type: T.self, completion: completion)
    }
    
    /// Home feed
    static func homeFeed<T: Response>(completion: @escaping CompletionHandler<T>) {
        let urlRequest = RequestGenerator.call.getHomeFeed()
        RequestManager.send.startRequest(request: urlRequest, type: T.self, completion: completion)
    }
    
    static func trendingFeed<T: Response>(completion: @escaping CompletionHandler<T>) {
        let urlRequest = RequestGenerator.call.getTrendingFeed()
        RequestManager.send.startRequest(request: urlRequest, type: T.self, completion: completion)
    }
    
    /// User Profile
    static func userProfile<T: Response>(username : String, completion: @escaping CompletionHandler<T>) {
        let urlRequest = RequestGenerator.call.getUserProfile(userName: username)
        RequestManager.send.startRequest(request: urlRequest, type: T.self, completion: completion)
    }
    
    static func userProfilePosts<T: Response>(username : String, completion: @escaping CompletionHandler<T>) {
        let urlRequest = RequestGenerator.call.getUserProfilePosts(userName: username)
        RequestManager.send.startRequest(request: urlRequest, type: T.self, completion: completion)
    }
    
    
    /// Constructing URL, based on parameter it will append query paramter also
    /// - Parameters:
    ///   - baseURL: baseURL like root url of the API
    ///   - apiInput: which APIInput has been requested
    /// - Returns: It will return URLRequest
    func constructURLRequest(with baseURL : String, apiInput : APIInputs) throws -> URLRequest {
        let urlWithPathString = baseURL.appending(apiInput.path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var components = URLComponents(string: urlWithPathString ?? "")
        
        if let parameters = apiInput.parameters, !parameters.isEmpty {
            components?.queryItems = parameters.map{ URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = components?.url else {
            return URLRequest(url: URL(string: TalkShopConfig.APIBaseURL)!)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = apiInput.method
        
        return urlRequest
    }
}












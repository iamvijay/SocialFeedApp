//
//  LoginResponse.swift
//  TalkShop
//
//  Created by V!jay on 16/03/24.
//

import Foundation

struct LoginResponse : Response {
    let status : String
    let loginInfo : UserLogin
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case loginInfo = "data"
    }
}

struct UserLogin: Codable {
    let username: String
    let profilePictureUrl: String
    let name: String
    let age: Int
    let profession: String
    let coverPicUrl : String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case profilePictureUrl = "profilePictureUrl"
        case name = "name"
        case age = "age"
        case profession = "profession"
        case coverPicUrl = "coverPicUrl"
    }
}

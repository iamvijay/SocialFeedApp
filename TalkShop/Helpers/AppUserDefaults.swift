//
//  AppUserDefaults.swift
//  TalkShop
//
//  Created by V!jay on 16/03/24.
//

import Foundation

struct AppUserDefaults {
    static func saveValue(_ value: Any?, forKey key: AppUserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.keyValue)
    }
    
    static func deleteValue(forKey key: AppUserDefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.keyValue)
    }
    
    static func boolean(forKey key: AppUserDefaultsKey) -> Bool {
        UserDefaults.standard.bool(forKey: key.keyValue)
    }
    
    static func string(forKey key: AppUserDefaultsKey) -> String {
        UserDefaults.standard.string(forKey: key.keyValue) ?? ""
    }
    
    static func integer(forKey key: AppUserDefaultsKey) -> Int {
        if UserDefaults.standard.object(forKey: key.keyValue) == nil {
            return 0
        }
        return UserDefaults.standard.integer(forKey: key.keyValue)
    }
}

enum AppUserDefaultsKey {
    case profileName
    case profileUserName
    case userAge
    case userProfession
    case profileImageThumbnail
    case profileCoverImageThumbnail
    
    var keyValue: String {
        let key: String
        switch self {
        case .profileName: key = "name"
        case .profileUserName: key = "userName"
        case .userAge: key = "age"
        case .userProfession: key = "profession"
        case .profileImageThumbnail: key = "profileThumbnail"
        case .profileCoverImageThumbnail: key = "profileCoverPic"
        }
        return key
    }
}

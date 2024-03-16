//
//  Utils.swift
//  TalkShop
//
//  Created by V!jay on 16/03/24.
//

import Foundation
import UIKit

struct Utils {
    static var name : String {
        AppUserDefaults.string(forKey: .profileName)
    }
    
    static var userName : String {
        AppUserDefaults.string(forKey: .profileUserName)
    }
    
    static var profileImage : String {
        AppUserDefaults.string(forKey: .profileImageThumbnail)
    }
    
    static var coverPicUrl : String {
        AppUserDefaults.string(forKey: .profileCoverImageThumbnail)
    }
    
    static var age : Int {
        AppUserDefaults.integer(forKey: .userAge)
    }
    
    static var profession : String {
        AppUserDefaults.string(forKey: .userProfession)
    }
}



//
//  StringExtension.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation


extension String {
    func getImagePathForFileURL () -> String {
        let imageURLStr = self
        
        if let imageURL = URL(string: imageURLStr) {
            let component = imageURL.pathComponents
            let path = "\(component.last ?? "cacheImage")-\(component.prefix(component.count-1).last ?? "image")"
            return path
        }
        
        return "cacheImage-image"
    }
}


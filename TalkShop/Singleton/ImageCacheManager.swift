//
//  ImageCacheManager.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation
import UIKit

class ImageCacheManager {
    fileprivate let logsEnabled = false
    
    static let shared = ImageCacheManager()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private let fileManager = FileManager.default
    private let cacheDirectory : URL
    
    /// Creating a folder to store image on the app memory
    /// This will allow to store the image and retreive when there is no resource in cache memory
    private init() {
        if let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("ImageCache") {
            cacheDirectory = cacheDirectoryURL
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } else {
            cacheDirectory = FileManager.default.temporaryDirectory
        }
    }
    
    
    /// This function is to cache the image it will be store both in cache and app storage
    /// - Parameters:
    ///   - image: Image we are going to cache
    ///   - urlString: urlString the image key will be used to retrieve the UIImage
    func cacheImage(image: UIImage, for urlString: String) {
        let fileName = urlString.getImagePathForFileURL()
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            printLogs(from: "File already exists")
        }
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .withoutOverwriting)
        }
        
        imageCache.setObject(image, forKey: urlString as NSString)
    }
    
    
    /// Gettinga cached image from the memory, initally from cache memiory if it is not there will get from app storage
    /// - Parameter urlString: urlString is the key to match
    /// - Returns: Returns the Uiimage
    func getCachedImage(for urlString: String) -> UIImage? {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            printLogs(from: "From catch")
            return cachedImage
        }
        
        let fileName = urlString.getImagePathForFileURL()
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        guard let imageData = try? Data(contentsOf: fileURL), let imageCached = UIImage(data: imageData) else {
            printLogs(from: "failed to load")
            return nil
        }
        
        imageCache.setObject(imageCached, forKey: urlString as NSString)
        printLogs(from: "From disk")
        return imageCached
    }
}

extension ImageCacheManager {
    func printLogs(from message : String) {
        if logsEnabled {
            print(message)
        }
    }
}

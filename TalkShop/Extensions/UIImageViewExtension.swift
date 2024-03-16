//
//  UIImageViewExtension.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    private static var taskKey : Int = 0
    
    private var currentTask : URLSessionDataTask? {
        get{ objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionDataTask }
        set{ objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    
    func loadImageWithURL(from urlString : String) {
        currentTask?.cancel()   // Cancel any existing task
        
        // Set placeholder image
        self.image = UIImage(named: "placeholder-image.jpeg")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        if let cachedImage = ImageCacheManager.shared.getCachedImage(for: urlString) {
            self.image = cachedImage        // Use cached image if available
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, respomse, error in
            guard let imageData = data, error == nil, let downloadedImage = UIImage(data: imageData) else {
                return
            }

            // Set downloaded image and cache the image
            ImageCacheManager.shared.cacheImage(image: downloadedImage, for: urlString)
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }
        
        currentTask = task
        currentTask?.resume()
    }
}

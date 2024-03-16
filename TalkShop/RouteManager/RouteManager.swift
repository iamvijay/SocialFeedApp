//
//  RouteManager.swift
//  TalkShop
//
//  Created by V!jay on 14/03/24.
//

import Foundation
import UIKit

class RouteManager {
    static var shared = RouteManager()
    
    func openFeedPostDetailView(from VC : UIViewController, homeFeed : HomeFeedPosts) {
        let detailViewController = FeedPostDetailViewController.initNib()
        detailViewController.homeFeedPost = homeFeed
        VC.present(detailViewController, animated: true)
    }
    
    func openUserProfileDetailView(from VC : UIViewController) {
        let detailViewController = UserProfileViewController.initNib()
        VC.present(detailViewController, animated: true)
    }
}

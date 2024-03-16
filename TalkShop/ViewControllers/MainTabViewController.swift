//
//  MainTabViewController.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import UIKit

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        self.tabBar.tintColor = .white
        
        //remove top line
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemMaterialDark) // here you can change blur style
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(origin: tabBar.bounds.origin, size: CGSize(width: tabBar.bounds.width, height: 100))
        blurView.autoresizingMask = .flexibleWidth
        tabBar.insertSubview(blurView, at: 0)
        
        loadUserProfileAPI()
    }
    
    //Load user profile API
    func loadUserProfileAPI () {
        APIManager.login { (response: APIResult<LoginResponse>) in
            switch response {
            case .success(let loginResponse):
                self.handleResponse(profile: loginResponse)
                break
            case .failure(_):
                break
            }
        }
    }
    
    //Store user info in local storage
    private func handleResponse(profile : LoginResponse) {
        AppUserDefaults.saveValue(profile.loginInfo.name, forKey: .profileName)
        AppUserDefaults.saveValue(profile.loginInfo.username, forKey: .profileUserName)
        AppUserDefaults.saveValue(profile.loginInfo.age, forKey: .userAge)
        AppUserDefaults.saveValue(profile.loginInfo.profession, forKey: .userProfession)
        AppUserDefaults.saveValue(profile.loginInfo.profilePictureUrl, forKey: .profileImageThumbnail)
        AppUserDefaults.saveValue(profile.loginInfo.coverPicUrl, forKey: .profileCoverImageThumbnail)
    }
}

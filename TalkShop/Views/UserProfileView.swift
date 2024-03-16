//
//  UserProfileView.swift
//  TalkShop
//
//  Created by V!jay on 15/03/24.
//

import UIKit

class UserProfileView: UIView {
    // MARK: - IBOutlets
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ageProfessionDetails: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postsCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var coverPicImageView: UIImageView!
    @IBOutlet weak var stackVIewHeight: NSLayoutConstraint!
    @IBOutlet weak var userDataInfoStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
}

// MARK: - Configuration - UI
extension UserProfileView {
    private func loadNib() {
        Bundle.main.loadNibNamed("UserProfileView", owner: self)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupUI () {
        self.NameLabel.text = Utils.name
        self.userNameLabel.text = "@\(Utils.userName)"
        self.ageProfessionDetails.text = "\(Utils.age), \(Utils.profession)."
       
        self.profileImageView.loadImageWithURL(from: Utils.profileImage)
        self.coverPicImageView.loadImageWithURL(from: Utils.coverPicUrl)
    }
    
    func setUserProfileData (profile : UserProfile) {
        DispatchQueue.main.async {
            self.userDataInfoStackView.isHidden = false
            self.postsCount.text = "\(profile.totalPostsPosted)"
            self.followersCount.text = "\(profile.followersCount)"
            self.followingCount.text = "\(profile.followingCount)"
        }
    }
}

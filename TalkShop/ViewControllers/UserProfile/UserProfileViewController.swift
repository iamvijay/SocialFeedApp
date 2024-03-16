//
//  UserProfileViewController.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import UIKit

class UserProfileViewController: UIViewController {
    deinit {
        logDeinit()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var userProfileContainerView: UIView!
    @IBOutlet weak var userProfileHeaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerProfileImage: UIImageView!
    @IBOutlet weak var headerProfileName: UILabel!
    @IBOutlet weak var userProfileHeader: UIView!
    
    // MARK: - Properties
    /// Indicates if the current view is visible to the user. This flag helps manage operations based on the view's visibility, such as playing or pausing media content.
    private var isViewVisible : Bool = true
    var userProfile : UserProfile?
    var headerView : UserProfileView!

    private var topConstant : CGFloat = 0.0
    
    // MARK: - UI Components
    lazy var acitivityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 10
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.backgroundColor = .black
        indicator.startAnimating()
        return indicator
    }()
    
    lazy var userProfileCloseButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "ic-close_arrow"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeUserProfile), for: .touchUpInside)
        return button
    }()
    
    /// The table view displaying the feed. Configured based on the current screen type.
    private lazy var userPostFeedTable: FeedTableView = {
        let tableView = FeedTableView(frame: UIScreen.main.bounds, screenType: .userProfile)
        tableView.feedDelegate = self
        tableView.scrollViewDelegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Setup Methods
/// Configures the initial UI elements and fetches user profile data.
extension UserProfileViewController {
    private func setupView () {
        self.view.addSubview(userProfileCloseButton)
        self.view.addSubview(acitivityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            acitivityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            acitivityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            acitivityIndicator.widthAnchor.constraint(equalToConstant: 100),
            acitivityIndicator.heightAnchor.constraint(equalToConstant: 100),
            
            userProfileCloseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 33),
            userProfileCloseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            userProfileCloseButton.widthAnchor.constraint(equalToConstant: 60),
            userProfileCloseButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        topConstant = userProfileHeaderTopConstraint.constant
        
        loadUserInfo()
        self.userProfileContainerView.addSubview(userPostFeedTable)
    }
    
    /// Fetches and displays the user's profile data.
    func loadUserInfo() {
        self.setupUI()
        
        APIManager.userProfile(username: Utils.userName) { (response: APIResult<UserProfileResponse>) in
            self.stopAnimating()
            switch response {
            case .success(let userProfileResponse):
                self.userProfile = userProfileResponse.profile
                self.headerView?.setUserProfileData(profile: userProfileResponse.profile)
                break
            case .failure(_):
                break
            }
        }
    }
    
    /// Sets up the UI based on the fetched user profile data.
    private func setupUI () {
        DispatchQueue.main.async {
            self.headerProfileImage.loadImageWithURL(from: Utils.profileImage)
            self.headerProfileName.text = "@\(Utils.userName)"
            
            // Setup the profile header view
            self.headerView = UserProfileView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 330))
            self.headerView.setupUI()
            self.headerView.backgroundColor = .clear
            self.userPostFeedTable.tableHeaderView = self.headerView
        }
    }
    
    // MARK: - Actions
    /// Closes the user profile view.
    @objc
    private func closeUserProfile() {
        DispatchQueue.main.async {
            self.userProfileHeader.isHidden = true
            self.userPostFeedTable.removeFromSuperview()
            self.dismiss(animated: true)
        }
    }
    
    func stopAnimating () {
        DispatchQueue.main.async {
            self.acitivityIndicator.stopAnimating()
        }
    }
}

// MARK: - FeedPostDelegate
extension UserProfileViewController : FeedPostDelegate {
    /// Handles user interaction with a feed card.
    /// Opens the detail view for the selected post.
    /// - Parameter post: The `HomeFeedPosts` object that was selected
    func didFeedCardClick(post: HomeFeedPosts) {
        RouteManager.shared.openFeedPostDetailView(from: self, homeFeed: post)
    }
    
    /// Called when the feed request successfully completes.
    /// This method hides any error views and stops the loader animation.
    func didFeedRequestSuccess() {
        //Not used
    }
    
    /// Called when the feed request fails.
    /// This method shows an error view and stops the loader animation.
    func didFeedRequestFailed() {
        //Not used
    }
}

extension UserProfileViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        userPostFeedTable.updatePlayerStatus(isPlayPlayer: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewVisible = false
        userPostFeedTable.updatePlayerStatus(isPlayPlayer: false)
    }
}

// MARK: - UIScrollViewDelegate
extension UserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        userProfileHeader.isHidden = false
        
        // Adjusts the profile header's top constraint based on scroll position
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 130 {
            userProfileHeaderTopConstraint.constant = topConstant + scrollView.contentOffset.y
        }
    }
}

// MARK: - UI Customization
extension UserProfileViewController {
   override var prefersStatusBarHidden: Bool {
        return true
    }
}

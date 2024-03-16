//
//  BaseViewController.swift
//  TalkShop
//
//  Created by V!jay on 16/03/24.
//

import UIKit

/// `BaseViewController` serves as a foundational class for view controllers that manage a feed table view along with user interaction, loading states, and navigation.

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    /// Indicates if the current view is visible to the user. This flag helps manage operations based on the view's visibility, such as playing or pausing media content.
    private var isViewVisible : Bool = true
    
    private lazy var acitivityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 10
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.backgroundColor = .black
        indicator.startAnimating()
        return indicator
    }()
    
    /// Button that allows users to navigate to their profile. Configured with custom appearance and action.
    private lazy var userProfileButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(openUserProfile), for: .touchUpInside)
        
        // Create UIImageView and add it as a subview of the button
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        button.addSubview(imageView)
        
        // Set constraints for the image view
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: button.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        
        // Load image from URL asynchronously
        imageView.loadImageWithURL(from: Utils.profileImage)
        return button
    }()
    
    /// The table view displaying the feed. Configured based on the current screen type.
    private lazy var feedTableView: FeedTableView = {
        let tableView = FeedTableView(frame: view.frame, screenType: screenType)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.feedDelegate = self
        return tableView
    }()
    
    private(set) lazy var errorView: EmptyView = {
        let view = EmptyView(frame: self.view.frame)
        view.isHidden = true
        return view
    }()
    
    private var screenType : ScreenName = .homeFeed
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupNotificationObservers()
    }
}

extension BaseViewController {
    private func setupView() {
        /// Configures the view by adding subviews and setting up constraints.
        screenType = type(of: self) == TrendingViewController.self ? .trendingFeed : .homeFeed
        
        self.view.addSubview(feedTableView)
        self.view.addSubview(userProfileButton)
        self.view.addSubview(acitivityIndicator)
        self.view.addSubview(errorView)

        NSLayoutConstraint.activate([
            userProfileButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 45),
            userProfileButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            userProfileButton.widthAnchor.constraint(equalToConstant: 60),
            userProfileButton.heightAnchor.constraint(equalToConstant: 60),
            
            acitivityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            acitivityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            acitivityIndicator.widthAnchor.constraint(equalToConstant: 100),
            acitivityIndicator.heightAnchor.constraint(equalToConstant: 100),
            
            feedTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            feedTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            feedTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            feedTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        ])
        
        hideErrorView()
    }
    
    /// Sets up notification observers for application lifecycle events, specifically for backgrounding and foregrounding actions.
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerStatusUpdate), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStatusUpdate), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// Updates the player's status based on the application's lifecycle state. Pauses when entering background and resumes upon return.
    @objc
    private func playerStatusUpdate(notification: Notification) {
        if isViewVisible {
            if notification.name == UIApplication.didEnterBackgroundNotification {
                feedTableView.updatePlayerStatus(isPlayPlayer: false)
            } else {
                feedTableView.updatePlayerStatus(isPlayPlayer: true)
            }
        }
    }
    
    @objc
    private func openUserProfile() {
        DispatchQueue.main.async {
            RouteManager.shared.openUserProfileDetailView(from: self)
        }
    }
    
    func showErrorView() {
        errorView.isHidden = false
    }

    func hideErrorView() {
        errorView.isHidden = true
    }
    
    func setActivityIndicator(isAnimating: Bool) {
        isAnimating ? acitivityIndicator.startAnimating() : acitivityIndicator.stopAnimating()
        acitivityIndicator.isHidden = !isAnimating
    }
}


extension BaseViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewVisible = true
        feedTableView.updatePlayerStatus(isPlayPlayer: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewVisible = false
        feedTableView.updatePlayerStatus(isPlayPlayer: false)
    }
}

// MARK: - FeedPostDelegate
extension BaseViewController : FeedPostDelegate {
    /// Handles user interaction with a feed card.
    /// Opens the detail view for the selected post.
    /// - Parameter post: The `HomeFeedPosts` object that was selected
    func didFeedCardClick(post : HomeFeedPosts) {
        RouteManager.shared.openFeedPostDetailView(from: self, homeFeed: post)
    }
    
    /// Called when the feed request successfully completes.
    /// This method hides any error views and stops the loader animation.
    func didFeedRequestSuccess() {
        DispatchQueue.main.async {
            self.hideErrorView()
            self.setActivityIndicator(isAnimating: false)
        }
    }
    
    /// Called when the feed request fails.
    /// This method shows an error view and stops the loader animation.
    func didFeedRequestFailed() {
        DispatchQueue.main.async {
            self.showErrorView()
            self.setActivityIndicator(isAnimating: false)
        }
    }
}

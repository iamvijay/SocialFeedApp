//
//  FeedPostDetailViewController.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import UIKit

class FeedPostDetailViewController: UIViewController {
    deinit {
        NotificationCenter.default.removeObserver(self,name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self,name: UIApplication.willEnterForegroundNotification, object: nil)
        
        logDeinit()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postInteractionStackVIew: UIStackView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Properties
    var homeFeedPost : HomeFeedPosts! = nil
    private var streamContainerView : StreamPlayer!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNotificationCenterObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
    }
    
    // MARK: - Actions
    @IBAction func closePostDetail(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func likeUnlikeStream(_ sender: Any) {
        guard var post = homeFeedPost else { return }
        
        post.isStreamLiked.toggle()
        homeFeedPost?.isStreamLiked = post.isStreamLiked
        let likeImageName = post.isStreamLiked ? "ic_stream_likes" : "ic_stream_unlikes"
        likeButton.setBackgroundImage(UIImage(named: likeImageName), for: .normal)
        
        let likeCountChange = post.isStreamLiked ? 1 : -1
        homeFeedPost.likesCount += likeCountChange
        self.likesCountLabel.text = "\(homeFeedPost.likesCount)"
    }
    
    @IBAction func shareStream(_ sender: Any) {
        guard let post = homeFeedPost else { return }
        
        DispatchQueue.main.async {
            let textToShare = "Hey i am \(post.name)-\(post.postDescription) \n \n \(post.videoURL)"
            
            let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            // Exclude some activity types from the list
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Setup
extension FeedPostDetailViewController {
    private func setupView() {
        guard let post = homeFeedPost else { return }
        
        //Set ui
        postInteractionStackVIew.isHidden = false
        
        userName.text = "@\(post.userName)"
        profileName.text = post.name
        postDescription.text = post.postDescription
        likesCountLabel.text = "\(post.likesCount)"
        
        userProfileImage.loadImageWithURL(from: post.profileThumbnail)
        let likeImageName = post.isStreamLiked ? "ic_stream_likes" : "ic_stream_unlikes"
        likeButton.setBackgroundImage(UIImage(named: likeImageName), for: .normal)
        
        streamContainerView = StreamPlayer(frame: self.playerView.bounds, streamingUrl: post.videoURL, streamedScreen: .detailView)
        streamContainerView.backgroundColor = .clear
        self.playerView.addSubview(streamContainerView)
    }
    
    // Adds observers for application lifecycle notifications to pause/resume video playback appropriately.
    private func setupNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerStatusUpdate), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStatusUpdate), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Notification Handling
    /// Updates the player's playback status based on the app's foreground/background state.
    @objc
    private func playerStatusUpdate () {
        if streamContainerView.feedPlayer?.rate == 0 {
            streamContainerView?.feedPlayer?.play()
        } else {
            streamContainerView?.feedPlayer?.pause()
        }
    }
}

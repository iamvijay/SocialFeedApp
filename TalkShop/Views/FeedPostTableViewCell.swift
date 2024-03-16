//
//  FeedPostTableViewCell.swift
//  TalkShop
//
//  Created by V!jay on 14/03/24.
//

import UIKit

class FeedPostTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var likesButton: UIButton!
    
    // MARK: - Properties
    var isAlreadyStreaming = false
    var feedPostUIUse : HomeFeedPosts?
    
    var feedPlayerView : StreamPlayer!
    
    // MARK: - Cell Lifecycle
    override func prepareForReuse() {
        isAlreadyStreaming = false
        self.videoContainerView.isHidden = true
        
       // feedPlayerView = nil
    }
    
    // MARK: - User Interactions
    @IBAction func streamLiked(_ sender: Any) {
        guard var post = feedPostUIUse else { return }
        
        post.isStreamLiked.toggle()
        self.feedPostUIUse?.isStreamLiked = post.isStreamLiked
        let likeImage = post.isStreamLiked ?  UIImage(named: "ic_stream_likes") : UIImage(named: "like-ic")
        self.likesButton.setBackgroundImage(likeImage, for: .normal)
        
        let likeCountChange = post.isStreamLiked ? 1 : -1
        feedPostUIUse?.likesCount += likeCountChange
        self.likesCount.text = "\(feedPostUIUse?.likesCount ?? 0)"
    }
    
    // MARK: - Configuration
    func updateFeedCellPost (homeFeedRes post : HomeFeedPosts) {
        nameLabel.text = post.name
        userNameLabel.text = " @\(post.userName.lowercased())"
        professionLabel.text = post.profession
        likesCount.text = "\(post.likesCount)"
        commentsCount.text = "\(post.commentsCount)"
        postDescription.text = post.postDescription
       
        profileImage.loadImageWithURL(from: post.profileThumbnail)
        thumbnailImage.loadImageWithURL(from: post.thumbnailURL)
        
        let likeImage = post.isStreamLiked ?  UIImage(named: "ic_stream_likes") : UIImage(named: "like-ic")
        likesButton.setBackgroundImage(likeImage, for: .normal)
        
        feedPostUIUse = post
    }
    
    
    /// To play stream UI will be created and added to cell player container
    /// - Parameter feed: feed is HomeFeedPosts which will have streaming url
    func playStream (feed : HomeFeedPosts) {
        guard feedPlayerView == nil || feed.videoURL != feedPostUIUse?.videoURL else { return }

        if !isAlreadyStreaming {
            isAlreadyStreaming = true
            
            let playerFrame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width, height: videoContainerView.frame.height)
            feedPlayerView = StreamPlayer.init(frame: playerFrame, streamingUrl: feed.videoURL)
            self.videoContainerView.addSubview(feedPlayerView)
            self.videoContainerView.isHidden = false
        }
    }
    
    /// To stop stream and destroy all player related things
    func stopStream () {
        isAlreadyStreaming = false
        self.videoContainerView.isHidden = true
        
        feedPlayerView?.resetPlayer()
        feedPlayerView?.removeFromSuperview()
        feedPlayerView = nil
    }
}


//
//  FeedTableView.swift
//  TalkShop
//
//  Created by V!jay on 14/03/24.
//

import UIKit

enum ScreenName {
    case homeFeed
    case trendingFeed
    case userProfile
}

protocol FeedPostDelegate : AnyObject {
   func didFeedCardClick(post : HomeFeedPosts)
   func didFeedRequestSuccess()
   func didFeedRequestFailed()
}

class FeedTableView: UITableView {
    deinit {
        logDeinit()
    }
    
    private var feedDataSource : UITableViewDiffableDataSource<Int, HomeFeedPosts>!
    weak var feedDelegate : FeedPostDelegate?
    weak var scrollViewDelegate : UIScrollViewDelegate?
    private var previouslyVisibleIndexPath : IndexPath?
    private var currentVisibleIndexPath : IndexPath?
    
    private var initialIndexVideoPlaying = false
    private var currentScreen : ScreenName = .homeFeed
        
    init(frame: CGRect = CGRect(), screenType: ScreenName = .homeFeed) {
        super.init(frame: frame, style: .plain)
        currentScreen = screenType
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedTableView {
    private func setupTableView () {
        self.delegate = self
        self.backgroundColor = .clear
        self.separatorColor = .clear
        self.showsVerticalScrollIndicator = false
        
        let uiNib = UINib(nibName: "FeedPostTableViewCell", bundle: .main)
        self.register(uiNib, forCellReuseIdentifier: "feedPost")
        
        loadFeedDataSource()
        if currentScreen == .userProfile {
            loadUserPosts()
        } else {
            loadFeedVideoPost()
        }
        
        DispatchQueue.main.async {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.reloadFeed), for: .valueChanged)
            self.refreshControl?.tintColor = .gray
        }
    }
    
    
    private func loadFeedVideoPost () {
        if currentScreen == .homeFeed {
            APIManager.homeFeed { (response: APIResult<HomeFeedResponse>) in
                switch response {
                case .success(let feedResponse):
                    self.feedDelegate?.didFeedRequestSuccess()
                    self.handleResponse(response: feedResponse)
                    break
                case .failure(_):
                    self.feedDelegate?.didFeedRequestFailed()
                    break
                }
            }
            return
        }
        
        APIManager.trendingFeed { (response: APIResult<HomeFeedResponse>) in
            switch response {
            case .success(let feedResponse):
                self.feedDelegate?.didFeedRequestSuccess()
                self.handleResponse(response: feedResponse)
                break
            case .failure(_):
                self.feedDelegate?.didFeedRequestFailed()
                break
            }
        }
    }
    
    private func loadUserPosts () {
        APIManager.userProfilePosts(username: Utils.userName) { (response: APIResult<HomeFeedResponse>) in
            switch response {
            case .success(let feedResponse):
                self.handleResponse(response: feedResponse)
                break
            case .failure(_):
                break
            }
        }
    }
    
    private func handleResponse(response : HomeFeedResponse) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Int, HomeFeedPosts>()
            snapshot.appendSections([0]) // Make sure '0' is your intended section.
            snapshot.appendItems(response.response, toSection: 0)
            self.feedDataSource.apply(snapshot, animatingDifferences: false)
            self.refreshControl?.endRefreshing() // Ensure to stop the refresh control here.
        }
    }
    
    func updatePlayerStatus(isStopPlayer : Bool = false, isPlayPlayer : Bool = false) {
        if let indexPath = currentVisibleIndexPath, let cell = self.cellForRow(at: indexPath) as? FeedPostTableViewCell {
            if isStopPlayer {
                cell.feedPlayerView?.resetPlayer()
                return
            }
            if cell.isAlreadyStreaming {
                if isPlayPlayer {
                    cell.feedPlayerView?.feedPlayer?.play()
                } else {
                    cell.feedPlayerView?.feedPlayer?.pause()
                }
            }
        }
    }
    
    @objc
    private func reloadFeed() {
        DispatchQueue.main.async {
            self.updatePlayerStatus()
            
            var snapshot = self.feedDataSource.snapshot()
            snapshot.deleteAllItems()
            self.feedDataSource.apply(snapshot, animatingDifferences: false)
            
            if self.currentScreen == .userProfile {
                self.loadUserPosts()
            } else {
                self.loadFeedVideoPost()
            }
        }
    }
}

extension FeedTableView {
    func loadFeedDataSource () {
        feedDataSource = UITableViewDiffableDataSource(tableView: self){ tableView, indexPath, homeFeedPost in
            guard let videoFeedCell = tableView.dequeueReusableCell(withIdentifier: "feedPost", for: indexPath) as? FeedPostTableViewCell else {
                return UITableViewCell()
            }
            
            videoFeedCell.updateFeedCellPost(homeFeedRes: homeFeedPost)
            
            if !self.initialIndexVideoPlaying  {
                self.initalVideoStream(indexPath: indexPath, homeFeedPost : homeFeedPost)
            }
            return videoFeedCell
        }
    }
    
    private func initalVideoStream(indexPath : IndexPath, homeFeedPost : HomeFeedPosts) {
        self.initialIndexVideoPlaying = true
        self.previouslyVisibleIndexPath = indexPath
        self.currentVisibleIndexPath = indexPath
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let cell = self.cellForRow(at: indexPath) as? FeedPostTableViewCell {
                cell.playStream(feed: homeFeedPost)
            }
        }
    }
}


extension FeedTableView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let feedPost = feedDataSource.itemIdentifier(for: indexPath) {
            self.deselectRow(at: indexPath, animated: false)
            feedDelegate?.didFeedCardClick(post: feedPost)
        }
    }
}


extension FeedTableView : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let feedTable = scrollView as? UITableView else {
            return
        }
        
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
        
        let mostVisibleIndex = feedTable.visibileCellIndexPath()
        if let indexPath = mostVisibleIndex, let cell = feedTable.cellForRow(at: indexPath) as? FeedPostTableViewCell {
            self.currentVisibleIndexPath = indexPath
            if let feedPost = feedDataSource.itemIdentifier(for: indexPath) {
                if !cell.isAlreadyStreaming {
                    if let indexPath = previouslyVisibleIndexPath {
                        stopStream(indexPath: indexPath)
                    }
                }
                
                cell.playStream(feed: feedPost)
                previouslyVisibleIndexPath = indexPath
            }
        }
        
        func stopStream (indexPath : IndexPath) {
            //Stop stream
            if let cell = feedTable.cellForRow(at: indexPath) as? FeedPostTableViewCell, cell.isAlreadyStreaming {
                cell.stopStream()
            }
        }
    }
}

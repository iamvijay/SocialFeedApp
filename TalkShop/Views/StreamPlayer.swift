//
//  StreamPlayer.swift
//  TalkShop
//
//  Created by V!jay on 14/03/24.
//

import UIKit
import AVFoundation
import CallKit

enum StreamedScreen {
    case cell
    case detailView
}

class StreamPlayer: UIView {
    // Called when the StreamPlayer is deallocated
    deinit {
        resetPlayer()
        logDeinit()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var streamContainerView: UIView!
    @IBOutlet weak var watchAgainButton: UIButton!
    @IBOutlet weak var playerSeekarBar: UISlider!
    @IBOutlet weak var sliderBorderView: UIView!
    
    // MARK: - Properties
    var streamUrl : String?
    private var playerItem : AVPlayerItem!
    var feedPlayer : AVPlayer!
    var timeObserverToken: Any?
    
    private var observers: [NSKeyValueObservation] = []
    private var callObserver: CXCallObserver?
    
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var streamedScreen : StreamedScreen = .cell
        
    init(frame : CGRect, streamingUrl : String, streamedScreen : StreamedScreen = .cell) {
        super.init(frame: frame)
        self.streamedScreen = streamedScreen
        streamUrl = streamingUrl
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    // Action triggered when the user taps the watch again button
    @IBAction func watchAgain(_ sender: Any) {
        if let item = playerItem {
            item.seek(to: .zero) { _ in
                self.watchAgainButton.isHidden = true
                self.feedPlayer?.play()
            }
        }
    }
}

// MARK: - UI Setup
extension StreamPlayer {
    private func loadNib() {
        Bundle.main.loadNibNamed("StreamPlayer", owner: self)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
        setupView()
    }
    
    // Sets up the initial view configurations
    private func setupView () {
        self.backgroundColor = .clear
        
        activityIndicator.frame = self.frame
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        playerSeekarBar.minimumValue = 0
        playerSeekarBar.maximumValue = 1
        playerSeekarBar.value = 0
        
        // Add a target-action to the slider
        playerSeekarBar.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        // Attempts to configure the AVAudioSession
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        configurePlayer()
    }
    
    // Configures the AVPlayer with the stream URL
    private func configurePlayer () {
        guard let streamingUrl = streamUrl, let url = URL(string: streamingUrl) else { return }
        
        let avAsset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: avAsset)
        
        // Initialize and configure the AVPlayer
        feedPlayer = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: feedPlayer)
        playerLayer.frame = self.frame
        streamContainerView.layer.addSublayer(playerLayer)
        
        // Observe player and item properties
        if streamedScreen == .detailView {
            checkPlayerTimeObserver()
        }
        observePlayer(playerItem, playerLayer: playerLayer)
        
        feedPlayer.play()
    }
    
    // Sets up observers for updating slider value
    private func checkPlayerTimeObserver () {
        timeObserverToken = feedPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main, using: {  [weak self] time in
            guard let duration = self?.feedPlayer?.currentItem?.duration else { return }
            
            let currentTime = time.seconds
            let totalDuration = duration.seconds
            if totalDuration < 30 {
                self?.playerSeekarBar.isHidden = true
                self?.removePeriodicTime()
            } else if self?.sliderBorderView.isHidden == true && totalDuration.isNaN == false {
                self?.playerSeekarBar.isHidden = self?.streamedScreen == .cell
                self?.sliderBorderView.isHidden = self?.playerSeekarBar.isHidden == true
            }
            let progress = Float(currentTime / totalDuration)
            self?.playerSeekarBar.value = progress
        })
    }
    
    // Remove observer if duration is less than 30sec
    func removePeriodicTime() {
        if let token = timeObserverToken {
            feedPlayer?.removeTimeObserver(token)
        }
    }
    
    @objc
    /// This to detect when some drag happened on slider
    /// - Parameter slider: this will give you info about dragged position and all
    func sliderValueChanged(_ slider: UISlider) {
        guard let duration = feedPlayer?.currentItem?.duration else { return }
        let totalDuration = duration.seconds
        let timeToSeek = totalDuration * Double(slider.value)
        let time = CMTime(seconds: timeToSeek, preferredTimescale: 1)
        feedPlayer?.seek(to: time)
    }
}

// MARK: - Call Handling
extension StreamPlayer : CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        let isIncomingCall = call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false
        
        if isIncomingCall {
            // Incoming call detected, pause playback
            feedPlayer?.pause()
        } else {
            // Call ended, resume playback
            feedPlayer?.play()
        }
    }
}

// MARK: - Observers and Notifications
extension StreamPlayer {
    /// Sets up observers for the AVPlayerItem and handles playback-related notifications
    /// - Parameters:
    ///   - item: Player item will help to observe status and frame sizes
    ///   - playerLayer: To set content mode of video from based on video size
    private func observePlayer(_ item : AVPlayerItem, playerLayer: AVPlayerLayer) {
        let statusObserver = item.observe(\.status) { [weak self] (playerItem, _) in
            if playerItem.status == .readyToPlay {
                self?.activityIndicator.stopAnimating()
            }
        }
        observers.append(statusObserver)
        
        // Observe the presentation size to adjust videoGravity accordingly
        let sizeObserver = item.observe(\.presentationSize, options: [.new, .initial]) { (playerItem, change) in
            guard let size = change.newValue else { return }
            if size.width > 0 && size.height > 0 {
                DispatchQueue.main.async {
                    // Now that we have the size, determine the videoGravity
                    if size.width > size.height {
                        // If the width is greater, it's a landscape video
                        playerLayer.videoGravity = .resizeAspect
                    } else {
                        // Otherwise, it's portrait or square
                        playerLayer.videoGravity = .resizeAspectFill
                    }
                }
            }
        }
        observers.append(sizeObserver)
        
        // Add an observer for when the video finishes playing
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: item)
        
        // Observe time control status to show/hide activity indicator
        feedPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
        
        // Setup a call observer to pause/resume playback during calls
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: nil)
    }
    
    // Observe time control status to show/hide activity indicator
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(AVPlayer.timeControlStatus) else { return }
        guard let newValue = change?[.newKey] as? Int else { return }
        guard let oldStatus = AVPlayer.TimeControlStatus(rawValue: newValue) else { return }
        
        switch oldStatus {
        case .waitingToPlayAtSpecifiedRate:
            activityIndicator.startAnimating()
        case .paused, .playing:
            activityIndicator.stopAnimating()
        @unknown default:
            break
        }
    }
    
    @objc
    func finishedPlaying () {
        watchAgainButton.isHidden = false
    }
}

extension StreamPlayer {
    func resetPlayer () {

        // Remove the player layer
        if let playerLayer = streamContainerView.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) {
            playerLayer.removeFromSuperlayer()
        }
        
        // Cleanup and remove observers
        if let _ = feedPlayer {
            feedPlayer.replaceCurrentItem(with: nil)
            playerItem = nil
            feedPlayer = nil
            
            observers.forEach { observer in
                observer.invalidate()
            }
            observers.removeAll()
            
            if let token = timeObserverToken {
                feedPlayer?.removeTimeObserver(token)
            }
            
            feedPlayer?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            feedPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))

            NotificationCenter.default.removeObserver(self,name: .AVPlayerItemDidPlayToEndTime,object: feedPlayer?.currentItem)
        }
    }
}

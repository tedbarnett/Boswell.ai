//
//  AudioPlaybackViewController.swift
//  Boswell
//
//  Created by MyMac on 28/04/23.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlaybackViewController: UIViewController {

    @IBOutlet weak var viewControlsContainer: UIView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var lblCurrentAudioTime: UILabel!
    @IBOutlet weak var lblDurationLeft: UILabel!
    @IBOutlet weak var lblTotalLeftTime: UILabel!
    
    @IBOutlet weak var btnConnectToDevice: UIButton!
    @IBOutlet weak var viewConnectToDevice: UIView!
    @IBOutlet weak var btnForwardEnd: UIButton!
    @IBOutlet weak var btnBackwardEnd: UIButton!
    @IBOutlet weak var btnGoforward30: UIButton!
    @IBOutlet weak var btnGobackward30: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    var audioURL: URL!
    var playerItem:AVPlayerItem?
    var audioPlayer: AVPlayer?
    let seekDuration: Float64 = 30
    var periodicTimeObserver: Any?
    let volumeView = MPVolumeView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initPlayer()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
        self.stopPlayer()
    }
    
    // This method is called whenever an observed property changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the observed property is the player's rate property
        guard keyPath == #keyPath(AVPlayer.rate) else { return }
        
        // Make sure the object is the AVPlayer we're observing
        guard let _ = object as? AVPlayer else { return }
        
        // Get the new rate value from the change dictionary
        guard let newRate = change?[.newKey] as? Float else { return }
        
        // Update the UI based on the player's state
        if newRate == 0 {
            // Player is paused
            self.btnPlay.isSelected = false
        } else {
            // Player is playing
            self.btnPlay.isSelected = true
        }
    }
    
    func setupUI() {
        volumeView.showsVolumeSlider = false
        //volumeView.backgroundColor = .yellow
        viewControlsContainer.addSubview(volumeView)
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        volumeView.leadingAnchor.constraint(equalTo: self.viewConnectToDevice.leadingAnchor, constant: 0).isActive = true
        volumeView.trailingAnchor.constraint(equalTo: self.viewConnectToDevice.trailingAnchor, constant: 0).isActive = true
        volumeView.topAnchor.constraint(equalTo: self.viewConnectToDevice.topAnchor, constant: 0).isActive = true
        volumeView.bottomAnchor.constraint(equalTo: self.viewConnectToDevice.bottomAnchor, constant: 0).isActive = true
        self.viewControlsContainer.sendSubviewToBack(volumeView)
        
        self.viewControlsContainer.layer.masksToBounds = true
        self.viewControlsContainer.layer.cornerRadius = 10.0
        
        self.btnPlay.layer.masksToBounds = true
        self.btnPlay.layer.cornerRadius = self.btnPlay.bounds.size.width / 2
        
        self.viewContainer.layer.masksToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
    }
    
    func removeObserver() {
        if self.audioPlayer != nil && self.periodicTimeObserver != nil {
            self.audioPlayer?.removeTimeObserver(self.periodicTimeObserver!)
            self.periodicTimeObserver = nil
            self.audioPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
    }
    
    func initPlayer() {
        self.removeObserver()
        
        self.playerItem = AVPlayerItem(url: audioURL)
        self.audioPlayer = AVPlayer(playerItem: playerItem)
        self.audioPlayer!.usesExternalPlaybackWhileExternalScreenIsActive = true
        self.audioPlayer!.allowsExternalPlayback = true
        
        // Add an observer to the player's rate property to update the UI when the player's state changes
        self.audioPlayer!.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem!)
        
        // Add playback slider
        playbackSlider.minimumValue = 0
        
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        Task {
            do {
                let duration = try await self.playerItem!.asset.load(.duration)
                //let duration : CMTime = self.playerItem!.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                lblTotalLeftTime.text = self.stringFromTimeInterval(interval: seconds)
                lblDurationLeft.text =  "-" + self.stringFromTimeInterval(interval: seconds)
                
                let duration1 : CMTime = self.playerItem!.currentTime()
                let seconds1 : Float64 = CMTimeGetSeconds(duration1)
                lblCurrentAudioTime.text = self.stringFromTimeInterval(interval: seconds1)
                
                playbackSlider.maximumValue = Float(seconds)
                playbackSlider.isContinuous = true

                self.periodicTimeObserver = self.audioPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: .main, using: { time in
                    if self.audioPlayer?.status == .readyToPlay {
                        if let currentTime = self.audioPlayer?.currentTime(){
                            let time = CMTimeGetSeconds(currentTime)
                            self.playbackSlider.value = Float(time)
                            self.lblCurrentAudioTime.text = self.stringFromTimeInterval(interval: time)
                            self.lblDurationLeft.text =  "-" + self.stringFromTimeInterval(interval: seconds - time)
                        }
                    }
                })
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnShareAction(_ sender: Any) {
        let activityItem = audioURL!
        let activityVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func btnGoforward30Action(_ sender: Any) {
        if self.audioPlayer == nil { return }
        if let duration  = self.audioPlayer!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(self.audioPlayer!.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                self.audioPlayer!.seek(to: selectedTime)
            }
            self.audioPlayer?.pause()
            self.audioPlayer?.play()
            self.btnPlay.isSelected = true
        }
    }
    
    
    @IBAction func btnForwardEndAction(_ sender: Any) {
        if self.audioPlayer == nil { return }
        self.audioPlayer?.pause()
        Task {
            do  {
                let duration : CMTime = try await self.audioPlayer!.currentItem!.asset.load(.duration)
                let _ = await self.audioPlayer?.seek(to: duration, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.positiveInfinity)
                self.audioPlayer?.play()
                self.btnPlay.isSelected = true
            }
            catch let error {
                print(error)
            }
        }
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        if self.audioPlayer != nil {
            if audioPlayer?.rate == 0 {
                self.audioPlayer?.play()
                self.btnPlay.isSelected = true
            }
            else {
                self.audioPlayer?.pause()
                self.btnPlay.isSelected = false
            }
        }
        else {
            self.initPlayer()
            self.audioPlayer?.play()
            self.btnPlay.isSelected = true
        }
    }
    
    @IBAction func btnGobackward30Action(_ sender: Any) {
        if self.audioPlayer == nil { return }
        let playerCurrenTime = CMTimeGetSeconds(self.audioPlayer!.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }
        self.audioPlayer?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        self.audioPlayer?.seek(to: selectedTime)
        self.audioPlayer?.play()
        self.btnPlay.isSelected = true
    }
    
    @IBAction func btnBackwardEndAction(_ sender: Any) {
        if self.audioPlayer == nil { return }
        self.audioPlayer?.pause()
        let selectedTime: CMTime = CMTimeMake(value: 0, timescale: 1000)
        self.audioPlayer?.seek(to: selectedTime)
        self.audioPlayer?.play()
        self.btnPlay.isSelected = true
    }
    
    @IBAction func btnConnectToDeviceAction(_ sender: Any) {
        let airPlayButton = volumeView.subviews.first(where: { $0 is UIButton }) as? UIButton
        airPlayButton?.sendActions(for: .touchUpInside)
    }

    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        if self.audioPlayer == nil { return }
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        self.audioPlayer!.seek(to: targetTime)
        if self.audioPlayer!.rate == 0
        {
            self.audioPlayer?.play()
            self.btnPlay.isSelected = true
        }
    }
    
    @objc func didPlayToEnd() {
        self.audioPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1), completionHandler: { success in
            self.btnPlay.isSelected = false
        })
    }
    
    func stopPlayer() {
        if self.audioPlayer != nil {
            self.audioPlayer?.pause()
            self.audioPlayer?.replaceCurrentItem(with: nil)
            self.playerItem = nil
            self.audioPlayer = nil
            self.btnPlay.isSelected = false
        }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours != 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

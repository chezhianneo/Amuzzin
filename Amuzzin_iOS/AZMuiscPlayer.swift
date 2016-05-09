//
//  AZMuiscPlayer.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 23/03/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

extension CMTime {
    var isValid : Bool { return flags.contains(.Valid) }
}
protocol AZPlayerSliderDelegate
{
    func sliderValueChanged(value:Double,playerTime:Double)
    func setSongDetailsAfterSetup()
}

enum AZPlayModeType
{
    case Library
    case Local
    case Remote
    case AppleMusic
}

class AZMuiscPlayer: NSObject
{
    var playerAZ:AVPlayer?
    var playerMZ:MPMusicPlayerController?
    
    var arrPlayerURL:[AZPlayerItemModel]?
    var currentPlayerIndex:Int
    var isPlaying:Bool?
    var currentPlayerItem:AVPlayerItem?
    var totalValueQueue:Int?
    var delegate:AZPlayerSliderDelegate?
    var azplayerCurrentItemModel:AZPlayerItemModel
    
    var boolRepeat:Bool?
    var shuffle:Bool?
    var seekToBeforePlay:Bool?
    var totalDuration:CMTime?
    var currentMode:AZPlayModeType?
    
    //Slider
    var sliderWidth:CGFloat?
    var timeObserver:AnyObject?
    var restoreAfterScrubbingRate:Float?
    
    let kTracksKey        = "tracks"
    let kStatusKey        = "status"
    let kRateKey          = "rate"
    let kPlayableKey      = "playable"
    let kCurrentItemKey	  = "currentItem"
    let kTimedMetadataKey = "currentItem.timedMetadata"
    
    var MyStreamingMovieViewControllerRateObservationContext  = 0
    var MyStreamingMovieViewControllerCurrentItemObservationContext = 1
    var MyStreamingMovieViewControllerPlayerItemStatusObserverContext  = 2
    
    class var sharedInstance: AZMuiscPlayer
    {
        struct Static
        {
            static var instance : AZMuiscPlayer?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)
        {
            Static.instance = AZMuiscPlayer()
        }
        
        return Static.instance!
    }

    override init()
    {
        self.currentPlayerIndex = 0
        self.isPlaying = false
        self.arrPlayerURL = [AZPlayerItemModel]()
        self.azplayerCurrentItemModel = AZPlayerItemModel()
        self.totalDuration = CMTime()
        super.init()

        MPRemoteCommandCenter.sharedCommandCenter().playCommand.addTarget(self, action: #selector(MPMediaPlayback.play))
        MPRemoteCommandCenter.sharedCommandCenter().pauseCommand.addTarget(self, action: #selector(AZMuiscPlayer.pause))
        MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.addTarget(self, action: #selector(AZMuiscPlayer.previousSong))
        MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.addTarget(self, action: #selector(AZMuiscPlayer.nextSong))

    }
    
    
    func resetPlayer()
    {
        self.azplayerCurrentItemModel = self.arrPlayerURL![currentPlayerIndex]
        
        
        if let tAzplayURL = self.azplayerCurrentItemModel.avplayerURL
        {
         var azplayURL = tAzplayURL
        if let songID = self.azplayerCurrentItemModel.songID
        {
            if  songID.getCharactersForIndex(2) == "SD"
            {
                let directoryArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let directoryPath = directoryArray.first! as String
                let toArray:[AnyObject] = self.azplayerCurrentItemModel.avplayerURL!.absoluteString.componentsSeparatedByString("/")

                let azcurrentPlayerString = directoryPath + "/" + (toArray.last as! String)
                   azplayURL = NSURL(fileURLWithPath: azcurrentPlayerString.stringByRemovingPercentEncoding!)

            }

        }
        
        let avurlAssest: AVURLAsset = AVURLAsset(URL: azplayURL)
        let arrReqkeys = [kTracksKey,kPlayableKey]
        avurlAssest.loadValuesAsynchronouslyForKeys(arrReqkeys, completionHandler:
            {
                dispatch_async(dispatch_get_main_queue(),
                    {
                        self.setupDPlayer(avurlAssest, keys: arrReqkeys)
                    }
                )
                
            }
        )
        }
        else
        {
            
        }
    }
    
    func setupIpodPlayer()
    {
        
    }
    
    func setupDPlayer(asset:AVURLAsset , keys:[String])
    {
       // print(__FUNCTION__)
        
        for key in keys
        {
            var error:NSError?
            let keyStatus:AVKeyValueStatus = asset.statusOfValueForKey(key, error: &error)
            if keyStatus == AVKeyValueStatus.Failed
            {
                self.assetFailedtoPlayback(error)
                return
            }
        }
        if !asset.playable
        {
            self.assetFailedtoPlayback(nil)
            return
        }
        
        
        if self.currentPlayerItem != nil
        
        {
           self.currentPlayerItem?.removeObserver(self, forKeyPath: kStatusKey)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.currentPlayerItem)
            
        }
        
        
      currentPlayerItem = AVPlayerItem(asset: asset)
        self.currentPlayerItem?.addObserver(self, forKeyPath: kStatusKey, options: [.Initial,.New],context: &MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
        
       
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AZMuiscPlayer.playerItemEndReached), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.currentPlayerItem)
        
        if self.playerAZ == nil
        {
            playerAZ = AVPlayer(playerItem: self.currentPlayerItem!)
            
            self.playerAZ?.addObserver(self, forKeyPath: kCurrentItemKey, options: [.Initial,.New], context: &MyStreamingMovieViewControllerCurrentItemObservationContext)
            
            self.playerAZ?.addObserver(self, forKeyPath: kRateKey, options: [.Initial,.New], context: &MyStreamingMovieViewControllerRateObservationContext)

        }
        
        if self.playerAZ?.currentItem != self.currentPlayerItem
        {
            
            self.playerAZ?.replaceCurrentItemWithPlayerItem(self.currentPlayerItem)
        }
        self.delegate?.setSongDetailsAfterSetup()

        let image = AZPlayerUtils.getImageForSongModel(self.azplayerCurrentItemModel)
        let artwork  = MPMediaItemArtwork(image:image)
        
        self.play()
        var songInfo:[NSObject:AnyObject] = [NSObject:AnyObject]()
        songInfo[MPMediaItemPropertyTitle] = self.azplayerCurrentItemModel.songTitle
        songInfo[MPMediaItemPropertyAlbumTitle] = self.azplayerCurrentItemModel.albumName
        songInfo[MPMediaItemPropertyArtwork] = artwork
        songInfo[MPMediaItemPropertyPlaybackDuration] =  CMTimeGetSeconds(playerItemDuration())
        songInfo[MPMediaItemPropertyArtist] = self.azplayerCurrentItemModel.artists
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo as? [String:AnyObject]

    }
    
    

    
    func assetFailedtoPlayback(error:NSError?)
    {
        
    }
    
    func play()
    {
       // print("Playing set True")
        self.isPlaying = true
        playerAZ?.play()
        
        
    }
    
    func pause()
    {
       // print("Playing set false")

        self.isPlaying = false
        playerAZ?.pause()
    }
    
    func playerItemEndReached()
    {
      self.seekToBeforePlay = true
        self.boolRepeat = true

      if (arrPlayerURL != nil && arrPlayerURL?.count > 0)
      {
        if currentPlayerIndex != (arrPlayerURL!.count - 1)
        {
            currentPlayerIndex++
            resetPlayer()
            seekToBeforePlay = true
        }
        else if(currentPlayerIndex == (arrPlayerURL!.count - 1) && boolRepeat == true)
        {
            currentPlayerIndex = 0
            resetPlayer()
            seekToBeforePlay = true
        }
      }

    }
    
    func nextSong()
    {
        self.pause()
        if (arrPlayerURL != nil && arrPlayerURL?.count > 0)
        {
            if currentPlayerIndex != (arrPlayerURL!.count - 1)
            {
                currentPlayerIndex++
                resetPlayer()
                seekToBeforePlay = true
            }
            else if(currentPlayerIndex == (arrPlayerURL!.count - 1))
            {
                currentPlayerIndex = 0
                resetPlayer()
                seekToBeforePlay = true
            }
        }
    }
    
    func previousSong()
    {
        self.pause()

        if (arrPlayerURL != nil && arrPlayerURL?.count > 0)
        {
            if currentPlayerIndex > 0
            {
                currentPlayerIndex--
                resetPlayer()
                seekToBeforePlay = true
            }
            else if currentPlayerIndex == 0
            {
                currentPlayerIndex = arrPlayerURL!.count - 1
                resetPlayer()
                seekToBeforePlay = true
            }
        }

    }
    func removePlayerItemforIndex(index:Int)
    {
        
    }
    
    
    func syncPlayPauseButton()
    {
        
    }
    
    //MARK: Slider methods
    
    func initSliderTimings()
    {
        
        var interval:Double = 0.1
        let playerDuration:CMTime = playerItemDuration()
        
        if !playerDuration.isValid
        {
            return;
        }
        
        let duration:Double = CMTimeGetSeconds(playerDuration)
        
        if isfinite(duration)
        {
            interval = 0.5 * duration / Double(self.sliderWidth!)
        }
        timeObserver = playerAZ?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock:{(time:CMTime) -> Void in
            self.syncSlider()
            }
        )
    
    }
    
    func endSliderScrubing()
    {
        let playerDuration:CMTime = playerItemDuration()
        if timeObserver == nil
        {
            if !playerDuration.isValid
            {
                return;
            }
            
            let duration:Double = CMTimeGetSeconds(playerDuration)
            
            if isfinite(duration)
            {
                let interval:Double = 0.5 * duration / Double(self.sliderWidth!)
                
                timeObserver = (playerAZ?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock:{(time:CMTime) -> Void in
                    self.syncSlider()
                    }
                ))
            }
        }
        
        if let restoreRate = restoreAfterScrubbingRate
        {
            playerAZ?.rate = restoreRate
            restoreAfterScrubbingRate = 0
        }

    }
    func isPLaying() -> Bool
    {
    return (restoreAfterScrubbingRate != 0) || (playerAZ?.rate != 0)
    }

    func beginSliderScrubbing()
    {
        
        
        restoreAfterScrubbingRate = playerAZ?.rate
        playerAZ?.rate = 0
        self.removeTimeObserver()
    }
    
    func removeTimeObserver()
    {
        if timeObserver != nil
        {
            playerAZ?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func playerItemDuration()->CMTime
    {
        let playerItem = playerAZ?.currentItem
        
        if playerItem?.status == AVPlayerItemStatus.ReadyToPlay
        {
            
            return playerItem!.duration
        }
        return kCMTimeInvalid
    }
    
    func sliderValueChanged(value:Float)
    {
        let playerDuration:CMTime = self.playerItemDuration()

       
        if !playerDuration.isValid
        {
            return;
        }
        
        let duration:Double = CMTimeGetSeconds(playerDuration)
        
        let time:Double = duration * Double(value)
        
        if isfinite(duration)
        {
            playerAZ?.seekToTime(CMTimeMakeWithSeconds(time,Int32(NSEC_PER_SEC)))
        }
    }
    
    
    func syncSlider()
    {
        let playerDuration:CMTime = playerItemDuration()
        
        if !playerDuration.isValid
        {
            return;
        }
        
        let duration:Double = CMTimeGetSeconds(playerDuration)
        
        if isfinite(duration)
        {
            self.delegate?.sliderValueChanged(duration, playerTime:CMTimeGetSeconds(playerAZ!.currentTime()))

        }
        }
    
    
    //MARK: - Key Observing
    
    
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        
        if context == &MyStreamingMovieViewControllerPlayerItemStatusObserverContext
        {
            if let changeV:Int = change![NSKeyValueChangeNewKey] as? Int
            {
                //   print(changeV)
                
                let avplayerStatus:AVPlayerStatus = AVPlayerStatus(rawValue: changeV)!
                
                
                switch avplayerStatus
                {
                case .Unknown:
                    self.removeTimeObserver()
                    self.syncSlider()
                    break
                    
                case .ReadyToPlay:
                    self.initSliderTimings()
                    break
                    
                case .Failed:
                    let avpPlayerItem:AVPlayerItem = object as! AVPlayerItem
                    self.assetFailedtoPlayback(avpPlayerItem.error)
                    break
                    
                }
            }
        }
        else if context == &MyStreamingMovieViewControllerRateObservationContext
        {
            // let tempAvplayer:AVPlayerItem = change[NSKeyValueChangeNewKey] as! AVPlayerItem
            
        }
        else if context == &MyStreamingMovieViewControllerCurrentItemObservationContext
        {
            
        }
    }
    
    
    
    

}


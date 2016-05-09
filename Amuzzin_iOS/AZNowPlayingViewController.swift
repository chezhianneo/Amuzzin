//
//  ViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 02/02/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZNowPlayingViewController: AZCommonViewController,AZPlayerSliderDelegate {

    
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var play: UIButton!
    
    @IBOutlet weak var prev: UIButton!
    
    @IBOutlet weak var next: UIButton!
    
    @IBOutlet var barPlay: UIButton!
    
    @IBOutlet weak var imgVw: UIImageView!
    
    @IBOutlet weak var cntrlbarVw: UIView!
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var barImgVw: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    
    @IBOutlet weak var playedDuration: UILabel!
    
    @IBOutlet weak var totalDuration: UILabel!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.title = "Playing"
        
        AZMuiscPlayer.sharedInstance.sliderWidth = self.slider.bounds.size.width
        AZMuiscPlayer.sharedInstance.delegate = self
        slider.value = 0
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = self.cntrlbarVw.bounds
        self.cntrlbarVw.addSubview(visualEffectView)
        self.cntrlbarVw.sendSubviewToBack(visualEffectView)
        let navBarEffectVw = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        navBarEffectVw.frame = self.navBar.bounds
        self.navBar.addSubview(navBarEffectVw)
        self.navBar.sendSubviewToBack(navBarEffectVw)
        
           }
    
    
    func setSongDetailsAfterSetup()
    {
        self.songTitle.text = AZMuiscPlayer.sharedInstance.azplayerCurrentItemModel.songTitle
        self.albumTitle.text = AZMuiscPlayer.sharedInstance.azplayerCurrentItemModel.albumName
        
        if let songID = AZMuiscPlayer.sharedInstance.azplayerCurrentItemModel.songID
        {
            if  songID.getCharactersForIndex(2) == "SD"
        {
            self.getMediaArtForSongForUrl(AZMuiscPlayer.sharedInstance.azplayerCurrentItemModel.avplayerURL, senderView: self.barImgVw)
            self.getMediaArtForSongForUrl(AZMuiscPlayer.sharedInstance.azplayerCurrentItemModel.avplayerURL, senderView: self.imgVw)
        }
        else
        {
        self.getMediaArtForID(songID, senderView: self.barImgVw, size: self.barImgVw.bounds.size)
            self.getMediaArtForID(songID, senderView: self.imgVw, size: self.imgVw.bounds.size)

        }
        }
        

        self.barPlay.setImage(UIImage(named: "pause"), forState: .Normal)
        self.play.setImage(UIImage(named: "pause"), forState: .Normal)
        self.totalDuration.text = AZPlayerUtils.getTimefromCMTime(AZMuiscPlayer.sharedInstance.currentPlayerItem!.asset.duration)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        AZMuiscPlayer.sharedInstance.syncSlider()
        

    }
    
    @IBAction func playPressed(sender: AnyObject)
    {
        let senderImg:UIImage! = (sender as! UIButton).backgroundImageForState(.Normal)
        
       if AZMuiscPlayer.sharedInstance.isPlaying == true
       {
        AZMuiscPlayer.sharedInstance.pause()
        self.barPlay.setImage(UIImage(named: "play"), forState: .Normal)
        self.play.setImage(UIImage(named: "play"), forState: .Normal)

       }
        else
       {
        AZMuiscPlayer.sharedInstance.play()
        self.barPlay.setImage(UIImage(named: "pause"), forState: .Normal)
        self.play.setImage(UIImage(named: "pause"), forState: .Normal)
       }
    }

    @IBAction func prevPressed(sender: AnyObject)
    {
        AZMuiscPlayer.sharedInstance.previousSong()
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        
        AZMuiscPlayer.sharedInstance.nextSong()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

    @IBAction func valueChanged(sender: AnyObject)
    {
        let sliderTemp:UISlider = sender as! UISlider

        AZMuiscPlayer.sharedInstance.sliderValueChanged(sliderTemp.value)
    }
    
    func sliderValueChanged(value: Double, playerTime: Double)
    {
        slider.value =  Float(playerTime) / Float(value)
        self.playedDuration.text = AZPlayerUtils.getTimefromCMTime(AZMuiscPlayer.sharedInstance.playerAZ!.currentItem!.currentTime())
    }

    @IBAction func beginScrubbing(sender: AnyObject)
    {
    
        AZMuiscPlayer.sharedInstance.beginSliderScrubbing()
    }
    
    @IBAction func endScrubbing(sender: AnyObject)
    {
        
        AZMuiscPlayer.sharedInstance.endSliderScrubing()
    }
    
}


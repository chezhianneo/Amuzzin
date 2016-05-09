//
//  AZCommonViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 10/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

class AZCommonViewController: UIViewController,UIActionSheetDelegate,PlaylistListViewDelegate
{

    var selectedInt:Int?
    var playlistView:AZPlaylistListViewController!
    var cancelBtn:UIButton!
    var selectedType:AZPlayModeType?
    var color:UIColor?
    var azplayItemrModelArr:[AZPlayerItemModel]?
    
    func loadActionsheetView(senderObject:[AZPlayerItemModel]?)
    {
        self.azplayItemrModelArr = senderObject
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:"Play","Play Next","Add to Current Queue","Add to Playlist")
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int)
    {

        switch(buttonIndex)
        {
        case 1:
            if let array = self.azplayItemrModelArr
            {
                AZMuiscPlayer.sharedInstance.arrPlayerURL?.removeAll(keepCapacity: false)
                AZMuiscPlayer.sharedInstance.arrPlayerURL = array
                AZMuiscPlayer.sharedInstance.currentPlayerIndex = 0
                AZMuiscPlayer.sharedInstance.resetPlayer()
            }
            
        case 2:
            if let array = self.azplayItemrModelArr
            {
            var index = 1
            for item in array
            {
            AZMuiscPlayer.sharedInstance.arrPlayerURL?.insert(item, atIndex: index)
            index++
            }
            }
        case 3:
            if let array = self.azplayItemrModelArr
            {
                AZMuiscPlayer.sharedInstance.arrPlayerURL?.appendContentsOf(array)
            }
        case 4:
            self.displayPlaylist()
            
        default:
            break
        }
    }
    
    func displayPlaylist()
    {
        let window = UIApplication.sharedApplication().keyWindow
         playlistView = self.storyboard?.instantiateViewControllerWithIdentifier("PlaylistView") as! AZPlaylistListViewController
        playlistView.songArray = self.azplayItemrModelArr
        playlistView.delegate = self
        
        window!.addSubview(playlistView.view)
        cancelBtn = UIButton(type: .Custom)
        cancelBtn.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0), forState: UIControlState.Normal)
        cancelBtn.backgroundColor = UIColor.whiteColor()

        cancelBtn.setTitle("Cancel", forState: UIControlState.Normal)
        window!.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchDown)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        window?.addConstraint(NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: window, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -30))
        cancelBtn.addConstraint(NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 275))

        window?.addConstraint(NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: window, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
    }
    
    func close()
    {
        self.cancelBtn.removeFromSuperview()
        self.playlistView.view.removeFromSuperview()
        self.cancelBtn = nil
        self.playlistView = nil
    }
    
    func closePlaylistListView()
    {
        close()
    }
    
    func resizeImage(image:MPMediaItemArtwork ,size:CGSize) -> UIImage
    {
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        let newimage  = image.imageWithSize(size)
        newimage!.drawInRect(CGRectMake(10, 0, size.width, size.height))
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimage!
        
    }
    
    func getMediaArtForSongForUrl(stringURL:NSURL?,senderView:UIImageView?)
    {
        let directoryArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let directoryPath = directoryArray.first! as String

        let toArray:[AnyObject] = stringURL!.absoluteString.componentsSeparatedByString("/")
        var azcurrentPlayerString = directoryPath + "/" + (toArray.last as! String)
        var azplayURL = NSURL(fileURLWithPath: azcurrentPlayerString.stringByRemovingPercentEncoding!)
        
        let avAsset = AVURLAsset(URL: azplayURL, options: nil)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            { () -> Void in
                
                let artWorks = AVMetadataItem.metadataItemsFromArray(avAsset.commonMetadata, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon) as! [AVMetadataItem]
                
                for item:AVMetadataItem in artWorks
                {
                    if let key = item.keySpace
                    {
                    if key == AVMetadataKeySpaceID3 || key == AVMetadataKeySpaceiTunes
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                () -> Void in
                                senderView?.image  = UIImage(data: item.dataValue!)!
                                return

                            })
                        }
                        
                    }
                    else
                    {
                        
                        dispatch_async(dispatch_get_main_queue(),
                            {
                                () -> Void in
                                senderView?.image  = UIImage(named: "album-art-missing")
                                
                        })
                    }
                }
        })
        
    }
    
    func getMediaArtForID(stringID:String?,senderView:UIImageView?,size:CGSize?)
    {
        
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    {
        () -> Void in
   
    let songQuery = MPMediaQuery()
    
    songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: stringID, forProperty: MPMediaItemPropertyPersistentID))
    let songArray = songQuery.items
    if let songItem:MPMediaItem = songArray!.first {
    if let mpArtWork = songItem.valueForProperty(MPMediaItemPropertyArtwork)  as? MPMediaItemArtwork {
    
    let newSize = (size == nil) ? mpArtWork.imageCropRect.size : size

    let artwork:UIImage = mpArtWork.imageWithSize(newSize!)!

     dispatch_async(dispatch_get_main_queue(),
      {
        () -> Void in
            senderView?.image = artwork
            return
        })
      }
     }
    })
    dispatch_async(dispatch_get_main_queue(), {
    () -> Void in
    senderView?.image  = UIImage(named: "album-art-missing")
    })
    }
}





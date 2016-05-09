//
//  AZPlaylistdetailViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 14/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZPlaylistdetailViewController: AZCommonViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var playListimgvw: UIImageView!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var playlistTitleLbl: UILabel!
    @IBOutlet weak var songsCountLbl: UILabel!
    var playlistId:String?
    var selectedPlaylistRow:Int?
    var longPressGesture:UILongPressGestureRecognizer!

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let playlistModel = AZPlaylistManager.sharedInstance.playlistArr![selectedPlaylistRow!]
        AZPlaylistManager.sharedInstance.getAddedSongsinPlaylist(playlistModel.id)
        playlistTitleLbl.text = playlistModel.name
        self.title = playlistModel.name
        self.playlistId = playlistModel.id
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressGestureAction:")
        self.tableView.addGestureRecognizer(self.longPressGesture)

        if let playlistSongArr = AZPlaylistManager.sharedInstance.playlistSongsArr where playlistSongArr.count > 0
        {
            var imgArray = [UIImage]()
            var interval = Int(playlistSongArr.count/4)
            if interval == 0
            {
                var index = 0
                for count in 0...4
                {
                    let model:AZPlayerItemModel = playlistSongArr[index]
                    let image = AZPlayerUtils.getImageForSongModel(model)
                    imgArray.append(image)
                    index = (index == (playlistSongArr.count - 1)) ? 0 : (index+1)
                    
                }
            }
            else
            {
            for var index = 0; index < playlistSongArr.count; index += interval
            {
                let model:AZPlayerItemModel = playlistSongArr[index]
                let image = AZPlayerUtils.getImageForSongModel(model)
                imgArray.append(image)

            }
            }
            let image = self.mergeImages(imgArray)
            playListimgvw.image = image
            
            songsCountLbl.text = String(stringInterpolationSegment: playlistSongArr.count) + " Songs"

        }
        
//        Make Nav bar transparent
//        self.navigationBar.setBackgroundImage(UIImage.new(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationBar.shadowImage = UIImage.new()
//        self.navigationBar.translucent = true
//        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AZPlaylistManager.sharedInstance.playlistSongsArr!.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell:AZSongTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("SongCellQueue") as! AZSongTableViewCell
        let azplayerModel:AZPlayerItemModel = AZPlaylistManager.sharedInstance.playlistSongsArr![indexPath.row] as AZPlayerItemModel
        
        if let songID = azplayerModel.songID
        {
            if  songID.getCharactersForIndex(2) == "SD"
            {
                self.getMediaArtForSongForUrl(azplayerModel.avplayerURL, senderView: cell.imgVw)
            }
            else
            {
                self.getMediaArtForID(songID, senderView: cell.imgVw, size: cell.imgVw.bounds.size)
                
            }
        }
        
        cell.songTitleLbl.text = azplayerModel.songTitle
        cell.albumLbl.text = azplayerModel.albumName
        cell.minLbl.text = azplayerModel.duration
        cell.addAction.addTarget(self, action: "loadActionsheetView:", forControlEvents: UIControlEvents.TouchDown)
        let tapGesture = UIPanGestureRecognizer(target: self, action: "longPressGestureAction:")
        cell.dragImgVw.addGestureRecognizer(tapGesture)
        cell.addAction.tag = indexPath.row
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        playSongAtIndex(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func mergeImages(images:[UIImage]) -> UIImage
    {
        let newSize = self.playListimgvw.bounds.size
        let image1 = images[0]
        let image2 = images[1]
        let image3 = images[2]
        let image4 = images[3]
            
        UIGraphicsBeginImageContext(newSize)
        
        image1.drawInRect(CGRectMake(0, 0, newSize.width/4, newSize.height))
        image2.drawInRect(CGRectMake(newSize.width/4, 0, newSize.width/4, newSize.height))
        image3.drawInRect(CGRectMake(newSize.width/2,0, newSize.width/4, newSize.height))
        image4.drawInRect(CGRectMake(newSize.width * 3/4,0 , newSize.width/4, newSize.height))

        
//        image1.drawAtPoint(CGPointMake(((newSize.width - image1.size.width) / 2),((newSize.height - image1.size.height) / 2)))
//
//        
//        image2.drawAtPoint(CGPointMake(((newSize.width - image2.size.width) / 2),((newSize.height - image2.size.height) / 2)))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    @IBOutlet weak var addButtonAction: UIButton!
    
    @IBAction func playbuttonAction(sender: AnyObject)
    {
        playSongAtIndex(0)

    }
    @IBAction func suffleButtonTapped(sender: AnyObject)
    {
    }
    
    func playSongAtIndex(index:Int)
    {
        AZMuiscPlayer.sharedInstance.arrPlayerURL?.removeAll(keepCapacity: false)
        AZMuiscPlayer.sharedInstance.arrPlayerURL = AZPlaylistManager.sharedInstance.playlistSongsArr
        AZMuiscPlayer.sharedInstance.currentPlayerIndex = index
        AZMuiscPlayer.sharedInstance.resetPlayer()
    }
    
    func longPressGestureAction(sender:UIGestureRecognizer)
    {
        let state = sender.state
        let location = sender.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        
        struct StaticVar
        {
            static var snapshot:UIView? =  nil
            static var sourceIndexPath:NSIndexPath? = nil
        }
        
        
        switch(state)
        {
        case UIGestureRecognizerState.Began:
            if let tempIndexPath = indexPath
            {
                StaticVar.sourceIndexPath = indexPath
                let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(tempIndexPath)!
                //cell.backgroundColor = UIColor.clearColor()
                StaticVar.snapshot = self.takeSnapshot(cell)
                var center:CGPoint = cell.center
                StaticVar.snapshot?.center = center
                
                StaticVar.snapshot?.alpha = 0.0
                self.tableView.addSubview(StaticVar.snapshot!)
                UIView.animateWithDuration(0.25, animations: {
                    // center.y = location.y
                    StaticVar.snapshot?.center = center
                    StaticVar.snapshot?.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    StaticVar.snapshot?.alpha = 0.98
                    }, completion: {
                        (finished) -> Void in
                        cell.hidden = true
                })
                
                
            }
            break
            
        case UIGestureRecognizerState.Changed:
            var center = StaticVar.snapshot?.center
            center?.y = location.y
            StaticVar.snapshot?.center = center!
            
            if (indexPath != nil) && (indexPath != StaticVar.sourceIndexPath)
            {
                
                let f = indexPath!.row, t = StaticVar.sourceIndexPath!.row
                AZPlaylistManager.sharedInstance.reorderSongsatIndexPath(self.playlistId!, sourceIndex: t, destinationIndex: f)
//                (AZMuiscPlayer.sharedInstance.arrPlayerURL![f], AZMuiscPlayer.sharedInstance.arrPlayerURL![t]) = (AZMuiscPlayer.sharedInstance.arrPlayerURL![t], AZMuiscPlayer.sharedInstance.arrPlayerURL![f])
                self.tableView.moveRowAtIndexPath(StaticVar.sourceIndexPath!, toIndexPath: indexPath!)
                StaticVar.sourceIndexPath = indexPath
            }
            break
        default:
            let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(StaticVar.sourceIndexPath!)!
            cell.hidden = false
            cell.alpha = 0.0
            UIView.animateWithDuration(0.25, animations:
                {
                    StaticVar.snapshot?.center = cell.center
                    StaticVar.snapshot?.transform = CGAffineTransformIdentity
                    StaticVar.snapshot?.alpha = 0.0
                    cell.alpha = 1.0
                }, completion:
                {
                    (finished:Bool) -> Void in
                    StaticVar.sourceIndexPath = nil
                    StaticVar.snapshot?.removeFromSuperview()
                    StaticVar.snapshot = nil
            })
            break
        }
    }
    
    func takeSnapshot(inputView:UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

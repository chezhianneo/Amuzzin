//
//  AZCurrentQueueVC.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 10/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZCurrentQueueVC: AZCommonViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var undoDeleteBtn: UIButton!
    var longPressGesture:UILongPressGestureRecognizer!
    override func viewDidLoad()
    {
        super.viewDidLoad()
       // self.tableView.registerNib(UINib(nibName:"AZSongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressGestureAction:")
        self.tableView.addGestureRecognizer(self.longPressGesture)
        self.title = "Current Queue"
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AZMuiscPlayer.sharedInstance.arrPlayerURL!.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
    return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:AZSongTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("SongCellQueue") as! AZSongTableViewCell
        let azplayerModel:AZPlayerItemModel = AZMuiscPlayer.sharedInstance.arrPlayerURL![indexPath.row] as AZPlayerItemModel
        
        if let songID = azplayerModel.songID
        {
            if  songID.substringToIndex(songID.startIndex.advancedBy(2)) == "SD"
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
        cell.dragImgVw.userInteractionEnabled = true
        let tapGesture = UIPanGestureRecognizer(target: self, action: "longPressGestureAction:")
        cell.dragImgVw.addGestureRecognizer(tapGesture)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        AZMuiscPlayer.sharedInstance.currentPlayerIndex = indexPath.row
        AZMuiscPlayer.sharedInstance.resetPlayer()        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    @IBAction func addToPlaylist(sender: AnyObject)
    {
        self.displayPlaylist()
    }
    
    @IBAction func clearQueue(sender: AnyObject)
    {
        AZMuiscPlayer.sharedInstance.arrPlayerURL?.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    // Override to support editing the table view.


    
     func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    //Mark:Gesture
    
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
            (AZMuiscPlayer.sharedInstance.arrPlayerURL![f], AZMuiscPlayer.sharedInstance.arrPlayerURL![t]) = (AZMuiscPlayer.sharedInstance.arrPlayerURL![t], AZMuiscPlayer.sharedInstance.arrPlayerURL![f])
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
    deinit
    {

    }

}

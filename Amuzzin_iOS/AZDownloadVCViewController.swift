//
//  AZDownloadVCViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 20/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZDownloadVCViewController: AZCommonViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.title = "Downloads"
        
        if AZDownloadManager.sharedInstance.songsUpdated == true
        {
            AZMediaManager.sharedInstance.loadSongsFromDownloadedPath()
            self.tableView.reloadData()
            AZDownloadManager.sharedInstance.songsUpdated = false
        }
    }
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "AZSongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        AZMediaManager.sharedInstance.loadSongsFromDownloadedPath()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBarHidden = false
        
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
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
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AZMediaManager.sharedInstance.downloadedSongsArr!.count
    }
    
    func tableView(_tableView: UITableView,
        willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if cell.respondsToSelector("setSeparatorInset:")
        {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell:AZSongTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("SongCell") as! AZSongTableViewCell
        let azplayerModel:AZPlayerItemModel = AZMediaManager.sharedInstance.downloadedSongsArr![indexPath.row] as AZPlayerItemModel
        
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

        cell.addAction.addTarget(self, action: "actionMorePressed:", forControlEvents: UIControlEvents.TouchDown)
        cell.addAction.contentMode = UIViewContentMode.ScaleAspectFit
        cell.addAction.clipsToBounds = true
        cell.addAction.tag = indexPath.section*100000000 + indexPath.row
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        AZMuiscPlayer.sharedInstance.arrPlayerURL?.removeAll(keepCapacity: false)
        AZMuiscPlayer.sharedInstance.currentPlayerIndex = 0
        AZMuiscPlayer.sharedInstance.arrPlayerURL?.append(AZMediaManager.sharedInstance.downloadedSongsArr![indexPath.row])
        AZMuiscPlayer.sharedInstance.resetPlayer()
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func actionMorePressed(sender:UIButton)
    {

        self.loadActionsheetView([AZMediaManager.sharedInstance.downloadedSongsArr![sender.tag]])
    }
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
}


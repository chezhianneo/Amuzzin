//
//  AZSongsTableViewController.swift
//  Amuzzin_iOS
//
//  Created by C!T! on 08/04/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer

class AZSongsTableViewController: AZCommonViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var pageIndex:Int?
    var type:AZLibraryType?
    var songArr:SongSectionModel?
    var sectionArray:[String]?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if AZMediaManager.sharedInstance.songLibDict?.isEmpty == true
        {
        AZMediaManager.sharedInstance.loadSongLibrary()
        }
        self.sectionArray = Array(AZMediaManager.sharedInstance.songLibDict!.keys).sort { (element1, element2) -> Bool in
            return element1 < element2
        }

//
//        self.view.backgroundColor = color
//        
//        self.tableView.contentInset = UIEdgeInsetsMake(36, 0, 0, 0)
        
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
        if let array = self.sectionArray where self.sectionArray?.count>0
        {
            return array.count
        }
            return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if let array = self.sectionArray where self.sectionArray?.count>0
        {
            return array[section] as String
        }
        return ""
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
            return 83
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.

        if let dictKey = self.sectionArray?[section]
        {
            
            let songDictArray:[AZPlayerItemModel] = AZMediaManager.sharedInstance.songLibDict![dictKey]!
            return songDictArray.count
            
        }
        return 0
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCells", forIndexPath: indexPath) as! AZSongTableViewCell
        
        if let dictKey = self.sectionArray?[indexPath.section]
        {
            
        let songDictArray:[AZPlayerItemModel] = AZMediaManager.sharedInstance.songLibDict![dictKey]!
            
        let songModel:AZPlayerItemModel = songDictArray[indexPath.row]
            
        cell.songTitleLbl.text = songModel.songTitle
        cell.albumLbl.text = songModel.albumName
        cell.minLbl.text =  songModel.duration

        self.getMediaArtForID(songModel.songID, senderView: cell.imgVw, size: cell.imgVw.bounds.size)
        }
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        
        if let dictKey = self.sectionArray?[indexPath.section]
        {
            AZMuiscPlayer.sharedInstance.arrPlayerURL?.removeAll(keepCapacity: false)
            AZMuiscPlayer.sharedInstance.currentPlayerIndex = 0
            
            let songDictArray:[AZPlayerItemModel] = AZMediaManager.sharedInstance.songLibDict![dictKey]!
            
            let songModel:AZPlayerItemModel = songDictArray[indexPath.row]
         //   self.getMediaArtForID(songModel.songID, senderView: cell.imgVw, size: cell.imgVw.bounds.size)

         //   songModel.artWorkImage = loadArtWorkForSongItem(songModel.songID!, size:nil)
            AZMuiscPlayer.sharedInstance.arrPlayerURL?.append(songModel)
            AZMuiscPlayer.sharedInstance.resetPlayer()

        }
               tableView.deselectRowAtIndexPath(indexPath, animated: false)
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

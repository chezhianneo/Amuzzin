//
//  AZSearchViewControllerTableViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 02/05/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer

class AZSearchViewControllerTableViewController: AZCommonViewController,UITableViewDelegate,UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    var sectionsArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func resetView()
    {
        sectionsArray.removeAll(keepCapacity: false)
        if AZSearchManager.sharedInstance.searchAlbumArray?.count > 0
        {
        sectionsArray.append("Albums")
        }
        
        if AZSearchManager.sharedInstance.searchSongArray?.count > 0
        {
            sectionsArray.append("Songs")
        }
        if AZSearchManager.sharedInstance.searchArtistsArray?.count > 0
        {
            sectionsArray.append("Artists")
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return sectionsArray.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch(sectionsArray[section])
        {
        case "Albums":
            return AZSearchManager.sharedInstance.searchAlbumArray!.count
        case "Songs":
            return AZSearchManager.sharedInstance.searchSongArray!.count
        case "Artists":
            return AZSearchManager.sharedInstance.searchArtistsArray!.count
        default:
        return 0
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch(sectionsArray[indexPath.section])
        {
        case "Albums":
            return 100
        case "Songs":
            return 80
        case "Artists":
            return 100
        default:
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(sectionsArray[indexPath.section])
        {
        case "Albums":
            return self.setCellForAlbumSearchResult(indexPath)
        case "Songs":
            return self.setCellForSongsSearchResult(indexPath)
        case "Artists":
            return self.setCellForArtistSearchResult(indexPath)
        default:
        break
        }
        return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
    }
    
    func setCellForAlbumSearchResult(indexPath:NSIndexPath) -> UITableViewCell
    {
        let   cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AZAlbumTableViewCell

        let albumModel:AlbumModel = AZSearchManager.sharedInstance.searchAlbumArray![indexPath.row]
        cell.albumTitle.text = albumModel.albumName
        cell.artistTitle.text = albumModel.albumArtist
        if let albumID = albumModel.albumID
        {
            cell.imgAlbumVw.image =  self.loadArtWorkForSongItem(albumID, size: cell.imgAlbumVw.bounds.size, propertyStr: MPMediaItemPropertyAlbumPersistentID)
        }
        else
        {
            self.getMediaArtForSongForUrl(albumModel.albumURLArtWork, senderView: cell.imgAlbumVw)
        }
        
        return cell
    }
    
    func setCellForSongsSearchResult(indexPath:NSIndexPath) -> UITableViewCell
    {
        let  cell = tableView.dequeueReusableCellWithIdentifier("SongCells", forIndexPath: indexPath) as! AZSongTableViewCell
        let songModel:AZPlayerItemModel = AZSearchManager.sharedInstance.searchSongArray![indexPath.row]

        cell.songTitleLbl.text = songModel.songTitle
        cell.albumLbl.text = songModel.albumName
        cell.minLbl.text = songModel.duration
        if let songID = songModel.songID
        {
            if  songID.getCharactersForIndex(2) == "SD"
            {
                self.getMediaArtForSongForUrl(songModel.avplayerURL, senderView: cell.imgVw)
            }
            else
            {
                self.getMediaArtForID(songID, senderView: cell.imgVw, size: cell.imgVw.bounds.size)
            }
        }

        
        
        return cell


    }
    func setCellForArtistSearchResult(indexPath:NSIndexPath) -> UITableViewCell
    {
        let  cell = tableView.dequeueReusableCellWithIdentifier("ArtistsCell", forIndexPath: indexPath) as! AZArtistsTableViewCell
        
        let artistModel:ArtistModel = AZSearchManager.sharedInstance.searchArtistsArray![indexPath.row]
        cell.artistTitleLbl.text = artistModel.artistName
        if let albumID = artistModel.artistID
        {
            cell.artistImgVw.image =  self.loadArtWorkForSongItem(albumID, size: cell.artistImgVw.bounds.size, propertyStr: MPMediaItemPropertyAlbumArtistPersistentID)
        }
        

        return cell


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
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {

        switch(sectionsArray[section])
        {
        case "Albums":
            return "Albums"
        case "Songs":
            return "Songs"
        case "Artists":
            return "Artists"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        
        // This changes the header background
        //view.tintColor = UIColor.whiteColor()
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        var headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.grayColor()
        
    }
    
    private func loadArtWorkForSongItem(albumID:String,size:CGSize?,propertyStr:String) -> UIImage?
    {
        let albumQuery = MPMediaQuery()
        
        albumQuery.addFilterPredicate(MPMediaPropertyPredicate(value: albumID, forProperty: propertyStr))
        let albumArray = albumQuery.collections
        let albumItem:MPMediaItem = albumArray!.first!.representativeItem!
        
        if let mpArtWork = albumItem.valueForProperty(MPMediaItemPropertyArtwork)  as? MPMediaItemArtwork
        {
            
            
            let newSize = (size == nil) ? mpArtWork.imageCropRect.size : size
            let artwork:UIImage = mpArtWork.imageWithSize(newSize!)!
            return artwork
        }
        
        return UIImage(named: "album-art-missing")
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

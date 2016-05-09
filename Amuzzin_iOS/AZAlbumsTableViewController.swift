//
//  AZAlbumsTableViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 27/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer

extension UIImage
{
    func imageResize (sizeChange:CGSize,quality:CGInterpolationQuality?)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}

class AZAlbumsTableViewController:  AZCommonViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var pageIndex:Int?
    var type:AZLibraryType?
    var sectionArray:[String]?
    var albumPersistenID:[String]?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AZMediaManager.sharedInstance.albumLibDict?.isEmpty == true
        {
            AZMediaManager.sharedInstance.loadAlbumLibrary()
        }
        self.sectionArray = Array(AZMediaManager.sharedInstance.albumLibDict!.keys).sort({$0.0 < $0.1})
    }
    
//    func setupAlbumSectionArray()
//    {
//        
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
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
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
            return 123
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let dictKey = self.sectionArray?[section]
        {
            
            let albumDictArray:[AlbumSectionModel] = AZMediaManager.sharedInstance.albumLibDict![dictKey]!
            return albumDictArray.count
            
        }
        return 0
        
    }
    
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        
        // This changes the header background
        //view.tintColor = UIColor.whiteColor()
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.grayColor()
        
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AZAlbumTableViewCell
        if let dictKey = self.sectionArray?[indexPath.section]
        {
            
            let albumDictArray:[AlbumSectionModel] = AZMediaManager.sharedInstance.albumLibDict![dictKey]!
            
            let albumModel:AlbumSectionModel = albumDictArray[indexPath.row]
            
            cell.albumTitle.text = albumModel.albumName
            cell.artistTitle.text = albumModel.albumArtist
            cell.totalSongs.text =  albumModel.albumCount + " Songs"
            //  cell.totMinslbl.text = ""
            cell.addButton.addTarget(self, action: "actionMorePressed:", forControlEvents: UIControlEvents.TouchDown)
            cell.addButton.tag = indexPath.section * 1000000 + indexPath.row
            cell.imgAlbumVw.image = self.loadArtWorkForSongItem(albumModel.albumID, size: cell.imgAlbumVw.bounds.size)
        }
        return cell
            
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        
        if let dictKey = self.sectionArray?[indexPath.section]
        {
            
            let songDictArray:[AlbumSectionModel] = AZMediaManager.sharedInstance.albumLibDict![dictKey]!
            let albumModel:AlbumSectionModel = songDictArray[indexPath.row]
            let albumDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("AlbumDetail") as! AZAlbumDetailViewController
            albumDetailVC.albumModel = albumModel
            albumDetailVC.albumImage = self.loadArtWorkForSongItem(albumModel.albumID, size: nil)
            self.navigationController?.pushViewController(albumDetailVC, animated: true)
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    {
        return self.sectionArray!
    }
    
    
    func tableView(tableView: UITableView,
        sectionForSectionIndexTitle title: String,
        atIndex index: Int)
        -> Int
    {
            return self.sectionArray!.indexOf(title)!
        
    }

    
    func actionMorePressed(sender:UIButton)
    {
        let section = Int(sender.tag/1000000)
        let row = sender.tag%1000000
        if let dictKey = self.sectionArray?[section]
        {
        let albumDictArray:[AlbumSectionModel] = AZMediaManager.sharedInstance.albumLibDict![dictKey]!
            
        let albumModel:AlbumSectionModel = albumDictArray[row]
        let id = albumModel.albumID
        let songQuery = MPMediaQuery()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyAlbumPersistentID))
            var playerItemModel = [AZPlayerItemModel]()
            
            for songItem in songQuery.items!
            {
                let azplayerItemModel = AZPlayerItemModel()
                let songTitle = songItem.valueForProperty(MPMediaItemPropertyTitle) as? String
                azplayerItemModel.songTitle = songTitle
                azplayerItemModel.albumName = songItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String
                azplayerItemModel.artists = songItem.valueForProperty(MPMediaItemPropertyArtist) as? String
                azplayerItemModel.albumArtist = songItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as? String
                azplayerItemModel.duration = AZPlayerUtils.getTimeFromNstimeInterval(songItem.valueForProperty(MPMediaItemPropertyPlaybackDuration)!.integerValue)
                azplayerItemModel.lyrics = songItem.valueForProperty(MPMediaItemPropertyLyrics) as? String
                azplayerItemModel.genreName = songItem.valueForProperty(MPMediaItemPropertyGenre) as? String
                azplayerItemModel.avplayerURL = songItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
                azplayerItemModel.songID = String(stringInterpolationSegment: songItem.valueForProperty(MPMediaItemPropertyPersistentID))
                playerItemModel.append(azplayerItemModel)
            }

        
        self.loadActionsheetView(playerItemModel)
        }
    }
    
    
    
    
    private func loadArtWorkForSongItem(albumID:AnyObject,size:CGSize?) -> UIImage?
    {
        let albumQuery = MPMediaQuery.albumsQuery()
        let predicate = MPMediaPropertyPredicate(value: albumID, forProperty: MPMediaItemPropertyPersistentID)
        
        albumQuery.addFilterPredicate(predicate)
        let albumArray = albumQuery.items
        if let albumItem:MPMediaItem = albumArray!.first
        {
        
        if let mpArtWork = albumItem.valueForProperty(MPMediaItemPropertyArtwork)  as? MPMediaItemArtwork
        {
            
            
            let newSize = (size == nil) ? mpArtWork.imageCropRect.size : size
            let artwork:UIImage = mpArtWork.imageWithSize(newSize!)!
            return artwork
        }
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

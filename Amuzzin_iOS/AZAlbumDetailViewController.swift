//
//  AZAlbumDetailViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 05/07/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer

class AZAlbumDetailViewController: AZCommonViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var playListimgvw: UIImageView!
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var playlistTitleLbl: UILabel!
    @IBOutlet weak var songsCountLbl: UILabel!
    var albumModel:AlbumSectionModel?
    var songModel:[AZPlayerItemModel]?
    var albumImage:UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songModel = [AZPlayerItemModel]()
        playlistTitleLbl.text = albumModel?.albumName
        songsCountLbl.text = albumModel!.albumCount + " Songs"
        artistName.text = albumModel!.albumArtist
        self.title = albumModel?.albumName
        self.playListimgvw.image = albumImage
        
        let songQuery = MPMediaQuery.songsQuery()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: albumModel!.albumID, forProperty: MPMediaItemPropertyPersistentID))
        
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
            songModel?.append(azplayerItemModel)
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
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.songModel!.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell:AZSongTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("SongCellAlbum") as! AZSongTableViewCell
        let azplayerModel:AZPlayerItemModel = self.songModel![indexPath.row] as AZPlayerItemModel
        
        cell.songTitleLbl.text = azplayerModel.songTitle
        cell.albumLbl.text = azplayerModel.albumName
        cell.minLbl.text = azplayerModel.duration
        cell.addAction.addTarget(self, action: "loadActionsheetView:", forControlEvents: UIControlEvents.TouchDown)
        cell.addAction.tag = indexPath.row
        

        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        playSongAtIndex(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
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
        AZMuiscPlayer.sharedInstance.arrPlayerURL = self.songModel
        AZMuiscPlayer.sharedInstance.currentPlayerIndex = index
        AZMuiscPlayer.sharedInstance.resetPlayer()
    }
}

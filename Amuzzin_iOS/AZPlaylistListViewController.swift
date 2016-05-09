//
//  AZPlaylistListViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 14/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

protocol PlaylistListViewDelegate
{
    func closePlaylistListView()
}

class AZPlaylistListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var delegate:PlaylistListViewDelegate?
    var songArray:[AZPlayerItemModel]?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        songArray = [AZPlayerItemModel]()
        AZPlaylistManager.sharedInstance.getPlaylist({})

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AZPlaylistManager.sharedInstance.playlistCount! + 1
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if indexPath.row == 0
        {
            let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
            cell.textLabel?.text = "Create a New Playist"
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        }
        else
        {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("PlaylistListCell")! as UITableViewCell
        let playListModel = AZPlaylistManager.sharedInstance.playlistArr![indexPath.row - 1] as PlaylistModel
        cell.textLabel?.text = playListModel.name
        //cell.layer.borderWidth = 2.0
        //cell.layer.borderColor = UIColor.whiteColor().CGColor
        
        return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == 0
        {
            let alert:UIAlertView = UIAlertView(title: "New Playlist", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Create Playlist")
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alert.show()
        }
        else
        {
            saveSongsinCoreData(indexPath.row, playlistNewName: "")

        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            let alertStr = alertView.textFieldAtIndex(0)?.text
            if alertStr != ""
            {
                saveSongsinCoreData(0, playlistNewName: alertStr!)
            }
        }
        
    }
    
    func saveSongsinCoreData(selectedInt:Int,playlistNewName:String)
    {
        if let songArr:[AZPlayerItemModel] = self.songArray
        {
            var playlistID = ""
            var playlistName = playlistNewName
            if selectedInt > 0
            {
            let azplaylistModel = AZPlaylistManager.sharedInstance.playlistArr![selectedInt - 1]
                playlistID = azplaylistModel.id
                playlistName = azplaylistModel.name
            }
            
            AZPlaylistManager.sharedInstance.addSongstoPlaylist(songArr, playlistID: playlistID,playlistName: playlistName)
            
        }
        self.delegate?.closePlaylistListView()


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

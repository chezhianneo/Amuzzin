//
//  AZPlaylistVC.swift
//  Amuzzin_iOS
//
//  Created by 01HW842980 on 02/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit



class AZPlaylistVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let colorDict = ["0":"FF00CC","1":"FF9900","2":"33CC00","3":"9900CC","4":"FF0033","5":"660033","6":"330099","7":"3399FF","8":"999900","9":"330099","A":"990033","B":"006600","C":"FF00CC","D":"FF9900","E":"33CC00","F":"9900CC","G":"FF0033","H":"660033","I":"330099","J":"3399FF","K":"999900","L":"330099","M":"990033","N":"006600","O":"FF00CC","P":"FF9900","Q":"33CC00","R":"9900CC","S":"FF0033","T":"660033","U":"330099","V":"3399FF","W":"999900","X":"330099","Y":"990033","Z":"006600"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "AZPlaylistTVCell", bundle: nil), forCellReuseIdentifier: "PlayListTableCell")
        self.tabBarController?.title = "Playlist"

    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.title = "Playlist"
        AZPlaylistManager.sharedInstance.getPlaylist({})
        self.tableView.reloadData()


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        return 1 + AZPlaylistManager.sharedInstance.playlistCount!
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

            let cell:AZPlaylistTVCell = self.tableView.dequeueReusableCellWithIdentifier("PlayListTableCell") as! AZPlaylistTVCell
            
            
            if indexPath.row == 0
            {
                cell.playlisttitleLbl.text = "Favourite"
                cell.indexLabel.text = "F"
                cell.indexLabel.backgroundColor = UIColor.blackColor()
            }
            else
            {
                let playlistModel = AZPlaylistManager.sharedInstance.playlistArr![indexPath.row - 1]
                cell.playlisttitleLbl.text = playlistModel.name
                let indexString = String(playlistModel.name[playlistModel.name.startIndex]).uppercaseString
                cell.indexLabel.text = indexString
                cell.indexLabel.backgroundColor = UIColor(hexString:colorDict[indexString]!, alpha: 1.0)
            }
            return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
            let playlistDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlaylistDetail") as! AZPlaylistdetailViewController
            playlistDetailVC.selectedPlaylistRow = indexPath.row - 1
            self.navigationController?.pushViewController(playlistDetailVC, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    


    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
    // Return NO if you do not want the specified item to be editable.
        if indexPath.row > 0
        {
            return true
        }
        return false
    }

    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
    if editingStyle == .Delete
    {
        let playlistModel = AZPlaylistManager.sharedInstance.playlistArr![indexPath.row - 1]
        AZPlaylistManager.sharedInstance.playlistCount = AZPlaylistManager.sharedInstance.playlistCount! - 1
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        AZPlaylistManager.sharedInstance.deletePlaylistEntity(playlistModel.id)
    }
    }
    
    
    // Override to support rearranging the table view.
 
    @IBAction func showCurrentQueue(sender: AnyObject)
    {
        
    }
    // Override to support conditional rearranging of the table view.

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
}

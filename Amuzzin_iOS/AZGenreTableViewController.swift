//
//  AZGenreTableViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 27/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import MediaPlayer

class AZGenreTableViewController:   AZCommonViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var pageIndex:Int?
    var type:AZLibraryType?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        //  self.view.backgroundColor = color
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
        return 103
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        let genreArray = MPMediaQuery.genresQuery()
        return genreArray.collections!.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let genreQuery = MPMediaQuery.genresQuery()
        let genreArray = genreQuery.collections
        let genreItem:MPMediaItem = genreArray![indexPath.row].representativeItem!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GenreCell", forIndexPath: indexPath) as! AZArtistsTableViewCell
        
        
        cell.artistTitleLbl.text = genreItem.valueForProperty(MPMediaItemPropertyGenre) as? String
        cell.artistTypeLbl.text = genreItem.valueForProperty(MPMediaItemPropertyAlbumTrackCount) as? String
        cell.artistCountLbl.text = String(stringInterpolationSegment: genreItem.valueForProperty(MPMediaItemPropertyAlbumTrackCount))
        if let mpArtWork = genreItem.valueForProperty(MPMediaItemPropertyArtwork)  as? MPMediaItemArtwork
        {
            let artwork:UIImage = mpArtWork.imageWithSize(cell.artistImgVw.bounds.size)!
            cell.artistImgVw.image = artwork
        }
        return cell
        
        
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

//
//  AZDownloadingViewController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 25/07/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZDownloadingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,AZDownloadingDelegate
{
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
      if let dm = AZDownloadManager.sharedInstance.downloadInfoArr
      {
        return dm.count
        }
        return 0
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        AZDownloadManager.sharedInstance.delegate = self


    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AZDownloadInfoCell") as! AZDownloadInfoCell
        let downloadModel = AZDownloadManager.sharedInstance.downloadInfoArr![indexPath.row]
        cell.fileNameLbl.text =  downloadModel.name
        return cell
    }
    
    func downloadFailed(selectedRow: Int)
    {
        //
    }
    
    func downloadCompleted(selectedRow: Int)
    {
        let indexPath = NSIndexPath(forRow: selectedRow, inSection: 0)
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
        self.tableView.endUpdates()

    }
    
    func valueChanged(totalSize: String, speed: String, downloaded: String, remainingTime: String, selectedRow: Int, progress: Float)
    {
        //
        
        let tmpIndexPath = NSIndexPath(forRow: selectedRow, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(tmpIndexPath) as! AZDownloadInfoCell
        cell.speedLbl.text = speed
        cell.totalSizeLbl.text = totalSize
        cell.downloadedLbl.text = downloaded
        cell.downloadPercentLbl.text = String(Int(progress * 100)) + "%"
        cell.downloadPercentPVw.progress = progress
        //cell.downloadStatusLbl.text = "Downloading"
        cell.remianingTimeLbl.text = remainingTime
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var title:String? = "Pause"
        var color:UIColor?
        let downloadModel = AZDownloadManager.sharedInstance.downloadInfoArr![indexPath.row]
        
        if let status = downloadModel.downloadStatus
        {
            switch(status)
            {
            case .Paused:
                title = "Resume"
                color = UIColor(hexString: "4CD964")
            case .Failed:
                title = "Retry"
                color = UIColor(hexString: "4CD964")
            default:
                title = "Pause"
                color = UIColor(hexString: "DBDDDE")
            }
        }
        
        
        let pauseRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: title, handler:{action, indexpath in
            print("MORE•ACTION");
            let tmpDownloadModel = AZDownloadManager.sharedInstance.downloadInfoArr![indexPath.row]
            AZDownloadManager.sharedInstance.pauseButtonAction(indexPath.row)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AZDownloadInfoCell
            cell.speedLbl.text = ""
            cell.downloadStatusLbl.text = tmpDownloadModel.downloadStatus?.rawValue
            
        })
        pauseRowAction.backgroundColor = color
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Remove", handler:
            {action, indexpath in
                print("MORE•ACTION");
                AZDownloadManager.sharedInstance.removeTaskForSelctedRow(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
        })
        
        return [deleteRowAction, pauseRowAction]
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(true)
        AZDownloadManager.sharedInstance.delegate = nil
    }
    
}

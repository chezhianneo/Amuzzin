//
//  AZDownloadInfo.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 14/07/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import Foundation
import UIKit

enum DownloadingStatus:String
{
    case Downloading = "Downloading"
    case Paused = "Paused"
    case Failed = "Failed"
}

class DownloadInfo:NSObject,NSCoding
{
    var name:String?
    var downloadURL:NSURL?
    var downloadStatus:DownloadingStatus?
    var downloadtask:NSURLSessionDownloadTask?
    var downloadDataURL:NSURL?
    var progress:Double?
    var startDate:NSDate?
    var details:String?
    
    override init()
    {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        if let name = aDecoder.decodeObjectForKey("name") as? String
        {
            self.name = name
        }
        if let downloadURL = aDecoder.decodeObjectForKey("downloadURL") as? NSURL
        {
            self.downloadURL = downloadURL
        }
        if let downloadStatus = aDecoder.decodeObjectForKey("downloadStatus") as? String
        {
            self.downloadStatus = DownloadingStatus(rawValue: downloadStatus)
        }
        if let downloadDataURL = aDecoder.decodeObjectForKey("downloadDataURL") as? NSURL
        {
            self.downloadDataURL = downloadDataURL
        }
        if let progress = aDecoder.decodeObjectForKey("progress") as? Double
        {
            self.progress = progress
        }
        if let startDate = aDecoder.decodeObjectForKey("startDate") as? NSDate
        {
            self.startDate = startDate
        }
        if let details = aDecoder.decodeObjectForKey("details") as? String
        {
            self.details = details
        }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {

        if let name = self.name
        {
            aCoder.encodeObject(name, forKey: "name")
        }
        if let downloadURL = self.downloadURL
        {
            aCoder.encodeObject(downloadURL, forKey: "downloadURL")
        }
        if let downloadStatus = self.downloadStatus
        {
            aCoder.encodeObject(downloadStatus.rawValue, forKey: "downloadStatus")
        }
        if let downloadDataURL = self.downloadDataURL
        {
            aCoder.encodeObject(downloadDataURL, forKey: "downloadDataURL")
        }
        if let progress = self.progress
        {
            aCoder.encodeObject(progress, forKey: "progress")
        }
        if let startDate = self.startDate
        {
            aCoder.encodeObject(startDate, forKey: "startDate")
        }
        if let details = self.details
        {
            aCoder.encodeObject(details, forKey: "details")
        }
    }
    
}


//
//  AZDownloadManager.swift
//  Amuzzin_iOS
//
//  Created by GLTAB on 3/6/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit


protocol AZDownloadingDelegate
{
    func valueChanged(totalSize:String,speed:String,downloaded:String,remainingTime:String,selectedRow:Int,progress:Float)
    func downloadCompleted(selectedRow:Int)
    func downloadFailed(selectedRow:Int)
}

class AZDownloadManager: NSObject,NSURLSessionDelegate,NSURLSessionDownloadDelegate
{
    var urlDSession:NSURLSession?
    var downloadInfoArr:[DownloadInfo]?
    var mRequest:NSMutableURLRequest!
    var responseData:NSMutableData?
    var jsonError : NSError?
    var progressPercent:Int?
    var onceToken : dispatch_once_t = 0
    var downloadURL:NSURL?
    var handlerQueue: [String : BackGroundTaskCompletionHandler]!
    var delegate:AZDownloadingDelegate?
    var songsUpdated:Bool?

    
    override init()
    {
        super.init()
        self.urlDSession = BackGroundSession()
        self.songsUpdated = false
        if let tmpDictArr: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("AZDownloadQueue")
        {
            let downloadInfoArr:[DownloadInfo] = NSKeyedUnarchiver.unarchiveObjectWithData(tmpDictArr as! NSData) as! [DownloadInfo]
            self.downloadInfoArr = downloadInfoArr
        }
        else
        {
            self.downloadInfoArr = [DownloadInfo]()

        }
        
    }
    
    func addDownloadTask(mediaURL:NSURL)
    {
        let request = NSMutableURLRequest(URL: mediaURL)
        let urlSessionDataTask = self.urlDSession?.downloadTaskWithRequest(request)
        let downloadModel = DownloadInfo()
        
        let toArray:[AnyObject] = mediaURL.absoluteString.componentsSeparatedByString("/")
        let fileName = toArray.last as! String

        downloadModel.downloadURL = mediaURL
        downloadModel.name = fileName.stringByReplacingOccurrencesOfString("%20", withString: "", options: .LiteralSearch, range: nil)
        downloadModel.downloadtask  = urlSessionDataTask
        downloadModel.downloadStatus = .Downloading
        downloadModel.startDate = NSDate()
        downloadInfoArr?.append(downloadModel)
        urlSessionDataTask!.resume()
        
    }
    
    
    class var sharedInstance: AZDownloadManager
    {
        struct Static {
            static var instance : AZDownloadManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)
        {
            Static.instance = AZDownloadManager()
            Static.instance!.handlerQueue = [String : BackGroundTaskCompletionHandler]()
        }
        
        return Static.instance!
    }
    
    func removeTaskForSelctedRow(selectedRow:Int)
    {
        let downloadModel:DownloadInfo = self.downloadInfoArr![selectedRow]
        downloadModel.downloadtask?.cancel()
        self.downloadInfoArr?.removeAtIndex(selectedRow)
        
    }
    
    
    func BackGroundSession() -> NSURLSession
    {
        var session : NSURLSession?
        
        dispatch_once(&onceToken)
        {
            let sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(BackGroundTokenIdentifier)
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 3
            session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        }
        return session!
    }
    
    func cancel(selectedRow:Int)
    {
        let downloadModel:DownloadInfo = self.downloadInfoArr![selectedRow]
        let downloadTask = downloadModel.downloadtask
        downloadTask?.cancel()
        downloadInfoArr?.removeAtIndex(selectedRow)
    }
    
    private var directoryPathForResumeData:String
    {
        let directoryArray = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
        return directoryArray.first! as String
    }
    
    private var directoryPathForStoreData:String
    {
        let directoryArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return directoryArray.first! as String

    }
    
    func pauseButtonAction(selectedRow:Int)
    {
        let downloadModel:DownloadInfo = self.downloadInfoArr![selectedRow]
        if downloadModel.downloadStatus == .Downloading
        {
            downloadModel.downloadtask?.suspend()
            downloadModel.downloadStatus = .Paused
            
        }
        else if downloadModel.downloadStatus == .Paused
        {
            downloadModel.downloadtask?.resume()

            downloadModel.downloadStatus = .Downloading
        }
        else if downloadModel.downloadStatus == .Failed
        {
      /*      if let url = downloadModel.downloadDataURL
            {
            let directoryPath = self.directoryPathForResumeData
            let toArray:[AnyObject] = url.absoluteString!.componentsSeparatedByString("/")
            var strTmpURL = directoryPath + "/" + (toArray.last as! String)
                
            var resumableData = NSData(contentsOfFile: strTmpURL)
            clearResumeData(NSURL(string: strTmpURL)!)
            self.urlDSession?.downloadTaskWithResumeData(resumableData!)
            downloadModel.downloadStatus = .Downloading
            }
            else
            { */
                self.urlDSession?.downloadTaskWithURL(downloadModel.downloadURL!)
                downloadModel.downloadStatus = .Downloading
          //  }
            
        }
        downloadInfoArr![selectedRow] = downloadModel


    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if let downloadModel = (self.downloadInfoArr!.filter(){$0.downloadtask == downloadTask
            }).first
        {
            
            let index = self.downloadInfoArr?.indexOf{$0.name == downloadModel.name}
            if downloadModel.downloadStatus == .Downloading
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let receivedBytesCount      : Double = Double(downloadTask.countOfBytesReceived)
                    let totalBytesCount         : Double = Double(downloadTask.countOfBytesExpectedToReceive)
                    let progress                : Float = Float(receivedBytesCount / totalBytesCount)
                    
                    let taskStartedDate         : NSDate = downloadModel.startDate!
                    let timeInterval            : NSTimeInterval = taskStartedDate.timeIntervalSinceNow
                    let downloadTime            : NSTimeInterval = NSTimeInterval(-1 * timeInterval)
                    
                    let speed                   : Float = Float(totalBytesWritten) / Float(downloadTime)
                    
                    let indexOfObject           : Int = index!
                    var indexPath               : NSIndexPath = NSIndexPath(forRow: indexOfObject, inSection: 0)
                    
                    let remainingContentLength  : Int64 = totalBytesExpectedToWrite - totalBytesWritten
                    let remainingTime           : Int64 = remainingContentLength / Int64(speed)
                    let hours                   : Int = Int(remainingTime) / 3600
                    let minutes                 : Int = (Int(remainingTime) - hours * 3600) / 60
                    let seconds                 : Int = Int(remainingTime) - hours * 3600 - minutes * 60
                    let fileSizeUnit            : Float = AZPlayerUtils.calculateFileSizeInUnit(totalBytesExpectedToWrite)
                    let unit                    : String = AZPlayerUtils.calculateUnit(totalBytesExpectedToWrite)
                    let fileSizeInUnits         : String = String(format: "%.2f \(unit)", fileSizeUnit)
                    let fileSizeDownloaded      : Float = AZPlayerUtils.calculateFileSizeInUnit(totalBytesWritten)
                    let downloadedSizeUnit      : String = AZPlayerUtils.calculateUnit(totalBytesWritten)
                    let downloadedFileSizeUnits : String = String(format: "%.2f \(downloadedSizeUnit)", fileSizeDownloaded)
                    let speedSize               : Float = AZPlayerUtils.calculateFileSizeInUnit(Int64(speed))
                    let speedUnit               : String = AZPlayerUtils.calculateUnit(Int64(speed))
                    let speedInUnits            : String = String(format: "%.2f \(speedUnit)", speedSize)
                    var remainingTimeStr:String = ""
                    var detailLabelText:String = ""
                    
                        if hours > 0
                        {
                        remainingTimeStr = "\(remainingTimeStr)" + "\(hours) Hours "
                        }
                        if minutes > 0 {
                            remainingTimeStr = "\(remainingTimeStr)" + "\(minutes) Min "
                        }
                        if seconds > 0 {
                            remainingTimeStr = "\(remainingTimeStr)" + "\(seconds) sec"
                        }
                        
                       detailLabelText =  "\(detailLabelText) + File Size: \(fileSizeInUnits)\nDownloaded: \(downloadedFileSizeUnits)  \(progress*100.0) \nSpeed: \(speedInUnits) sec\n"
                        print(detailLabelText)
                        if  progress == 1.0
                        {
                         detailLabelText = "\(detailLabelText)" + "Time Left: Please wait..."
                            self.delegate?.valueChanged(String(fileSizeInUnits), speed: "0 KB Ssec", downloaded: String(fileSizeInUnits), remainingTime: "0 sec", selectedRow: index!,progress:100)
                        }
                        else
                        {
                            detailLabelText = "\(detailLabelText)" + "Time Left: Please wait..."
                            self.delegate?.valueChanged(String(fileSizeInUnits), speed: String(speedInUnits), downloaded: String(downloadedFileSizeUnits), remainingTime: remainingTimeStr, selectedRow: index!,progress:progress)
                        }
                })
            }
        }
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    {
        if let downloadModel = (self.downloadInfoArr!.filter(){$0.downloadtask == downloadTask
            }).first
        {
            
        let index = self.downloadInfoArr?.indexOf{$0.name == downloadModel.name}
        let destinationURL = NSURL(fileURLWithPath:self.directoryPathForStoreData.stringByAppendingPathComponent(downloadModel.name!))
        let fileManager = NSFileManager.defaultManager()
        if let URL = downloadModel.downloadDataURL {
            let directoryPath = self.directoryPathForResumeData
            let toArray:[AnyObject] = URL.absoluteString.componentsSeparatedByString("/")
            let strTmpURL = directoryPath + "/" + (toArray.last as! String)

            clearResumeData(NSURL(string: strTmpURL)!)
        }
            
        if fileManager.fileExistsAtPath(destinationURL.path!) {
            do {
                try fileManager.removeItemAtPath(destinationURL.path!)
            }
            catch {
                print("File Copy error: \(error)")
            }
        }
        do {
            try fileManager.moveItemAtURL(location, toURL: destinationURL)
            downloadModel.downloadDataURL = destinationURL
            self.downloadInfoArr?.removeAtIndex(index!)
            self.delegate?.downloadCompleted(index!)
            AZMediaManager.sharedInstance.saveDownloadedSongs(downloadModel)
            self.songsUpdated = true
            
        }
        catch {
                print("File Move error: \(error)")
        }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let userInfo:[String:AnyObject] = error?.userInfo as? [String:AnyObject] {
                if let resonNumber:Int = userInfo["NSURLErrorBackgroundTaskCancelledReasonKey"] as? Int
                {
                    
                    if resonNumber == NSURLErrorCancelledReasonUserForceQuitApplication || resonNumber == NSURLErrorCancelledReasonBackgroundUpdatesDisabled
                    {

                        if let downloadModel = (self.downloadInfoArr!.filter(){$0.downloadtask == task
                            }).first
                        {
                            let index = self.downloadInfoArr?.indexOf{$0.name == downloadModel.name}
                            
                            copyResumableData(userInfo, downloadObject: downloadModel,index:index!)
                            self.delegate?.downloadFailed(index!)
                            return
                        }
                    }

                }
            var index = 0
            for downloadObject in self.downloadInfoArr! {
                let downloadModel = downloadObject
                if task == downloadModel.downloadtask
                {
                if let errorCopy = error
                {
                    if errorCopy.code == NSURLErrorCancelled
                    {
                        
                        let index = self.downloadInfoArr?.indexOf{$0.name == downloadModel.name}
                        copyResumableData(userInfo, downloadObject: downloadModel,index:index!)
                        return
                    }
                }
                else {
                    let taskInfo        : String = task.taskDescription!
                    let taskDescription : NSData? = taskInfo.dataUsingEncoding(NSUTF8StringEncoding)
                        do {
                        let taskInfoDict = try NSJSONSerialization.JSONObjectWithData(taskDescription!, options: .AllowFragments)
                        let fileName : String = taskInfoDict["fileName"] as! String
                        
                        if let downloadModel = (self.downloadInfoArr!.filter(){$0.name == fileName
                            }).first
                        {
                            
                            let index = self.downloadInfoArr?.indexOf{$0.name == downloadModel.name}
                            downloadModel.downloadStatus = .Failed
                            self.downloadInfoArr![index!] = downloadModel
                        }
                    }
                    catch {
                        print("Error while retreiving json value: didCompleteWithError \(error)")
                    }
                 }
                }
                index += 1
            }
        }
    }
    
    
    func copyResumableData(userInfo:[String:AnyObject],downloadObject:DownloadInfo,index:Int)
    {
//        var downloadModel = downloadObject
//            downloadModel.downloadStatus = .Failed
//            var resumeData: NSData? = userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
//            
//            let task = downloadModel.downloadtask
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                {
//                    (data) -> Void in
//                    let resumableData:NSData = resumeData!
//                    let pathURL = NSURL(fileURLWithPath: self.directoryPathForResumeData.stringByAppendingPathComponent(downloadModel.name!))
//                    downloadModel.downloadDataURL = pathURL
//                    let bool = resumableData.writeToURL(pathURL!, atomically: true)
//                    print("copy \(bool)")
//                    self.downloadInfoArr![index] = downloadModel
//            })
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession)
    {
        let appDelegate:AZAppDelegate = UIApplication.sharedApplication().delegate as! AZAppDelegate
        
         let completetionHandler = appDelegate.bgDCHandler
         appDelegate.bgDCHandler = nil
         completetionHandler!()
        //
    }
    
    func clearResumeData(url:NSURL)
    {
        
//        let error = NSErrorPointer()
//        NSFileManager.defaultManager().removeItemAtURL(url, error:error)
    }
    
}






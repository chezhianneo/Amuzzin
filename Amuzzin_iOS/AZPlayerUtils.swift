//
//  AZPlayerUtils.swift
//  Amuzzin_iOS
//
//  Created by 01HW842980 on 21/05/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


extension Array {
    func find <L : BooleanType>(predicate: Element -> L) -> Element? {
        for item in self {
            if predicate(item) {
                return item // found
            }
        }
        return nil // not found
    }
}
extension String
{
    func getCharactersForIndex(int:Int)->String
    {
        if self.characters.count > int {
        let index = self.startIndex.advancedBy(int)
        let subString = self.substringToIndex(index)
        return subString
        }
        return ""
    }
    
    func addExtensionToString(ext:String)->String?
    {
        let extentStr = self as NSString
        return extentStr.stringByAppendingPathExtension(ext)
    }
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        
        let nsSt = self as NSString  
        
        return nsSt.stringByAppendingPathExtension(ext)  
    }
    
}

class AZPlayerUtils: NSObject
{

    
    class func setAVPLayerMetaDataItem(url:NSURL) -> AZPlayerItemModel?
    {
    let azplayerItem = AZPlayerItemModel()
    let avAsset = AVURLAsset(URL: url, options: nil)
        azplayerItem.duration =  getTimefromCMTime(avAsset.duration)
        azplayerItem.avplayerURL = url
        let yearKey = -1453039239
        let genreKey = -1452841618
        let encoderKey = -1451987089
        let trackKey = "com.apple.iTunes.iTunes_CDDB_TrackNumber"
        let CDDBKey = "com.apple.iTunes.iTunes_CDDB_1"
     
       for format in avAsset.availableMetadataFormats
       {
        
        for item:AVMetadataItem in avAsset.metadataForFormat(format as! String) as! Array<AVMetadataItem> {
            
            if let key = item.commonKey { if key == "title" {// println("Title: \(item.value)")
                azplayerItem.songTitle = item.value as? String } }
            if let key = item.commonKey { if key == "artist" { //println("artist: \(item.value)")
                azplayerItem.artists = item.value as? String } }
            if let key = item.commonKey { if key == "albumName" { //println("albumName: \(item.value)")
                azplayerItem.albumName = item.value as? String } }
            if let key = item.commonKey { if key == "creator" { //println("creationDate: \(item.value)")
                azplayerItem.albumArtist = item.value as? String } }
           
//            if item.keySpace == AVMetadataID3MetadataKeyLength {
//                var img = UIImage()
//                if item.keySpace == AVMetadataKeySpaceID3
//                {
//                    img = UIImage(data: item.dataValue)!
//                }
//                }
//            else
//            {

//            }

//            if item.key.isKindOfClass(NSNumber) {
//                if item.key as? NSNumber == yearKey { //println("year: \(item.numberValue)") 
//                }
//                if item.key as? NSNumber == genreKey { //println("genre: \(item.stringValue)") 
//                }
//                if item.key as? NSNumber == encoderKey { //println("encoder: \(item.stringValue)") 
//                }
//            }
//            
//            if item.key.isKindOfClass(NSString) {
//                if item.key as! String == trackKey { //println("track: \(item.stringValue)") 
//                }
//                if item.key as! String == CDDBKey { //println("CDDB: \(item.stringValue)")
//                }
//            }
        }
        


       }
        
    return azplayerItem
    }
    
    class func getTimefromCMTime(time:CMTime!) -> String
    {
        
        let dTotalSeconds = CMTimeGetSeconds(time);
        
        let dHours:Int = Int(floor(dTotalSeconds / 3600))
        let dMinutes:Int = Int(floor(dTotalSeconds % 3600 / 60))
        let dSeconds:Int = Int(floor(dTotalSeconds % 3600 % 60))
        
        return dHours > 0 ? "\(dHours).\(dMinutes).\(dSeconds)" : "\(dMinutes).\(dSeconds)"
    }
    
    class func getTimeFromNstimeInterval(sec:Int) -> String
    {
        let dMinutes:Int = sec % 3600 / 60
        let dSeconds:Int = sec % 3600 % 60
        
        return "\(dMinutes).\(dSeconds)"

    }
    
    
    private class func getImageForSongForUrl(stringURL:NSURL?)->UIImage?
    {
        let directoryArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let directoryPath = directoryArray.first! as String
        
        let toArray:[AnyObject] = stringURL!.absoluteString.componentsSeparatedByString("/")
        var azcurrentPlayerString = directoryPath + "/" + (toArray.last as! String)
        let URL = NSURL(fileURLWithPath: azcurrentPlayerString)
        let avAsset = AVURLAsset(URL: URL, options: nil)
        let artWorks = AVMetadataItem.metadataItemsFromArray(avAsset.commonMetadata, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon) 
        
        for item:AVMetadataItem in artWorks
        {
            if let key = item.keySpace
            {
                if key == AVMetadataKeySpaceID3 || key == AVMetadataKeySpaceiTunes
                {
                    return UIImage(data: item.dataValue!)
                    
                }
            }
            else
            {
                return UIImage(named: "album-art-missing")

            }
        }
        return UIImage(named: "album-art-missing")
    }
    
    private class func getImageForID(stringID:String?)->UIImage?
    {
        let songQuery = MPMediaQuery()
        
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: stringID, forProperty: MPMediaItemPropertyPersistentID))
        let songArray = songQuery.items! as [MPMediaItem]
        let songItem:MPMediaItem = songArray.first! as MPMediaItem

        if let mpArtWork = songItem.valueForProperty(MPMediaItemPropertyArtwork)  as? MPMediaItemArtwork
        {
            let newSize = mpArtWork.imageCropRect.size
            let artwork:UIImage = mpArtWork.imageWithSize(newSize)!
            
            return artwork
        }
        return nil
    }
    
    class func getImageForSongModel(model:AZPlayerItemModel) -> UIImage
    {
        if let songID = model.songID
        {
            if  songID.getCharactersForIndex(2) == "SD"
            {
                return self.getImageForSongForUrl(model.avplayerURL)!
            }
            else
            {
                return self.getImageForID(model.songID)!
                
            }
        }
        return UIImage(named: "album-art-missing")!
    }
    
    class func getUniqueFileNameWithPath(filePath : String) -> String {
        var fullFileName        : String = filePath.lastPathComponent
        var fileName            : String = fullFileName.stringByDeletingPathExtension
        var fileExtension       : String = fullFileName.pathExtension
        var suggestedFileName   : String = fileName
        
        var isUnique            : Bool = false
        var fileNumber          : Int = 0
        
        var fileManger          : NSFileManager = NSFileManager.defaultManager()
        
        repeat {
            var fileDocDirectoryPath : String?
            
            if fileExtension.characters.count > 0 {
                fileDocDirectoryPath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName).\(fileExtension)"
            } else {
                fileDocDirectoryPath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName)"
            }
            
            var isFileAlreadyExists : Bool = fileManger.fileExistsAtPath(fileDocDirectoryPath! as String)
            
            if isFileAlreadyExists {
                fileNumber++
                suggestedFileName = "\(fileName)(\(fileNumber))"
            } else {
                isUnique = true
                if fileExtension.characters.count > 0 {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)"
                }
            }
            
        } while isUnique == false
        
        return suggestedFileName
    }
    
    class func calculateFileSizeInUnit(contentLength : Int64) -> Float
    {
        var dataLength : Float64 = Float64(contentLength)
        if dataLength >= (1024.0*1024.0*1024.0) {
            return Float(dataLength/(1024.0*1024.0*1024.0))
        } else if dataLength >= 1024.0*1024.0 {
            return Float(dataLength/(1024.0*1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength/1024.0)
        } else {
            return Float(dataLength)
        }
    }
    
    class func calculateUnit(contentLength : Int64) -> String
    {
        if(contentLength >= (1024*1024*1024)) {
            return "GB"
        } else if contentLength >= (1024*1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
    
    class func addSkipBackupAttributeToItemAtURL(docDirectoryPath : String) -> Bool
    {
        let url : NSURL = NSURL(fileURLWithPath: docDirectoryPath as String)
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) {
            do {
                try url.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
                return true
            } catch {
                print("Error excluding \(url.lastPathComponent) from backup \(error)")
            }
        }
        return false
    }
    
    class func getFreeDiskspace() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        do {
            let systemAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(documentDirectoryPath.last!)
                if let freeSize = systemAttributes[NSFileSystemFreeSize] as? NSNumber {
                    return freeSize.longLongValue
            }
        } catch  {
            print("Error Obtaining System Memory Info: Domain = \(error), Code = \(error)")

        }
        return nil
}
}


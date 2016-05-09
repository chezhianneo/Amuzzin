    //
//  AZMediaManager.swift
//  Amuzzin_iOS
//
//  Created by 01HW842980 on 22/05/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

struct AlbumSectionModel
{
    var albumName:String
    var albumArtist:String
    var albumCount:String
    var totalMinutes:String
    var albumID:AnyObject
}


class AZMediaManager: NSObject
{
    
    var arrAlbums:[AnyObject]?
    var currentFolder:NSURL?
    var downloadedSongsArr:[AZPlayerItemModel]?
    var mediaManagedModel:[NSManagedObject]?
    var songLibDict:Dictionary<String,[AZPlayerItemModel]>?
    var albumLibDict:Dictionary<String,[AlbumSectionModel]>?
    var artistLibDict:Dictionary<String,[AlbumSectionModel]>?
    var genreLibDict:Dictionary<String,[AlbumSectionModel]>?
    
    class var sharedInstance: AZMediaManager {
        struct Static {
            static var instance : AZMediaManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AZMediaManager()
        }
        
        return Static.instance!
    }
    
    override init()
    {
        super.init()
        downloadedSongsArr = [AZPlayerItemModel]()
        songLibDict = Dictionary<String,[AZPlayerItemModel]>()
        mediaManagedModel = [NSManagedObject]()
        albumLibDict = Dictionary<String,[AlbumSectionModel]>()
        
    }
    
    
    func loadSongLibrary()
    {
        self.songLibDict?.removeAll(keepCapacity: false)
        let songQuery = MPMediaQuery.songsQuery()
        let songArray = songQuery.items
        for songItem in  songArray!
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
            //     azplayerItemModel.year = songItem.valueForProperty(MPMediaItemPropertyReleaseDate) as? NSDate
            azplayerItemModel.avplayerURL = songItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
            azplayerItemModel.songID = String(stringInterpolationSegment: songItem.valueForProperty(MPMediaItemPropertyPersistentID))
            
            var indexStr = songTitle!.getCharactersForIndex(0).uppercaseString
            if indexStr == "="
            {
                indexStr = "0"
            }
            
            if self.songLibDict![indexStr] != nil {
                self.songLibDict![indexStr]!.append(azplayerItemModel)
            }
            else {
                self.songLibDict![indexStr] = [azplayerItemModel]
            }
        }
    }

    
    func loadAlbumLibrary()
    {
                self.albumLibDict?.removeAll(keepCapacity: false)
                let albumQuery = MPMediaQuery.albumsQuery()
                let albumArray = albumQuery.collections
                for album in  albumArray!
                {
                    let albumItem:MPMediaItem = album.representativeItem!
                    let name = albumItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
                    let id =   albumItem.valueForProperty(MPMediaItemPropertyPersistentID)
                    var artist:String

                    if let albumArtsit: String = albumItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as? String
                    {
                        artist = albumArtsit
                    }
                    else
                    {
                        artist = ""
                    }

                    let minutes = String(0)
                    let songQuery = MPMediaQuery.albumsQuery()
                    songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .EqualTo))
                    let count = String(songQuery.items!.count)
                    
                    let albumModel = AlbumSectionModel(albumName: name, albumArtist: artist, albumCount: count, totalMinutes: minutes, albumID: id!)
                    let startIndex = name.startIndex
                    let endIndex = name.getCharactersForIndex(1)
                    var indexStr = name.getCharactersForIndex(1).uppercaseString
                    
                    if indexStr == "="
                    {
                        indexStr = "0"
                    }
                    

                    
                    
                    if let array = self.albumLibDict![indexStr]
                    {
                        self.albumLibDict![indexStr]!.append(albumModel)
                    }
                    else
                    {
                        self.albumLibDict![indexStr] = [albumModel]
                    }
                    
                    
                }

        
    }
    
    func saveDownloadedSongs(info:DownloadInfo)
    {

            let azplayerItem = AZPlayerUtils.setAVPLayerMetaDataItem(info.downloadDataURL! as NSURL)
            azplayerItem?.songID = "SD"+NSUUID().UUIDString
            self.saveSongs(azplayerItem)
        
    }
    
    func loadSongsFromDownloadedPath()
    {
        self.downloadedSongsArr?.removeAll(keepCapacity: false)
        self.arrAlbums?.removeAll(keepCapacity: false)
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Offlinesongs")
        
        //3
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            for result in fetchedResults {
                let songItemModel = AZPlayerItemModel()
                
                songItemModel.artists = result.valueForKey("artists") as? String
                songItemModel.duration = result.valueForKey("duration") as? String
                songItemModel.genreName = result.valueForKey("genreName") as? String
                songItemModel.avplayerURL = NSURL(string: (result.valueForKey("avplayerURL") as! String))
                songItemModel.songID = result.valueForKey("songID") as? String
                songItemModel.songTitle = result.valueForKey("songTitle") as? String
                //songItemModel.year = result.valueForKey("year") as? String
                songItemModel.lyrics = result.valueForKey("lyrics") as? String
                songItemModel.albumName = result.valueForKey("albumName") as? String
                songItemModel.albumArtist = result.valueForKey("albumArtist") as? String
                self.downloadedSongsArr?.append(songItemModel)
            }
        } catch {
            print(error);
        }
    }
    
    func saveSongs(downloadModel:AZPlayerItemModel?)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        
        let entityObject =  NSEntityDescription.entityForName("Offlinesongs",
            inManagedObjectContext:
            managedContext)
        
        let songObject = NSManagedObject(entity: entityObject!,
            insertIntoManagedObjectContext:managedContext)
        
        songObject.setValue(downloadModel?.artists, forKey: "artists")
        songObject.setValue(downloadModel?.duration, forKey: "duration")
        songObject.setValue(downloadModel?.genreName, forKey: "genreName")
        songObject.setValue(downloadModel?.avplayerURL?.absoluteString, forKey: "avplayerURL")
        songObject.setValue(downloadModel?.songID, forKey: "songID")
        songObject.setValue(downloadModel?.songTitle, forKey: "songTitle")
        songObject.setValue(downloadModel?.year, forKey: "year")
        songObject.setValue(downloadModel?.lyrics, forKey: "lyrics")
        songObject.setValue(downloadModel?.albumName, forKey: "albumName")
        songObject.setValue(downloadModel?.albumArtist, forKey: "albumArtist")
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }

        mediaManagedModel!.append(songObject)
    }
    
    func addSongToCurrentPlayer()
    {
     //   let url = self.readDownloadedSongsFromFolder("04 Mental Manadhil")
     //   let azplayerItem = AZPlayerUtils.setAVPLayerMetaDataItem(url)
     //   AZMuiscPlayer.sharedInstance.arrPlayerURL?.append(azplayerItem!)
        
    }
    
    private func urlForKey(key: String) -> NSURL {
        let fileName = key.stringByAppendingPathExtension("archive")
        return currentFolder!.URLByAppendingPathComponent(fileName!)
    }
    
    
    private func constructDictionary(title:String,arrayItem:AnyObject,dict:Dictionary<String,[AnyObject]>) -> Dictionary<String,[AnyObject]>
    {
        var newDict = dict
        
        let indexStr = title.getCharactersForIndex(1)

        newDict[indexStr]!.append(arrayItem)
        return newDict
    }

}

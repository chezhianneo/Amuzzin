//
//  AZPlaylistMsnager.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 06/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer


struct PlaylistModel
{
   var name:String
    var id:String
}

class AZPlaylistManager: NSObject
{
    var playlistArr:[PlaylistModel]?
    var playlistDataModel:[NSManagedObject]?
    var playlistCount:Int?
    var playlistSongsArr:[AZPlayerItemModel]?
 

    class var sharedInstance: AZPlaylistManager {
        struct Static {
            static var instance : AZPlaylistManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AZPlaylistManager()
        }
        
        return Static.instance!
    }
    
    override init()
    {
        super.init()
        playlistArr = [PlaylistModel]()
        playlistDataModel = [NSManagedObject]()
        playlistSongsArr = [AZPlayerItemModel]()
        self.playlistCount = 0
    }
    
    func getPlaylist(completion:(() -> ())?)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("PlaylistSongs", inManagedObjectContext: managedContext)
          fetchRequest.entity = entity
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.propertiesToFetch = ["playlistID","playlistName"]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults:Array = try managedContext.executeFetchRequest(fetchRequest)
            self.playlistCount = fetchedResults.count
            self.playlistArr?.removeAll(keepCapacity: false)
            
            for result in fetchedResults as! Array<NSDictionary>
            {
                let playlistID = result.valueForKey("playlistID") as? String
                let playlistNameStr = result.valueForKey("playlistName") as? String
                let playlistModel = PlaylistModel(name: playlistNameStr!, id: playlistID!)
                
                self.playlistArr?.append(playlistModel)
            }
        } catch {
            print(error)
        }
        
        if let completionHandler = completion
        {
            completionHandler()
        }

    }
    
    
    func deletePlaylistEntity(playlistID:String)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"PlaylistSongs")
        
        let predicate =  NSPredicate(format: "playlistID = %@", playlistID)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            for result in fetchedResults {
                managedContext.deleteObject(result as! NSManagedObject)
            }
        } catch {
            print("Could not save \(error)")
        }
        //self.playlistCount = fetchedResults.count
        do {
             try managedContext.save()
        } catch {
            print("Could not save \(error)")

        }
    }
    
    func reorderSongsatIndexPath(playlistID:String,sourceIndex:Int,destinationIndex:Int)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"PlaylistSongs")
        
        let sortdescriptor = NSSortDescriptor(key: "playlistID", ascending: false)
        fetchRequest.sortDescriptors = [sortdescriptor]
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: "temp")
        do {
            try fetchedController.performFetch()
            var array:[AnyObject] = fetchedController.fetchedObjects!
            let moveIndex: NSManagedObject = array[sourceIndex] as! NSManagedObject
            array.removeAtIndex(sourceIndex)
            array.insert(moveIndex, atIndex:destinationIndex )
        }
        catch {
            print("Could not save \(error)")
        }
        
        let context = fetchedController.managedObjectContext
        
        do {
            try context.save()
        }
        catch {
            print("Could not save \(error)")
        }
    }
    
    
    func addSongstoPlaylist(songArr:[AZPlayerItemModel],playlistID:String,playlistName:String)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("PlaylistSongs",
            inManagedObjectContext:
            managedContext)
        
        var playlistNewID:String = playlistID
        
        if playlistNewID == "" {
            playlistNewID = "PL" + NSUUID().UUIDString
        }
        
        for songItem:AZPlayerItemModel in songArr {
            let songID = songItem.songID
            let insertObject = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)

        insertObject.setValue(playlistNewID, forKey: "playlistID")
        insertObject.setValue(songID, forKey: "songID")
        insertObject.setValue(playlistName.capitalizedString, forKey: "playlistName")

        playlistDataModel!.append(insertObject)

        }
        do {
            try managedContext.save()
        }
        catch {
            print("Could not save \(error)")
        }
    }
    
    func getAddedSongsinPlaylist(playlistID:String)
    {
        self.playlistSongsArr?.removeAll(keepCapacity: false)
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"PlaylistSongs")

        let predicate =  NSPredicate(format: "playlistID = %@", playlistID)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults:Array = try managedContext.executeFetchRequest(fetchRequest)
            for result in fetchedResults {
                if let songID = ((result.valueForKey("songID") as? String)) {
                    if  songID.getCharactersForIndex(2) == "SD" {
                        getSongFromforSongID(songID)
                    }
                    else {
                        getSongsFromLibraryForID(songID)
                    }
                }
            }
        }
        catch {
            
        }
    }


    func getSongFromforSongID(songID:String) {
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AZAppDelegate
    
    let managedContext = appDelegate.managedObjectContext!
    
    //2
    let fetchRequest = NSFetchRequest(entityName:"Offlinesongs")
    
    let predicate =  NSPredicate(format: "songID = %@", songID)
    fetchRequest.predicate = predicate

    do {
        let fetchedResults:Array = try managedContext.executeFetchRequest(fetchRequest)
        for result in fetchedResults {
            let songItemModel = AZPlayerItemModel()
            
            songItemModel.artists = result.valueForKey("artists") as? String
            
            songItemModel.duration = result.valueForKey("duration") as? String
            songItemModel.genreName = result.valueForKey("genreName") as? String
            songItemModel.avplayerURL = NSURL(string: (result.valueForKey("avplayerURL") as! String))
            songItemModel.songID = result.valueForKey("songID") as? String
            songItemModel.songTitle = result.valueForKey("songTitle") as? String
            songItemModel.year = result.valueForKey("year") as? String
            songItemModel.lyrics = result.valueForKey("lyrics") as? String
            songItemModel.albumName = result.valueForKey("albumName") as? String
            songItemModel.albumArtist = result.valueForKey("albumArtist") as? String
            
            self.playlistSongsArr?.append(songItemModel)
        }
    }
    catch {
        print("Get Song DB Error\(error)")
    }
   }
    
    func getSongsFromLibraryForID(stringID:String) {
       
        let songQuery = MPMediaQuery()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: stringID, forProperty: MPMediaItemPropertyPersistentID))
        let songArray = songQuery.items
        if let songItem: MPMediaItem = (songArray?.first)! as MPMediaItem
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
            self.playlistSongsArr?.append(azplayerItemModel)

        }

    }

}


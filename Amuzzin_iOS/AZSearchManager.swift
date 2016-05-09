//
//  AZSearchManager.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 09/07/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class AZSearchManager: NSObject {
    var searchAlbumArray:[AlbumModel]?
    var searchSongArray:[AZPlayerItemModel]?
    var searchArtistsArray:[ArtistModel]?
    var searchDataModel:NSManagedObject?
    var albumNameArray = [String]()
    
    
    
    class var sharedInstance: AZSearchManager {
        struct Static {
            static var instance : AZSearchManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AZSearchManager()
        }
        
        return Static.instance!
    }
    
    override init()
    {
        super.init()
        searchDataModel =  NSManagedObject()
        searchSongArray    = [AZPlayerItemModel]()
        searchArtistsArray = [ArtistModel]()
        searchAlbumArray   = [AlbumModel]()
        
    }
    
    func searchForText(searchText:String)
    {
        self.searchSongArray?.removeAll(keepCapacity: false)
        self.searchArtistsArray?.removeAll(keepCapacity: false)
        self.searchAlbumArray?.removeAll(keepCapacity: false)
        
        self.getSongFromforSongID(searchText)
        self.getSongsFromLibraryForID(searchText)
        self.getAlbumFromforText(searchText)
        self.getAlbumFromLibraryforText(searchText)
        self.getArtistsFromLibraryforText(searchText)
        self.albumNameArray.removeAll(keepCapacity: false)
        
    }
    
    
    func getSongFromforSongID(songText:String)
    {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Offlinesongs")
        let predicate =  NSPredicate(format: "songTitle CONTAINS[cd] %@", songText)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            for result in fetchedResults
            {
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
                
                self.searchSongArray?.append(songItemModel)
            }

        }
        catch {
            print("Error in Executing Query:\(error)")
        }
    }
    
    
    func getAlbumFromforText(albumText:String)
    {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AZAppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Offlinesongs")
        let predicate =  NSPredicate(format: "albumName CONTAINS[cd] %@", albumText)
        fetchRequest.predicate = predicate
        
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.propertiesToFetch = ["albumName","albumArtist","avplayerURL"]
        fetchRequest.returnsDistinctResults = true
        
        //3
        do {
        let fetchedResults:NSArray =
        try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        var albumNameArray = [String]()
        for result in fetchedResults as! Array<NSDictionary> {
            if albumNameArray.contains(result.valueForKey("albumName") as! String) == false
            {
                var albumItemModel = AlbumModel()
                albumItemModel.albumName = result.valueForKey("albumName") as? String
                albumItemModel.albumArtist = result.valueForKey("albumArtist") as? String
                albumNameArray.append(albumItemModel.albumName!)
                albumItemModel.albumURLArtWork = NSURL(string:result.valueForKey("avplayerURL") as! String)
                self.searchAlbumArray?.append(albumItemModel)
            }
        }
        }
        catch {
            print("Get Album Error\(error)")
        }
        
        
    }
    
    func getAlbumFromLibraryforText(albumText:String)
    {
        let albumQuery = MPMediaQuery()
        albumQuery.addFilterPredicate(MPMediaPropertyPredicate(value: albumText, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.Contains))
        let albumArray = albumQuery.collections
        var albumNameArray = [String]()
        
        for albumModel in albumArray!
        {
            
            let albumItem = albumModel.representativeItem! as MPMediaItem
            if albumNameArray.contains((albumItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String)) == false
            {
                var albumItemModel = AlbumModel()
                albumItemModel.albumArtist = albumItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as? String
                
                albumItemModel.albumName = albumItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String
                albumNameArray.append(albumItemModel.albumName!)
                albumItemModel.albumID = String(stringInterpolationSegment: albumItem.valueForProperty(MPMediaItemPropertyAlbumPersistentID))
                self.searchAlbumArray?.append(albumItemModel)
            }
        }
        
    }
    
    
    func getArtistsFromLibraryforText(artistsText:String)
    {
        let artistQuery = MPMediaQuery()
        artistQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistsText, forProperty: MPMediaItemPropertyAlbumArtist, comparisonType: MPMediaPredicateComparison.Contains))
        let artistArray = artistQuery.collections
        for artistModel in artistArray!
        {
            if (self.searchArtistsArray!.filter(){$0.artistName == (artistModel.valueForProperty(MPMediaItemPropertyAlbumArtist) as? String)}).count == 0
            {
                let artistItem = artistModel.representativeItem! as MPMediaItem
                var artistItemModel = ArtistModel()
                
                artistItemModel.artistName = artistItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as? String
                artistItemModel.artistID = String(stringInterpolationSegment: artistItem.valueForProperty(MPMediaItemPropertyAlbumArtistPersistentID))
                self.searchArtistsArray?.append(artistItemModel)
            }
        }
    }
    
    
    func getSongsFromLibraryForID(songText:String)
    {
        let songQuery = MPMediaQuery()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: songText, forProperty: MPMediaItemPropertyTitle, comparisonType: MPMediaPredicateComparison.Contains))
        let songArray = songQuery.items
        for songItem in songArray!
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
            self.searchSongArray?.append(azplayerItemModel)
            
        }
        
    }
    
}

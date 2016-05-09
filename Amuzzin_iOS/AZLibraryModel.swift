//
//  AZLibraryModel.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 27/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

struct SongSectionModel:NSObject
{
    var sectionName:String
    var songModel:[AZPlayerItemModel]
}

struct AlbumDisplayModel
    {
        var sections:[AlbumSectionModel]?
        var sectionCount:[Int]
        var sectionName:[String]?
    }

struct AlbumModel
{
    var albumID:String?
    var albumName:String?
    var albumCount:[Int]?
    var albumSongs:[AZPlayerItemModel]?
    var albumArtist:String?
    var albumURLArtWork:NSURL?
}

struct ArtistModel
{
    var artistID:String?
    var artistName:String?
    var artistCount:[Int]?
    var artistSongs:[AZPlayerItemModel]?
}

struct GenreModel
{
    var genreID:String?
    var genreName:String?
    var genreCount:[Int]?
    var genreSongs:[AZPlayerItemModel]?
}


struct SongListModel
{
    var sections:[String]
    var songinSectionsArr:[AZPlayerItemModel]
}


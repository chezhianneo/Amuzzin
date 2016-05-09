//
//  AZPlayerItemModel.swift
//  Amuzzin_iOS
//
//  Created by 01HW842980 on 21/05/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AZPlayerItemModel: NSObject
{
    var songTitle:String?
    var albumName:String?
    var genreName:String?
    var year:String?
    var lyrics:String?
    var duration:String?
    var albumArtist:String?
    var artists:String?
    var avplayerURL:NSURL?
    var favTag:String?
    var songID:String?
    
    override init()
    {
        self.songTitle = ""
        self.albumArtist = ""
        self.albumName = ""
        self.genreName = ""
        self.year = ""
        self.lyrics = ""
        self.duration = ""
        self.artists = ""
        self.avplayerURL = nil
    }
    

    
    
}


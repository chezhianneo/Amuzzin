//
//  AZSingleton.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 23/03/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZSingleton: NSObject
{
    
    var arrAlbums:[AnyObject]?
    var arrSongs:[AnyObject]?

    class var sharedInstance: AZSingleton {
        struct Static {
            static var instance : AZSingleton?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AZSingleton()
        }
        
        return Static.instance!
    }
    
    
}

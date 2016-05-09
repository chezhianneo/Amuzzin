//
//  SharedStorage.swift
//  Citibank
//
//  Created by Tony Kambourakis on 27/12/2014.
//  Copyright (c) 2014 Citigroup. All rights reserved.
//

import Foundation
import UIKit

class SharedStorage {
    
    let cacheFolder: NSURL


    init() {
        
        var availableCacheFolder = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("SHAREDSTORAGESUITENAME")
        #if (arch(i386) || arch(x86_64))
            if (availableCacheFolder == nil)
            {
                do
                {
                    availableCacheFolder = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
                }
                catch let error as NSError
                {
                   print("File Read Error" + error.description)
                }
            }
        #endif
        #if DEBUG
            cacheFolder = availableCacheFolder ?? NSURL()
            #else
            cacheFolder = availableCacheFolder!
        #endif
        
    }

    class var sharedInstance : SharedStorage {
        
        struct Singleton {
            static let instance = SharedStorage()
        }
        return Singleton.instance
    }
    

    
    func removeObjectForKey(objectKey : String) -> Bool {
        // Check if the object requested exists in Shared Storage
        do{
            try NSFileManager.defaultManager().removeItemAtURL(urlForKey(objectKey))
        }
        catch let error as NSError{
          print("RemoveObject error \(error)")
        }
        return true
    }
    
    private func urlForKey(key: String) -> NSURL {
        let fileName = key.addExtensionToString("archive")
        return cacheFolder.URLByAppendingPathComponent(fileName!)
    }
  
}
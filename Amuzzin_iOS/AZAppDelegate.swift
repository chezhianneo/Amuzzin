//
//  AppDelegate.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 02/02/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation


@UIApplicationMain
class AZAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bgDCHandler:BackGroundTaskCompletionHandler?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        let defaults =  NSUserDefaults.standardUserDefaults()
//        defaults.setObject(nil, forKey: "AZDownloadQueue")
//        defaults.synchronize()
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions:.DefaultToSpeaker)
        } catch {
            
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey("notFirstTimeLaunch") == false
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstTimeLaunch")
        }
        // Override point for customization after application launch.
        UIApplication.sharedApplication().registerForRemoteNotifications()
       // let uinavigation:UINavigationBar = UINavigationBar.appearance()
       // UITabBar.appearance().barTintColor = UIColor.whiteColor()
        
        return true
    }
    
     func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void)
    {
        self.bgDCHandler = completionHandler
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication)
    {

        if let object = AZDownloadManager.sharedInstance.downloadInfoArr where object.count > 0
        {
           let data = NSKeyedArchiver.archivedDataWithRootObject(object)
           let defaults =  NSUserDefaults.standardUserDefaults()
            defaults.setObject(data, forKey: "AZDownloadQueue")
            defaults.synchronize()
        }
        else
        {
            let defaults =  NSUserDefaults.standardUserDefaults()
            defaults.setObject(nil, forKey: "AZDownloadQueue")
            defaults.synchronize()
            print("Queue Cleared")

        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    

    //MARK:Core Data methods
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.chezhian.sample.hello" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Amuzzin", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Amuzzin.sqlite")
        print(self.applicationDocumentsDirectory)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            // Report any error we got.

            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        } catch {
            coordinator = nil
         print("Failed to load Application Data \(error)")
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                try moc.save()
                } catch {
                    print("Unresolved error \(error)")
                }
            }
            
        }
    }
    
}



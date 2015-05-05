//
//  dao.swift
//  CoreDataTry
//
//  Created by Timothy on 15/5/5.
//  Copyright (c) 2015年 t. All rights reserved.
//

import Foundation
import CoreData

class CoreDataAdapter{
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL  = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ibm.mobilefirst.insurance.riskinspector" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CoreDataTry", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // Check if running as test or not
        let environment = NSProcessInfo.processInfo().environment as! [String:AnyObject]
        let isTest = (environment["XCInjectBundle"] as? String)?.pathExtension == "xctest"
        
        // Create the module name
        let moduleName = (isTest) ? "CoreDataTryTests" : "CoreDataTry"
        
        // Create a new managed object model with updated entity class names
        var newEntities = [] as [NSEntityDescription]
        for (_, entity) in enumerate(managedObjectModel.entities) {
            let newEntity = entity.copy() as! NSEntityDescription
            newEntity.managedObjectClassName = "\(moduleName).\(entity.name)"
            newEntities.append(newEntity)
        }
        let newManagedObjectModel = NSManagedObjectModel()
        newManagedObjectModel.entities = newEntities
        
        return newManagedObjectModel
        } ()
    
    
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        
        get {
            if _persistentStoreCoordinator != nil {
                return _persistentStoreCoordinator
            }
            
            // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
            // Create the coordinator and store
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            
            let url = applicationDocumentsDirectory.URLByAppendingPathComponent("coreDataTry.sqlite")
            let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
            println(url)
            
            var error: NSError? = nil
            
            if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options,
                error: &error) == nil {
                    
                    _persistentStoreCoordinator = nil
                    
                    var rerror: NSError? = nil
                    NSFileManager.defaultManager().removeItemAtURL(url, error: &rerror) // remove the model and try again
                    if rerror == nil {
                        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                        var rperror: NSError? = nil
                        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("coreDataTry.sqlite")
                        
                        if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &rperror) == nil {
                            println("Unresolved error \(error), \(error!.userInfo)")
                            abort() // giving up
                        }
                    }
                    
            }
            return _persistentStoreCoordinator
        }
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    
    var managedObjectContext: NSManagedObjectContext? {
        
        get {
            if _managedObjectContext != nil {
                return _managedObjectContext
            }
            
            // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            let coordinator = persistentStoreCoordinator
            if coordinator == nil {
                return nil
            }
            _managedObjectContext = NSManagedObjectContext()
            _managedObjectContext?.persistentStoreCoordinator = coordinator
            return _managedObjectContext
        }
    }
    
    var _managedObjectContext: NSManagedObjectContext?
    
}

class DataManager {
    
    
    var coreData: CoreDataAdapter!
    
    struct Static  {
        static var onceToken: dispatch_once_t = 0
    }
    
    class var sharedInstance: DataManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = self()
            
        }
        return Static.instance!
    }
    
    required init() {
        coreData = CoreDataAdapter()
    }
    
    // MARK: - Core Data Saving support
    func rollbackContext () {
        if let moc = coreData.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                moc.rollback()
            }
        }
    }
    
    func saveContext () {
        if let moc = coreData.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    class func resetPersistentStore() {
        
        let manager = NSFileManager.defaultManager()
        
        for mediaType in ["Audio", "Notes", "Photos"] {
            
            let paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let folderPath = paths.stringByAppendingPathComponent(mediaType)
            
            if (manager.fileExistsAtPath(folderPath)){
                manager.removeItemAtPath(folderPath, error: nil)
            }
            
        }
        
        let url = DataManager.sharedInstance.coreData.applicationDocumentsDirectory.URLByAppendingPathComponent("riskinspector.sqlite")
        var error: NSError? = nil
        NSFileManager.defaultManager().removeItemAtURL(url, error: &error) // remove the model
        if error != nil {
            println("Error \(error), \(error!.userInfo)")
        }
        
        DataManager.sharedInstance.coreData._managedObjectContext = nil
        DataManager.sharedInstance.coreData._persistentStoreCoordinator = nil
        
}
}
    
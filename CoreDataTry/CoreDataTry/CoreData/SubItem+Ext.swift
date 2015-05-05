//
//  SubItem+Ext.swift
//  CoreDataTry
//
//  Created by Timothy on 15/5/5.
//  Copyright (c) 2015年 t. All rights reserved.
//

import Foundation
import CoreData

extension SubItem {
    
    class func subItemInStore() -> [SubItem]? {
        
        var subItems: [SubItem]?
        
        let moc = DataManager.sharedInstance.coreData.managedObjectContext
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("SubItems", inManagedObjectContext: moc!)
        fetchRequest.entity = entity
        
        var error: NSError? = nil
        subItems = moc?.executeFetchRequest(fetchRequest, error: &error) as? [SubItem]
        
        if subItems?.count == 0 {
            subItems = nil
        }
        
        return subItems
    }
    
    
}
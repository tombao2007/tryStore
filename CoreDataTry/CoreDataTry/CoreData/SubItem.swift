//
//  SubItem.swift
//  
//
//  Created by Timothy on 15/5/5.
//
//

import Foundation
import CoreData

class SubItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var insideOrder: Int64
    @NSManaged var content: String
    @NSManaged var item: NSManagedObject

}

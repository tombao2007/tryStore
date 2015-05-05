//
//  Item.swift
//  
//
//  Created by Timothy on 15/5/5.
//
//

import Foundation
import CoreData

class Item: NSManagedObject {

    @NSManaged var itemID: String
    @NSManaged var subItem: SubItem
    @NSManaged var itemList: ItemList

}

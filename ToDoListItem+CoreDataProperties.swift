//
//  ToDoListItem+CoreDataProperties.swift
//  CoreDataExample
//
//  Created by Prapti on 03/04/24.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var completed: Bool

}

extension ToDoListItem : Identifiable {

}

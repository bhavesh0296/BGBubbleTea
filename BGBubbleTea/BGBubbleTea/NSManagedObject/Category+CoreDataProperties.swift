//
//  Category+CoreDataProperties.swift
//  BGBubbleTea
//
//  Created by bhavesh on 20/06/21.
//  Copyright © 2021 Bhavesh. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryID: String?
    @NSManaged public var name: String?
    @NSManaged public var venue: Venue?

}

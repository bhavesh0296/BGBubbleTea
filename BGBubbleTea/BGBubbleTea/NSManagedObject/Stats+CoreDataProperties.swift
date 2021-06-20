//
//  Stats+CoreDataProperties.swift
//  BGBubbleTea
//
//  Created by bhavesh on 20/06/21.
//  Copyright © 2021 Bhavesh. All rights reserved.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var tipCount: Int32
    @NSManaged public var usersCount: Int32
    @NSManaged public var checkinsCount: Int32
    @NSManaged public var venue: Venue?

}

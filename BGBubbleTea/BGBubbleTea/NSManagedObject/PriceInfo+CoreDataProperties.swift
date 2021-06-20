//
//  PriceInfo+CoreDataProperties.swift
//  BGBubbleTea
//
//  Created by bhavesh on 20/06/21.
//  Copyright © 2021 Bhavesh. All rights reserved.
//
//

import Foundation
import CoreData


extension PriceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo")
    }

    @NSManaged public var priceCategory: String?
    @NSManaged public var venue: Venue?

}

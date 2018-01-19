//
//  CDPreAudit+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/19/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDPreAudit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPreAudit> {
        return NSFetchRequest<CDPreAudit>(entityName: "CDPreAudit")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var dataType: String?
    @NSManaged public var formId: String?
    @NSManaged public var key: String?
    @NSManaged public var objectId: String?
    @NSManaged public var syncStatus: Bool
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var value_double: Double
    @NSManaged public var value_int: Int64
    @NSManaged public var value_string: String?
    @NSManaged public var belongsToAudit: CDAudit?
    @NSManaged public var belongsToZone: CDZone?

}

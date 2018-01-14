//
//  CDPreAudit+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/13/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDPreAudit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPreAudit> {
        return NSFetchRequest<CDPreAudit>(entityName: "CDPreAudit")
    }

    @NSManaged public var auditId: String?
    @NSManaged public var formId: String?
    @NSManaged public var key: String?
    @NSManaged public var objectId: String?
    @NSManaged public var value: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var syncStatus: Bool
    @NSManaged public var belongsToAudit: CDAudit?

}

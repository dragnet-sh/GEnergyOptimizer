//
//  CDRoom+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/26/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDRoom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRoom> {
        return NSFetchRequest<CDRoom>(entityName: "CDRoom")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var guid: String?
    @NSManaged public var name: String?
    @NSManaged public var objectId: String?
    @NSManaged public var sync: Bool
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var belongsToAudit: CDAudit?
    @NSManaged public var belongsToZone: NSSet?

}

// MARK: Generated accessors for belongsToZone
extension CDRoom {

    @objc(addBelongsToZoneObject:)
    @NSManaged public func addToBelongsToZone(_ value: CDZone)

    @objc(removeBelongsToZoneObject:)
    @NSManaged public func removeFromBelongsToZone(_ value: CDZone)

    @objc(addBelongsToZone:)
    @NSManaged public func addToBelongsToZone(_ values: NSSet)

    @objc(removeBelongsToZone:)
    @NSManaged public func removeFromBelongsToZone(_ values: NSSet)

}

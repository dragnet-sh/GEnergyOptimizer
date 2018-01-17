//
//  CDAudit+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/17/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDAudit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAudit> {
        return NSFetchRequest<CDAudit>(entityName: "CDAudit")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var objectId: String?
    @NSManaged public var syncStatus: Bool
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var hasPreAuditFeature: NSSet?
    @NSManaged public var hasRoom: NSSet?
    @NSManaged public var hasZone: NSSet?

}

// MARK: Generated accessors for hasPreAuditFeature
extension CDAudit {

    @objc(addHasPreAuditFeatureObject:)
    @NSManaged public func addToHasPreAuditFeature(_ value: CDPreAudit)

    @objc(removeHasPreAuditFeatureObject:)
    @NSManaged public func removeFromHasPreAuditFeature(_ value: CDPreAudit)

    @objc(addHasPreAuditFeature:)
    @NSManaged public func addToHasPreAuditFeature(_ values: NSSet)

    @objc(removeHasPreAuditFeature:)
    @NSManaged public func removeFromHasPreAuditFeature(_ values: NSSet)

}

// MARK: Generated accessors for hasRoom
extension CDAudit {

    @objc(addHasRoomObject:)
    @NSManaged public func addToHasRoom(_ value: CDRoom)

    @objc(removeHasRoomObject:)
    @NSManaged public func removeFromHasRoom(_ value: CDRoom)

    @objc(addHasRoom:)
    @NSManaged public func addToHasRoom(_ values: NSSet)

    @objc(removeHasRoom:)
    @NSManaged public func removeFromHasRoom(_ values: NSSet)

}

// MARK: Generated accessors for hasZone
extension CDAudit {

    @objc(addHasZoneObject:)
    @NSManaged public func addToHasZone(_ value: CDZone)

    @objc(removeHasZoneObject:)
    @NSManaged public func removeFromHasZone(_ value: CDZone)

    @objc(addHasZone:)
    @NSManaged public func addToHasZone(_ values: NSSet)

    @objc(removeHasZone:)
    @NSManaged public func removeFromHasZone(_ values: NSSet)

}

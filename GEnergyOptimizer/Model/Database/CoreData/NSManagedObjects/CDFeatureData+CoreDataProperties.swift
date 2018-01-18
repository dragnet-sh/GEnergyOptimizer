//
//  CDFeatureData+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/18/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDFeatureData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFeatureData> {
        return NSFetchRequest<CDFeatureData>(entityName: "CDFeatureData")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var dataType: String?
    @NSManaged public var formId: String?
    @NSManaged public var key: String?
    @NSManaged public var objectId: String?
    @NSManaged public var syncStatus: Bool
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var value: NSObject?
    @NSManaged public var belongsToZone: CDZone?

}

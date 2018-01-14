//
//  CDPreAuditFeature+CoreDataProperties.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/12/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//
//

import Foundation
import CoreData


extension CDPreAuditFeature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPreAuditFeature> {
        return NSFetchRequest<CDPreAuditFeature>(entityName: "CDPreAuditFeature")
    }

    @NSManaged public var audit_parse_id: String?
    @NSManaged public var form_id: String?
    @NSManaged public var key: String?
    @NSManaged public var parse_id: String?
    @NSManaged public var value: String?
    @NSManaged public var belongsToAudit: CDAudit?

}

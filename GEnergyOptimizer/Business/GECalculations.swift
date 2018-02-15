//
//  GECalculations.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/5/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import CSV
import CSwiftV

public class GEnergyCalculations {

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var state = StateController.sharedInstance

    func test() {
        Log.message(.warning, message: "******* DEBUG MESSAGE FROM XCTest !! *******")
        state.registerAuditIdentifier(auditIdentifier: "test-001")
        initialize()
    }
}


extension GEnergyCalculations {

    func initialize() {
        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                guard let results = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Zone")
                    return
                }

                for zone in results {
                    guard let feature = zone.hasFeature?.allObjects as? [CDFeatureData] else {
                        Log.message(.error, message: "Guard Failed : Feature Data - Core Data Zone")
                        return
                    }

                    switch GUtils.getEAppliance(rawValue: zone.type!) {
                    case .freezerFridge: getFreezerFridge().compute(feature: feature)
                    default: Log.message(.warning, message: zone.type!)
                    }
                }
            }
        }
    }


    func getFreezerFridge() -> EnergyCalculator {
        return Refrigerator()
    }
}

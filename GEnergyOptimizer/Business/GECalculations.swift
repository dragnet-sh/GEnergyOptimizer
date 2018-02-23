//
//  GECalculations.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/5/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

enum GEnergyError: Error {
    case IdentifierNotSet
    case AuditNone
    case PreAuditNone
    case ZoneNone
}

public class GEnergyCalculations {

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var state = StateController.sharedInstance

    func test() {
        Log.message(.warning, message: "******* DEBUG MESSAGE FROM XCTest !! *******")
        state.registerAuditIdentifier(auditIdentifier: "test-001")
        run()
    }
}

extension GEnergyCalculations {
    func run() {
        let preAudit = try! getPreAudit()
        let zone = try! getZone()

        zone.forEach { zone in
            if let featureData = zone.hasFeature?.allObjects as? [CDFeatureData] {
                //ToDo: Use HashMap to get rid of the Switch
                switch GUtils.getEAppliance(rawValue: zone.type!) {
                case .freezerFridge: Refrigerator(feature: featureData, preAudit: preAudit).compute()
                default: Log.message(.warning, message: zone.type!)
                }
            }
        }
    }

    func getZone() throws -> [CDZone] {
        let audit = try! getAudit()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        if let zone = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] {return zone}
        else {throw GEnergyError.ZoneNone}
    }

    func getPreAudit() throws -> [CDFeatureData] {
        let audit = try! getAudit()
        if let preAudit = audit.hasPreAuditFeature?.allObjects as? [CDFeatureData] {return preAudit}
        else {throw GEnergyError.PreAuditNone}
    }

    func getAudit() throws -> CDAudit {
        let identifier = try! getAuditIdentifier()
        if let audit = coreDataAPI.getAudit(id: identifier) {return audit}
        else {throw GEnergyError.AuditNone}
    }

    func getAuditIdentifier() throws -> String {
        if let identifier = state.getIdentifier() {return identifier}
        else {throw GEnergyError.IdentifierNotSet}
    }
}

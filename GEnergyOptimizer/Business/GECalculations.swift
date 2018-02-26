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
}

extension GEnergyCalculations {
    func run() {
        let preAudit = try! getPreAudit()
        let zones = try! getZone()

        // **** Plugload **** //
        getPlugload(zones: zones).forEach {
            if let featureData = $0.hasFeature?.allObjects as? [CDFeatureData] {
                switch applianceType(zone: $0) {
                case .freezerFridge: Refrigerator(feature: featureData, preAudit: preAudit).compute()
                default: Log.message(.warning, message: $0.type!)
                }
            }
        }

        // **** HVAC **** //
        let hvac = getHVACFeature()
        HVAC(feature: getHVACFeature(), preAudit: preAudit).compute()

        // **** Lighting **** //

    }


    func getHVACFeature() -> [CDFeatureData] {

        let model = BuilderHelper.decodeJSON(bundleResource: "preaudit")!
        let sId2Ele = BuilderHelper.mapSectionIdsToElements(model: model)!
        let sId2Name = BuilderHelper.mapSectionIdsToName(model: model)!

        var hvacSId = Array<String>()
        for (sectionId, sectionName) in sId2Name {
            if sectionName.starts(with: "HVAC") {
                hvacSId.append(sectionId)}
        }

        var gElements = Array<GElements>()
        hvacSId.forEach {gElements.append(contentsOf: sId2Ele[$0]!)}

        let hvacEId = gElements.map {$0.elementId!}
        let preaudit = try! getPreAudit()

        let feature = preaudit.filter { feature in
            return hvacEId.contains(feature.formId!)
        }

        return feature
    }


    func getPlugload(zones: [CDZone]) -> [CDZone] {
        return zones.filter { applianceType(zone: $0) != .none }
    }

    func applianceType(zone: CDZone) -> EApplianceType {
        return GUtils.getEAppliance(rawValue: zone.type!)
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

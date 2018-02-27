//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class GEnergy {
    public var audit: CDAudit
    public var preaudit: [CDFeatureData]
    public var zone: [CDZone]
    let factory = AuditFactory.sharedInstance

    init() {
        self.audit = try! factory.setAudit()
        self.preaudit = try! factory.setPreAudit()
        self.zone = try! factory.setZone()
    }

    func calculate() {
        self.hvac()
        self.plugload()
    }

    func hvac() {
        Log.message(.error, message: "#### GEnergy Calculations Dry Run ####")
        let zhvac = ZHVAC()
        guard let feature = zhvac.features() else {return}
        HVAC(feature: feature, preAudit: preaudit).compute()
    }

    func plugload() {
        zone.filter { zone in GUtils.getEAppliance(rawValue: zone.type!) != .none }
                .forEach { zone in
                    let plugload = ZPlugLoad(plZone: zone)
                    guard let feature = plugload.features() else {return}
                    switch plugload.type() {
                    case .freezerFridge: Refrigerator(feature: feature, preAudit: preaudit).compute()
                    case .fryer: Fryer(feature: feature, preAudit: preaudit).compute()
                    default: Log.message(.warning, message: "UNKNOWN")
                    }
                }
    }
}

protocol Features {
    func features() -> [CDFeatureData]?
}

class ZHVAC: GEnergy, Features {
    func features() -> [CDFeatureData]? {
        let model = BuilderHelper.decodeJSON(bundleResource: FileResource.preaudit.rawValue)!
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
        let feature = super.preaudit.filter { feature in
            return hvacEId.contains(feature.formId!)
        }

        return feature
    }
}

class ZPlugLoad: GEnergy, Features {
    var plZone: CDZone

    init(plZone: CDZone) {
        self.plZone = plZone
    }

    func features() -> [CDFeatureData]? {
        return plZone.hasFeature?.allObjects as? [CDFeatureData]
    }

    func type() -> EApplianceType {
        return GUtils.getEAppliance(rawValue: plZone.type!)
    }
}


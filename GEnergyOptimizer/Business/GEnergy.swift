//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class GEnergy {
    private var gAudit: GAudit
    private var gHVAC: GHVAC
    private var gPlugload: GPlugLoad


    init() {
        self.gAudit = GAudit()
        self.gHVAC = GHVAC()
        self.gPlugload = GPlugLoad()
    }

    public func crunch() {
        calculate()
    }

    public func backup() {
        gAudit.backup()
    }

    private func calculate() {
        gHVAC._calculate()
        gPlugload._calculate()
    }
}

protocol CalculateAndUpload {
    func _features() -> [CDFeatureData]?
    func _calculate()
}

class GAudit {
    public var audit: CDAudit
    public var preaudit: [CDFeatureData]
    public var zone: [CDZone]
    let factory = AuditFactory.sharedInstance

    init() {
        self.audit = try! factory.setAudit()
        self.preaudit = try! factory.setPreAudit()
        self.zone = try! factory.setZone()
    }

    func backup() {
        // Create OutgoingRows and call it's upload Method // -- Simple : )
    }
}

class GHVAC: GAudit, CalculateAndUpload {
    func _features() -> [CDFeatureData]? {
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

    func _calculate() {
        guard let feature = _features() else {return}
        HVAC(feature: feature).compute() { result in result!.upload() }
    }
}

class GPlugLoad: GAudit, CalculateAndUpload {
    var plZone: CDZone?

    override init() {
        super.init()
    }

    init(plZone: CDZone) {
        self.plZone = plZone
    }

    func _features() -> [CDFeatureData]? {
        return plZone!.hasFeature?.allObjects as? [CDFeatureData]
    }

    func type() -> EApplianceType {
        return GUtils.getEAppliance(rawValue: plZone!.type!)
    }

    func _calculate() {
        super.zone.filter { zone in GUtils.getEAppliance(rawValue: zone.type!) != .none }
                .forEach { zone in
                    let plugload = GPlugLoad(plZone: zone)
                    guard let feature = plugload._features() else {return}
                    switch plugload.type() {
                    case .freezerFridge: Refrigerator(feature: feature).compute() { result in result!.upload() }
                    case .fryer: Fryer(feature: feature).compute() { result in result!.upload() }
                    default: Log.message(.warning, message: "UNKNOWN")
                    }
                }
        return
    }
}

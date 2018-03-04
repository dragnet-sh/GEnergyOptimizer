//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class GEnergy {
    private var gHVAC: GHVAC
    private var gPlugload: GPlugLoad

    init() {
        self.gHVAC = GHVAC()
        self.gPlugload = GPlugLoad()
    }

    public func crunch() {
        calculate()
        upload()
    }

    private func calculate() {
        gHVAC._calculate()
        gPlugload._calculate()
    }

    private func upload() {
        gHVAC._upload()
        gPlugload._upload()
    }
}

protocol CalculateAndUpload {
    func _features() -> [CDFeatureData]?
    func _calculate()
    func _upload()
    //_ filename: String, _ basePath: String, data: Data
}

class GAudit {
    public var identifier: String
    public var audit: CDAudit
    public var preaudit: [CDFeatureData]
    public var zone: [CDZone]
    let factory = AuditFactory.sharedInstance

    init() {
        self.identifier = try! factory.getIdentifier()
        self.audit = try! factory.setAudit()
        self.preaudit = try! factory.setPreAudit()
        self.zone = try! factory.setZone()
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
        HVAC(feature: feature).compute() { result in
            Log.message(.warning, message: result.debugDescription)
        }
    }

    func _upload() {
        // We have the Computed Rows
        // Now make rows for the Core Raw Data


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
                    case .freezerFridge:
                    Refrigerator(feature: feature).compute() { result in
                        Log.message(.warning, message: result.debugDescription)
                    }
                    case .fryer: Fryer(feature: feature).compute() { result in
                        Log.message(.warning, message: result.debugDescription)
                    }
                    default: Log.message(.warning, message: "UNKNOWN")
                    }
                }
        return
    }

    func _upload() {
    }
}

struct OutgoingRows {
    typealias Row = [String: String]
    enum type {
        case raw, computed
    }
    var rows: [Row]
    var entity: String
    var type: type

    init(rows: [Row], entity: String, type: type) {
        self.rows = rows
        self.entity = entity
        self.type = type
    }
}


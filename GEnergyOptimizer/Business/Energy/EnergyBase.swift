//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

protocol Computable {
    func compute(complete: @escaping (OutgoingRows?) -> Void)
    func fields() -> [String]?
}

class EnergyBase {
    var preAudit = Dictionary<String, Any>()
    var mappedFeature = Dictionary<String, Any>()
    var operatingHours = Dictionary<EDay, String>()
    var outgoing: [[String: String]]

    init(feature: [CDFeatureData]) {
        let preAudit = try! AuditFactory.sharedInstance.setPreAudit()
        self.preAudit = GUtils.mapFeatureData(feature: preAudit)
        self.mappedFeature = GUtils.mapFeatureData(feature: feature)
        self.operatingHours = GUtils.mapOperationHours(preAudit: preAudit)
        self.outgoing = [[String: String]]()
    }

    func starValidator(complete: @escaping () -> Void) {
        let energyStar = EnergyStar(mappedFeature: self.mappedFeature)
        energyStar.query() { status in
            if (status) {
                return
            }
            complete()
        }
    }
}

class OutgoingRows {
    typealias Row = [String: String]
    enum EType: String {
        case raw, computed
    }
    var header: [String]?
    var rows: [Row]
    var entity: String
    var eType: EType

    let baseDir: String = "/Gemini/Audit"
    var parentFolder: String

    init(rows: [Row], entity: String, type: EType) {
        self.rows = rows
        self.entity = entity
        self.eType = type
        self.parentFolder = try! AuditFactory.sharedInstance.getIdentifier()
    }

    func upload() {
        Log.message(.warning, message: "**** Uploading ****")
        var path: String = "\(baseDir)/\(parentFolder)/\(eType.rawValue)"
        Log.message(.error, message: path.description)
    }
}

protocol Consumption {
  func cost(energyUsed: Double) -> Double
}

class GasCost: Consumption {

    lazy var pricing: Dictionary<ERateKey, Double> = {
        let utility = GasRate()
        return utility.getBillData()
    }()

    // *** Gives the Average Cost Per Day *** //
    func cost(energyUsed: Double) -> Double {

        var slabPricing = 0.0

        if energyUsed <= 5 {
            slabPricing = pricing[ERateKey.slab1]!
        } else if energyUsed <= 16 {
            slabPricing = pricing[ERateKey.slab2]!
        } else if energyUsed <= 41 {
            slabPricing = pricing[ERateKey.slab3]!
        } else if energyUsed <= 123 {
            slabPricing = pricing[ERateKey.slab4]!
        } else {
            slabPricing = pricing[ERateKey.slab5]!
        }

        // Since the values are per day - Dividing by 2 averages Summer | Winter as they are both of 6 months
        slabPricing += (pricing[ERateKey.summerTransport]! + pricing[ERateKey.winterTransport]!) / 2 + pricing[ERateKey.surcharge]!

        return  (slabPricing * energyUsed)
    }
}

class ElectricCost: Consumption {
    var rateStructure: String
    var operatingHours: Dictionary<EDay, String>

    lazy var pricing: Dictionary<ERateKey, Double> = {
        let utility = ElectricRate(type: rateStructure)
        return utility.getBillData()
    }()

    lazy var usageByPeak: Dictionary<ERateKey, Int> = {
        let peak = PeakHourMapper()
        return peak.run(usage: operatingHours)
    }()

    init(rateStructure: String, operatingHours: Dictionary<EDay, String>) {
        self.rateStructure = rateStructure
        self.operatingHours = operatingHours
    }

    func cost(energyUsed: Double) -> Double {
        var summer = Double(usageByPeak[ERateKey.summerOn]!) * energyUsed * pricing[ERateKey.summerOn]!
        summer += Double(usageByPeak[ERateKey.summerPart]!) * energyUsed * pricing[ERateKey.summerPart]!
        summer += Double(usageByPeak[ERateKey.summerOff]!) * energyUsed * pricing[ERateKey.summerOff]!

        var winter = Double(usageByPeak[ERateKey.winterPart]!) * energyUsed * pricing[ERateKey.winterPart]!
        winter += Double(usageByPeak[ERateKey.winterOff]!) * energyUsed * pricing[ERateKey.winterOff]!

        return (summer + winter)
    }
}

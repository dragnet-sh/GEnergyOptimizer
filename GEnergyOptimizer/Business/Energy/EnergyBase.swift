//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

protocol Computable {
    func compute()
}

class EnergyBase {
    var preAudit = Dictionary<String, Any>()
    var mappedFeature = Dictionary<String, Any>()

    init(feature: [CDFeatureData], preAudit: [CDFeatureData]) {
        self.preAudit = GUtils.mapFeatureData(feature: preAudit)
        self.mappedFeature = GUtils.mapFeatureData(feature: feature)
    }
}

protocol Consumption {
  func cost(energyUsed: Double) -> Double
}

class GasCost: Consumption {
    func cost(energyUsed: Double) -> Double {
        return 0.0
    }
}

class ElectricCost: Consumption {
    var rateStructure: String
    var operatingHours: String

    lazy var pricing: Dictionary<ERateKey, Double> = {
        let utility = ElectricRate(type: rateStructure)
        return utility.getBillData()
    }()

    lazy var usageByPeak: Dictionary<ERateKey, Int> = {
        let peak = PeakHourMapper()
        return peak.run(usage: operatingHours)
    }()

    init(rateStructure: String, operatingHours: String) {
        self.rateStructure = rateStructure
        self.operatingHours = operatingHours
    }

    func cost(energyUsed: Double) -> Double {
        var summer = Double(usageByPeak[ERateKey.summerOn]!) * energyUsed * Double(pricing[ERateKey.summerOn]!)
        summer += Double(usageByPeak[ERateKey.summerPart]!) * energyUsed * Double(pricing[ERateKey.summerPart]!)
        summer += Double(usageByPeak[ERateKey.summerOff]!) * energyUsed * Double(pricing[ERateKey.summerOff]!)

        var winter = Double(usageByPeak[ERateKey.winterPart]!) * energyUsed * Double(pricing[ERateKey.winterPart]!)
        winter += Double(usageByPeak[ERateKey.winterOff]!) * energyUsed * Double(pricing[ERateKey.winterOff]!)

        return (summer + winter)
    }
}

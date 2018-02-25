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

extension EnergyBase {
    func costElectricity(hourEnergyUse: Double, pricing: Dictionary<ERateKey, Double>, usageByPeak: Dictionary<ERateKey, Int>) -> Double {

        var summer = Double(usageByPeak[ERateKey.summerOn]!) * hourEnergyUse * Double(pricing[ERateKey.summerOn]!)
        summer += Double(usageByPeak[ERateKey.summerPart]!) * hourEnergyUse * Double(pricing[ERateKey.summerPart]!)
        summer += Double(usageByPeak[ERateKey.summerOff]!) * hourEnergyUse * Double(pricing[ERateKey.summerOff]!)

        var winter = Double(usageByPeak[ERateKey.winterPart]!) * hourEnergyUse * Double(pricing[ERateKey.winterPart]!)
        winter += Double(usageByPeak[ERateKey.winterOff]!) * hourEnergyUse * Double(pricing[ERateKey.winterOff]!)

        return (summer + winter)
    }

    func costGas() {

    }
}
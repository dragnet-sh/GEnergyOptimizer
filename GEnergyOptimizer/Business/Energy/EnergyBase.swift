//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

protocol Computable {
    func compute()
}

class EnergyCalculator {
    var preAudit = Dictionary<String, Any>()
    var mappedFeature = Dictionary<String, Any>()

    init(feature: [CDFeatureData], preAudit: [CDFeatureData]) {
        self.preAudit = mapFeatureData(feature: preAudit)
        self.mappedFeature = mapFeatureData(feature: feature)
    }
}

extension EnergyCalculator {
    func costElectricity(hourEnergyUse: Double, pricing: Dictionary<EPeak, Double>, usageByPeak: Dictionary<EPeak, Int>) -> Double {

        var summer = Double(usageByPeak[EPeak.summerOn]!) * hourEnergyUse * Double(pricing[EPeak.summerOn]!)
        summer += Double(usageByPeak[EPeak.summerPart]!) * hourEnergyUse * Double(pricing[EPeak.summerPart]!)
        summer += Double(usageByPeak[EPeak.summerOff]!) * hourEnergyUse * Double(pricing[EPeak.summerOff]!)

        var winter = Double(usageByPeak[EPeak.winterPart]!) * hourEnergyUse * Double(pricing[EPeak.winterPart]!)
        winter += Double(usageByPeak[EPeak.winterOff]!) * hourEnergyUse * Double(pricing[EPeak.winterOff]!)

        return (summer + winter)
    }

    func costGas() {

    }

    func mapFeatureData(feature: [CDFeatureData]) -> Dictionary<String, Any> {
        var mapped = Dictionary<String, Any>()
        feature.map {
            let type = InitEnumMapper.sharedInstance.enumMap[$0.type!]
            if let eBaseType = type as? BaseRowType {
                switch eBaseType {
                case .intRow: mapped[$0.key!] = $0.value_int
                case .decimalRow: mapped[$0.key!] = $0.value_double
                default: mapped[$0.key!] = $0.value_string
                }
            }
        }

        return mapped
    }
}
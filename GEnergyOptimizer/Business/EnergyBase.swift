//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import Parse

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

    //ToDo: Not all of the Product Need to go through this ??
    func alternateProductMatchFilter(query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        Log.message(.error, message: "Please override method getBundleResource")
        fatalError("Must be over-ridden")
    }

    func productMatchFilter(query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        let model_number = String(describing: mappedFeature["Model Number"]!)
        let company = String(describing: mappedFeature["Company"]!)

        query.whereKey("data.company", equalTo: company)
        query.whereKey("data.model_number", equalTo: model_number)

        return query
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
}

extension EnergyCalculator {

    func isEnergyStar(curr_values: Dictionary<String, Any>, complete: @escaping (Bool) -> Void) {
        Log.message(.warning, message: "Energy Star Check")

        if let query = PlugLoad.query() {
            let queryWithProductMatchFilter = productMatchFilter(query: query)
            queryWithProductMatchFilter.findObjectsInBackground { object, error in
                if (error == nil) {
                    Log.message(.info, message: "Parse - Plugload Query - No Error")
                } else {
                    Log.message(.error, message: error.debugDescription)
                    return
                }

                guard let data = object as? [PlugLoad] else {
                    Log.message(.error, message: "Guard Failed : Plugload Data - Core Data Zone")
                    return
                }

                if (data.count > 0) {complete(true)}
                else {complete(false)}
            }
        }
    }

    func findBestModel(curr_values: Dictionary<String, Any>, complete: @escaping ([PlugLoad]) -> Void) {
        if let query = PlugLoad.query() {
            let queryWithAlternateProductMatchFilter = alternateProductMatchFilter(query: query)
            queryWithAlternateProductMatchFilter.findObjectsInBackground { object, error in
                if (error == nil) {
                    Log.message(.info, message: "Parse - Plugload Query - No Error")
                } else {
                    Log.message(.error, message: error.debugDescription)
                    return
                }

                guard let data = object as? [PlugLoad] else {
                    Log.message(.error, message: "Guard Failed : Plugload Data - Core Data Zone")
                    return
                }

                complete(data)
            }
        }
    }
}

extension EnergyCalculator {

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
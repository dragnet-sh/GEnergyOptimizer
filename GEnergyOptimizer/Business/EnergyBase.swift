//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import Parse

class EnergyCalculator {
    func compute(feature: [CDFeatureData]) {
        let energy_star = isEnergyStar(curr_values: mapFeatureData(feature: feature)) { status in
            if (status) {
                return
            }
        }
    }

    func costElectricity(hour_energy_use: Double, pricing_chart: Dictionary<EPeak, Double>, peak_hour_schedule: Dictionary<EPeak, Int>) -> Double {
        var summer = Double(peak_hour_schedule[EPeak.summerOn]!) * hour_energy_use * Double(pricing_chart[EPeak.summerOn]!)
        summer += Double(peak_hour_schedule[EPeak.summerPart]!) * hour_energy_use * Double(pricing_chart[EPeak.summerPart]!)
        summer += Double(peak_hour_schedule[EPeak.summerOff]!) * hour_energy_use * Double(pricing_chart[EPeak.summerOff]!)

        var winter = Double(peak_hour_schedule[EPeak.winterPart]!) * hour_energy_use * Double(pricing_chart[EPeak.winterPart]!)
        winter += Double(peak_hour_schedule[EPeak.winterOff]!) * hour_energy_use * Double(pricing_chart[EPeak.winterOff]!)

        return (summer + winter)
    }

    func addAlternateProductMatchFilter(query: PFQuery<PFObject>, curr_values: Dictionary<String, Any>) -> PFQuery<PFObject> {
        Log.message(.error, message: "Please override method getBundleResource")
        fatalError("Must be over-ridden")
    }


    func addProductMatchFilter(query: PFQuery<PFObject>, curr_values: Dictionary<String, Any>) -> PFQuery<PFObject> {
        let model_number = String(describing: curr_values["Model Number"]!)
        let company = String(describing: curr_values["Company"]!)

        query.whereKey("data.company", equalTo: company)
        query.whereKey("data.model_number", equalTo: model_number)

        return query
    }
}

extension EnergyCalculator {

    func isEnergyStar(curr_values: Dictionary<String, Any>, complete: @escaping (Bool) -> Void) {
        Log.message(.warning, message: "Energy Star Check")

        if let query = PlugLoad.query() {

            addProductMatchFilter(query: query, curr_values: curr_values).findObjectsInBackground { object, error in
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

                if (data.count > 0) {
                    complete(true)
                } else {
                    complete(false)
                }
            }
        }
    }

    func findBestModel(curr_values: Dictionary<String, Any>, complete: @escaping ([PlugLoad]) -> Void) {
        if let query = PlugLoad.query() {
            addAlternateProductMatchFilter(query: query, curr_values: curr_values).findObjectsInBackground { object, error in
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

// *** Helper Methods ***
extension EnergyCalculator {

    func mapFeatureData(feature: [CDFeatureData]) -> Dictionary<String, Any> {
        var curr_values = Dictionary<String, Any>()
        feature.map {
            let type = InitEnumMapper.sharedInstance.enumMap[$0.type!]
            if let eBaseType = type as? BaseRowType {
                switch eBaseType {
                case .intRow: curr_values[$0.key!] = $0.value_int
                case .decimalRow: curr_values[$0.key!] = $0.value_double
                default: curr_values[$0.key!] = $0.value_string
                }
            }
        }

        return curr_values
    }

    func getBillData(bill_type: String) -> Dictionary<EPeak, Double> {
        let rows = GUtils.openCSV(filename: "pge_electric")!
        var outgoing = Dictionary<EPeak, Double>()
        for row in rows {
            if row["rate"]! == bill_type {
                let key = "\(row["season"]!)-\(row["ec_period"]!)"
                outgoing[GUtils.getEPeak(rawValue: key)] = Double(row["energy_charge"]!)
            }
        }

        return outgoing
    }
}
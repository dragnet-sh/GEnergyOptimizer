//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Refrigerator: EnergyCalculator, Computable {

    lazy var utilityPricing: Dictionary<EPeak, Double> = {
        let rateStructure = GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
        let utility = UtilityMapper()
        return utility.getBillData(bill_type: rateStructure)
    }()

    lazy var usageByPeak: Dictionary<EPeak, Int> = {
        let operatingHours = GUtils.toString(subject: preAudit["Monday Operating Hours"]!)
        let peak = PeakHourMapper()
        return peak.run(usage: operatingHours)
    }()

    lazy var filterAlternateMatch: PFQuery<PFObject> = {
        let query = PlugLoad.query()!
        let type = String(describing: mappedFeature["Product Type"]!)
        let volume = String(describing: mappedFeature["Total Volume"]!)

        query.whereKey("data.style_type", equalTo: type)
        query.whereKey("data.total_volume", equalTo: Double(volume))

        return query
    }()


    func compute() {
        let energyStar = EnergyStar(mappedFeature: self.mappedFeature)
        energyStar.query() { status in
            if (status) { return }
            Log.message(.warning, message: self.mappedFeature.debugDescription)

            let bestModel = BestModel(query: self.filterAlternateMatch)
            bestModel.query(curr_values: self.mappedFeature) { freezers in
                Log.message(.warning, message: freezers.debugDescription)
                freezers.map { freezer in
                    var hourEnergyUse = 10.0 // ****** The final missing piece !!
                    var total_electric = self.costElectricity(hourEnergyUse: hourEnergyUse, pricing: self.utilityPricing, usageByPeak: self.usageByPeak)
                    var total_cost = total_electric

                    Log.message(.warning, message: "Calculated Energy Value - \(total_cost.description)")
                }
            }
        }
    }
}

//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Refrigerator: EnergyCalculator, Computable {

    func compute() {
        let energy_star = isEnergyStar(curr_values: mappedFeature) { status in
            if (status) { return }

            Log.message(.warning, message: self.mappedFeature.debugDescription)
            let pricing = self.pricingChart()
            let usage = self.peakHourSchedule()
            let best_model_num = self.findBestModel(curr_values: self.mappedFeature) { freezers in
                Log.message(.warning, message: freezers.debugDescription)
                for freezer in freezers {
                    var hour_energy_use = 10.0 // ****** The final missing piece !! ToDo: Talk about this with Anthony
                    var total_electric = self.costElectricity(hourEnergyUse: hour_energy_use, peakPricing: pricing, mappedUsageByPeak: usage)
                    var total_cost = total_electric

                    Log.message(.warning, message: "Calculated Energy Value - \(total_cost.description)")

                    // *** Writing the Total Cost to a File *** //

                }
            }
        }
    }

    override func alternateProductMatchFilter(query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        let prod_type = String(describing: mappedFeature["Product Type"]!)
        let total_volume = String(describing: mappedFeature["Total Volume"]!)
        let type = "solid_door_freezers_retrofits"

        query.whereKey("data.style_type", equalTo: prod_type)
        query.whereKey("data.total_volume", equalTo: Double(total_volume))

        return query
    }

    func pricingChart() -> Dictionary<EPeak, Double> {
        let utilityCompany = GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
        return getBillData(bill_type: utilityCompany)
    }

    func peakHourSchedule() -> Dictionary<EPeak, Int> {
        //ToDo: Consolidate the Operating Hours
        let operatingHours = GUtils.toString(subject: preAudit["Monday Operating Hours"]!)
        let peak = PeakHourCalculator()
        var peakHour = peak.run(usage: operatingHours)
        return peakHour
    }
}

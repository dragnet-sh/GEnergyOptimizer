//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Refrigerator: EnergyCalculator {

    override func compute(feature: [CDFeatureData]) {
        let mappedFeature = mapFeatureData(feature: feature)
        let energy_star = isEnergyStar(curr_values: mappedFeature) { status in
            if (status) { return }

            Log.message(.warning, message: mappedFeature.debugDescription)
            let best_model_num = self.findBestModel(curr_values: mappedFeature) { freezers in
                Log.message(.warning, message: freezers.debugDescription)
                for freezer in freezers {
                    var hour_energy_use = 10.0 // ****** The final missing piece !! ToDo: Talk about this with Anthony
                    var total_electric = self.costElectricity(hourEnergyUse: hour_energy_use)
                    var total_cost = total_electric

                    Log.message(.warning, message: "Calculated Energy Value - \(total_cost.description)")
                }
            }
        }
    }

    override func alternateProductMatchFilter(query: PFQuery<PFObject>, curr_values: Dictionary<String, Any>) -> PFQuery<PFObject> {
        let prod_type = String(describing: curr_values["Product Type"]!)
        let total_volume = String(describing: curr_values["Total Volume"]!)
        let type = "solid_door_freezers_retrofits"

        query.whereKey("data.style_type", equalTo: prod_type)
        query.whereKey("data.total_volume", equalTo: Double(total_volume))

        return query
    }

    //ToDo: Get the Bill Type from PreAudit
    override func pricingChart() -> Dictionary<EPeak, Double> {
        return getBillData(bill_type: "A-1 TOU")
    }

    //ToDo: Get the Peak Hour Usage from PreAudit
    override func peakHourSchedule() -> Dictionary<EPeak, Int> {
        let peak = PeakHourCalculator()
        var peakHour = peak.run(usage: "14:30 21:30,6:30 12:30")

        return peakHour
    }
}

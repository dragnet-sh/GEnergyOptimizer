//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class Refrigerator: EnergyCalculator {
    func compute() -> Double {

    }

    func __compute__freezer__fridge(feature: [CDFeatureData]) {

        var curr_values = mapFeatureData(feature: feature)
        Log.message(.warning, message: curr_values.debugDescription)

        let model_number = String(describing: curr_values["Model Number"]!)
        let company = String(describing: curr_values["Company"]!)

        // **** Check to see if the device is already an Energy Star Rated **** //

        let energy_star = isEnergyStar(model_number: model_number, company: company) { status in
            if (status) {
                Log.message(.warning, message: "**** Energy Star - \(company) - \(model_number) ****")
                return
            }

            // **** Proceed with finding the Energy Efficient Device **** //

            let best_model_num = self.find_best_model_fridge_freezer(curr_values: curr_values) { freezers in

                Log.message(.warning, message: freezers.debugDescription)

                for freezer in freezers {
                    var pricing_chart = self.getBillData(bill_type: "A-1 TOU") //ToDo: Get the Bill Type from PreAudit
                    let peak = PeakHourCalculator()
                    var peak_hour_schedule = peak.run(usage: "14:30 21:30,6:30 12:30") //ToDo: Get the Peak Hour Usage from PreAudit
                    var hour_energy_use = 10.0 // ****** The final missing piece !! ToDo: Talk about this with Anthony

                    var summer = Double(peak_hour_schedule[EPeak.summerOn]!) * hour_energy_use * Double(pricing_chart[EPeak.summerOn]!)
                    summer += Double(peak_hour_schedule[EPeak.summerPart]!) * hour_energy_use * Double(pricing_chart[EPeak.summerPart]!)
                    summer += Double(peak_hour_schedule[EPeak.summerOff]!) * hour_energy_use * Double(pricing_chart[EPeak.summerOff]!)

                    var winter = Double(peak_hour_schedule[EPeak.winterPart]!) * hour_energy_use * Double(pricing_chart[EPeak.winterPart]!)
                    winter += Double(peak_hour_schedule[EPeak.winterOff]!) * hour_energy_use * Double(pricing_chart[EPeak.winterOff]!)

                    var total_electric = summer + winter
                    var total_cost = total_electric

                    Log.message(.warning, message: "Calculated Energy Value - \(total_cost.description)")
                }
            }
        }
    }
}

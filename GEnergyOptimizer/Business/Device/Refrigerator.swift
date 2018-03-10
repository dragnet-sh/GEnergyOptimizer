//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Refrigerator: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!
        let type = mappedFeature["Product Type"]
        let volume = mappedFeature["Total Volume"]

        query.whereKey("data.style_type", equalTo: type)
        query.whereKey("data.total_volume", equalTo: volume)

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {

        Log.message(.info, message: "### Computing - Refrigerator ###")
        __compute(delegate: self, type: .freezerFridge, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)
            let operatingHours = 24

            guard let dailyEnergyUse = data["daily_energy_use"] as? Double else {

                Log.message(.error, message: "Daily Energy Use Nil")
                complete(nil)
                return nil
            }

            let electricEnergy: Double = dailyEnergyUse
            let electricCost = super.electricCost().cost(energyUsed: electricEnergy)
            let totalCost = electricCost

            entry["__daily_operating_hours"] = operatingHours.description
            entry["__electric_energy"] = electricEnergy.description
            entry["__electric_cost"] = electricCost.description

            return entry

        }) {complete($0)}

    }

    func fields() -> [String]? {
        return [
            "company", "model_number", "style_type", "total_volume","daily_energy_use", "rebate",
            "pgne_measure_code", "purchase_price_per_unit", "vendor",

            "__daily_operating_hours", "__electric_energy", "__electric_cost"
        ]
    }
}

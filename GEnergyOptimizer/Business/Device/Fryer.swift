//
// Created by Binay Budhthoki on 2/26/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Fryer: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!
        let productionCapacity = mappedFeature["Production Capacity (lbs/h)"]
        let vatWidth = mappedFeature["Vat Width (in)"]
        let fuelType = mappedFeature["Fuel Type"]

        query.whereKey("data.production_capacity", equalTo: productionCapacity)
        query.whereKey("data.vat_width", equalTo: vatWidth)
        query.whereKey("data.fuel_type", equalTo: fuelType)
        query.whereKey("type", equalTo: "fryers_retrofits")

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Fryer ###")
        __compute(delegate: self, type: .fryer, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = 3.0
            let operatingHours = super.dailyOperatingHours()

            guard   let preheatEnergyRate = data["preheat_energy"] as? Double,
                    let idleEnergyRate = data["idle_energy_rate"] as? Double else {
                Log.message(.error, message: "Pre Heat Energy | Idle Energy Rate Nil")
                complete(nil)
                return nil
            }

            let gasEnergy = preheatEnergyRate * operatingHours + idleEnergyRate * idleRunHours
            let electricEnergy = idleEnergyRate * idleRunHours

            let gasCost = super.gasCost().cost(energyUsed: gasEnergy)
            let electricCost = super.electricCost().cost(energyUsed: electricEnergy)
            let totalCost = gasCost + electricCost

            entry["__idle_run_hours"] = idleRunHours.description
            entry["__daily_operating_hours"] = operatingHours.description
            entry["__gas_energy"] = gasEnergy.description
            entry["__electric_energy"] = electricEnergy.description
            entry["__gas_cost"] = gasCost.description
            entry["__electric_cost"] = electricCost.description
            entry["__total_cost"] = totalCost.description

            return entry

        }) {complete($0)}

    }

    func fields() -> [String]? {
        return [
            "company", "model_number", "vat_width", "shortening_capacity", "fuel_type", "idle_energy_rate",
            "preheat_energy", "energy_efficiency", "production_capacity",  "rebate", "pgne_measure_code",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}
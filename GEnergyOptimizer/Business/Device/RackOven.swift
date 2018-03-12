//
// Created by Binay Budhthoki on 3/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class RackOven: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!
        let productionCapacity = mappedFeature["Production Capacity (lbs/h)"]
        let size = mappedFeature["Size"]

        query.whereKey("data.production_capacity", equalTo: productionCapacity)
        query.whereKey("data.size", equalTo: size)

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - RackOven ###")
        __compute(delegate: self, type: .rackOven, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            guard   let preheatEnergyRate = data["preheat_energy"] as? Double,
                    let idleEnergyRate = data["idle_energy_rate"] as? Double,
                    let fanEnergyRate = data["fan_control_energy_rate"] as? Double,
                    let fuelType = data["fuel_type"] else {

                Log.message(.error, message: "Pre Heat | Idle | Fan Control Energy Rate Nil")
                complete(nil)
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy: Double = fanEnergyRate * operatingHours

            switch EFuelType.eVal(rawValue: fuelType) {
            case .gas: gasEnergy = preheatEnergyRate * operatingHours + idleEnergyRate * idleRunHours
            case .electric: electricEnergy += idleEnergyRate * idleRunHours
            default: Log.message(.error, message: "Unknown Fuel Type !!"); return nil
            }

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
            "company", "model_number", "size", "fuel_type", "preheat_energy", "idle_energy_rate",
            "energy_efficiency", "production_capacity", "fan_control_energy_rate", "rebate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}
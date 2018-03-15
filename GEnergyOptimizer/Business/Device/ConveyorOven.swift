//
// Created by Binay Budhathoki on 3/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class ConveyorOven: EnergyBase, Computable {
    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!
        let conveyorWidth = mappedFeature["Conveyor Width"]

        query.whereKey("data.conveyor_width", equalTo: conveyorWidth)

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Conveyor Oven ###")
        __compute(delegate: self, type: .conveyorOven, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            guard   let preheatEnergyRate = data["preheat_energy"] as? Double,
                    let idleEnergyRate = data["idle_rate"] as? Double,
                    let fanEnergyRate = data["fan_control_energy_rate"] as? Double,
                    let fuelType = data["fuel_type"] else {

                Log.message(.error, message: "Pre Heat | Idle | Fan Control Energy Rate Nil")
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy: Double = fanEnergyRate * operatingHours

            switch EFuelType.eVal(rawValue: fuelType) {
            case .gas: gasEnergy = idleEnergyRate * idleRunHours + preheatEnergyRate * operatingHours
            case .electric: electricEnergy = 0.0
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
            "company", "model_name", "model_number", "conveyor_width", "fuel_type", "preheat_energy", "idle_rate",
            "energy_efficiency", "production_capacity", "fan_control_energy_rate", "rebate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}

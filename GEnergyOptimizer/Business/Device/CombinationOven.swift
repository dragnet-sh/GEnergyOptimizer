//
// Created by Binay Budhthoki on 3/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class CombinationOven: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!
        let size = mappedFeature["Size (Steam Pans)"]
        let fuelType = mappedFeature["Fuel Type"]

        query.whereKey("data.size", equalTo: size)
        query.whereKey("data.fuel_type", equalTo: fuelType)
        
        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Combination Oven ###")
        __compute(delegate: self, type: .combinationOven, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            //ToDo: Some entries have "-" as the value for Preheat Energy - Handle this !!
            guard   let preheatEnergyRate = data["preheat_energy"] as? Double,
                    let idleEnergyRate = data["idle_rate"] as? Double,
                    let fuelType = data["fuel_type"] else {

                Log.message(.error, message: "Pre Heat Energy | Idle Energy Rate | Fuel Type Nil")
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy = 0.0

            switch EFuelType.eVal(rawValue: fuelType) {
            case .gas: gasEnergy = preheatEnergyRate * operatingHours + idleEnergyRate * idleRunHours
            case .electric: electricEnergy = idleEnergyRate * idleRunHours
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
            "company", "model_number", "size", "fuel_type", "preheat_energy", "idle_rate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}
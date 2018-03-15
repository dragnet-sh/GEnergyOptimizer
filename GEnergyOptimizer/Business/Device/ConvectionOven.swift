//
// Created by Binay Budhathoki on 3/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class ConvectionOven: EnergyBase, Computable {
    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!

        let productionCapacity = mappedFeature["Production Capacity (lbs/h)"]
        let size = mappedFeature["Oven Size"]
        let fuelType = mappedFeature["Fuel Type"]

        print(productionCapacity.debugDescription)
        print(size.debugDescription)
        print(fuelType.debugDescription)

        query.whereKey("data.production_capacity", equalTo: productionCapacity)
        query.whereKey("data.oven_size", equalTo: size)
        query.whereKey("data.fuel_type", equalTo: fuelType)

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Convection Oven ###")
        __compute(delegate: self, type: .convectionOven, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            print(data["preheat_energy"])
            print(data["idle_energy_rate"])
            print(data["fan_control_energy"])
            print(data["fuel_type"])

            guard   let preheatEnergyRate = data["preheat_energy"] as? Double,
                    let idleEnergyRate = data["idle_energy_rate"] as? Double,
                    let fanEnergyRate = data["fan_control_energy"] as? Double,
                    let fuelType = data["fuel_type"] else {

                Log.message(.error, message: "Pre Heat | Idle | Fan Control Energy Rate Nil")
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy: Double = fanEnergyRate * operatingHours

            switch EFuelType.eVal(rawValue: fuelType) {
            case .gas: gasEnergy = preheatEnergyRate * operatingHours + idleEnergyRate * idleRunHours
            case .electric: electricEnergy += (idleEnergyRate * idleRunHours + preheatEnergyRate * operatingHours)
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
            "company", "model_number", "oven_size", "fuel_type", "preheat_energy", "idle_energy_rate",
            "energy_efficiency", "production_capacity", "fan_control_energy", "rebate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}

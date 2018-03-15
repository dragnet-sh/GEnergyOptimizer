//
// Created by Binay Budhathoki on 3/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Griddle: EnergyBase, Computable {
    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!

        let side = mappedFeature["Number of Sides"]
        let fuelType = mappedFeature["Fuel Type"]
        let width = mappedFeature["Nominal Width"]
        let area = mappedFeature["Surface Area"]

        query.whereKey("data.single_or_double_sided", equalTo: side)
        query.whereKey("data.fuel_type", equalTo: fuelType)
        query.whereKey("data.nominal_width", equalTo: width)
        query.whereKey("data.surface_area", equalTo: area)

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Griddle ###")
        __compute(delegate: self, type: .griddle, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            guard   let preheatEnergyGas = data["prehat_energy_gas"] as? Double,
                    let preheatEnergyElectric = data["preheat_energy_electric"] as? Double,
                    let idleEnergyGas = data["idle_energy_gas"] as? Double,
                    let idleEnergyElectric = data["idle_energy_electric"] as? Double,
                    let fuelType = data["fuel_type"] else {

                Log.message(.error, message: "Pre Heat | Idle Energy (Electric - Gas) Rate Nil")
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy = 0.0

            switch EFuelType.eVal(rawValue: fuelType) {
            case .gas: gasEnergy = preheatEnergyGas * operatingHours + idleEnergyGas * idleRunHours
            case .electric: electricEnergy = preheatEnergyElectric * operatingHours + idleEnergyElectric * idleRunHours
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
            "company", "model_number", "single_or_double_sided", "fuel_type", "nominal_width", "surface_area",
            "prehat_energy_gas", "preheat_energy_electric", "idle_energy_gas", "idle_energy_electric", "energy_efficiency",
            "production_capacity", "rebate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}
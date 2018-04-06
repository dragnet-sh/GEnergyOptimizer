//
// Created by Binay Budhathoki on 3/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class IceMaker: EnergyBase, Computable {
    override func filterQuery() -> PFQuery<PFObject>? {
        let query = PlugLoad.query()!

        let iceHarvestRate = mappedFeature["Ice Harvest Rate"]
        let energyUseRate = mappedFeature["Energy Use Rate"]
        let iceType = mappedFeature["Ice Type"]
        guard let machineType = mappedFeature["Machine Type"] else {return nil}

        query.whereKey("data.ice_harvest_rate", equalTo: iceHarvestRate)
        query.whereKey("data.energy_use_rate", equalTo: energyUseRate)
        query.whereKey("data.ice_type", equalTo: iceType)
        query.whereKey("data.machine_type", matchesRegex: GUtils.toString(subject: machineType), modifiers: "i")

        return query
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Ice Maker ###")
        __compute(delegate: self, type: .iceMaker, handler: { (data) in

            var entry = EnergyBase.createEntry(self, data)

            let idleRunHours = super.dailyOperatingHours()
            let operatingHours = super.dailyOperatingHours()

            guard let energyUseRate = data["energy_use_rate"] as? Double else {
                Log.message(.error, message: "Energy Use Rate Nil")
                return nil
            }

            var gasEnergy = 0.0
            var electricEnergy = 0.0
            electricEnergy = energyUseRate * operatingHours

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
            "company", "machine_type", "model_number", "ice_type", "ice_harvest_rate", "energy_use_rate", "rebate",

            "__idle_run_hours", "__daily_operating_hours", "__gas_energy", "__electric_energy",
            "__gas_cost", "__electric_cost", "__total_cost"
        ]
    }
}

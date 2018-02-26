//
// Created by Binay Budhthoki on 2/26/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Fryer: EnergyBase, Computable {
    lazy var rateStructure: String = {
        GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
    }()

    lazy var operatingHours: String = {
        GUtils.toString(subject: preAudit["Monday Operating Hours"]!)
    }()

    lazy var filterAlternateMatch: PFQuery<PFObject> = {
        let query = PlugLoad.query()!
        let productionCapacity = mappedFeature["Production Capacity (lbs/h)"]
        let vatWidth = mappedFeature["Vat Width (in)"]
        let fuelType = mappedFeature["Fuel Type"]

        query.whereKey("data.production_capacity", equalTo: productionCapacity)
        query.whereKey("data.vat_width", equalTo: vatWidth)
        query.whereKey("data.fuel_type", equalTo: fuelType)
        query.whereKey("type", equalTo: "fryers_retrofits")

        return query
    }()

    func compute() {
        let electric = ElectricCost(rateStructure: rateStructure, operatingHours: operatingHours)
        let gas = GasCost()
        let bestModel = BestModel(query: self.filterAlternateMatch)

        super.starValidator {
            bestModel.query(curr_values: self.mappedFeature) { fryers in
                fryers.forEach { fryer in
                    //ToDo: Verify where do these values come from
                    let idleRunHours = 7.0
                    let daysInOperation = 7.0

                    if let preheatEnergy = fryer.data["preheat_energy"] as? Double, let idleEnergyRate = fryer.data["idle_energy_rate"] as? Double {
                        let gasEnergy = preheatEnergy * daysInOperation + idleRunHours * idleEnergyRate
                        let gasCost = gas.cost(energyUsed: gasEnergy)
                        let electricCost = electric.cost(energyUsed: idleEnergyRate)
                        let totalCost = gasCost + electricCost
                        Log.message(.warning, message: "Calculated Energy Value Cost [Plugload : Fryer] - \(totalCost.description)")
                    }
                }
            }
        }
    }
}
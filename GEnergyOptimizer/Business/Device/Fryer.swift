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

    func compute(complete: @escaping (OutgoingRows?) -> Void) {
        let electric = ElectricCost(rateStructure: rateStructure, operatingHours: super.operatingHours)
        let gas = GasCost()
        let bestModel = BestModel(query: self.filterAlternateMatch)

        super.starValidator {
            bestModel.query(curr_values: self.mappedFeature) { fryers in
                fryers.forEach { appliance in
                    var entry = EnergyBase.createEntry(self, appliance.data)

                    //ToDo: Verify where do these values come from
                    let idleRunHours = 7.0
                    let daysInOperation = 7.0

                    if let preheatEnergy = appliance.data["preheat_energy"] as? Double, let idleEnergyRate = appliance.data["idle_energy_rate"] as? Double {
                        let gasEnergy = preheatEnergy * daysInOperation + idleRunHours * idleEnergyRate
                        let gasCost = gas.cost(energyUsed: gasEnergy)
                        let electricCost = electric.cost(energyUsed: idleEnergyRate)
                        let totalCost = gasCost + electricCost
//                        Log.message(.warning, message: "Calculated Energy Value Cost [Plugload : Fryer] - \(totalCost.description)")

                        entry["__gas_energy"] = gasEnergy.description
                        entry["__gas_cost"] = gasCost.description
                        entry["__electric_cost"] = electricCost.description
                        entry["__cost"] = totalCost.description
                    }

                    entry["__idle_run_hours"] = idleRunHours.description
                    entry["__days_in_operation"] = daysInOperation.description

                    super.outgoing.append(entry)
                }

                let entity = EApplianceType.getFileName(type: .fryer)
                let result = OutgoingRows(rows: super.outgoing, entity: entity)
                result.setHeader(header: self.fields()!)
                complete(result)
            }
        }
    }

    func fields() -> [String]? {
        return [
            "company", "energy_efficiency", "fuel_type", "idle_energy_rate", "model_number", "preheat_energy",
            "production_capacity", "rebate", "shortening_capacity", "vat_width",

            "__idle_run_hours", "__days_in_operation", "__gas_energy", "__gas_cost", "__electric_cost", "__cost"
        ]
    }
}
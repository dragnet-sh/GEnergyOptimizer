//
// Created by Binay Budhthoki on 2/15/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Refrigerator: EnergyBase, Computable {

    lazy var rateStructure: String = {
        GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
    }()

    lazy var filterAlternateMatch: PFQuery<PFObject> = {
        let query = PlugLoad.query()!
        let type = mappedFeature["Product Type"]
        let volume = mappedFeature["Total Volume"]

        query.whereKey("data.style_type", equalTo: type)
        query.whereKey("data.total_volume", equalTo: volume)

        return query
    }()

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        let electric = ElectricCost(rateStructure: rateStructure, operatingHours: super.operatingHours)
        let bestModel = BestModel(query: self.filterAlternateMatch)
        let hourEnergyUse = 10.0

        super.starValidator { status, error in
            Log.message(.error, message: "################################################################")
            Log.message(.error, message: error.debugDescription)

            if error == .none {
                bestModel.query(curr_values: self.mappedFeature) { result in
                    Log.message(.info, message: "Best Model Query Loop !!")
                    switch result {
                    case .Success(let data):
                        data.forEach { appliance in
                            var entry = EnergyBase.createEntry(self, appliance.data)

                            //ToDo: Where does this value come from
                            var hourEnergyUse = 10.0
                            var totalCost = electric.cost(energyUsed: hourEnergyUse)
                            Log.message(.warning, message: "Calculated Energy Value Cost [Plugload : Refrigerator] - \(totalCost.description)")

                            entry["__hour_energy_use"] = hourEnergyUse.description
                            entry["__cost"] = totalCost.description
                            super.outgoing.append(entry)
                        }

                        let entity = EApplianceType.getFileName(type: .freezerFridge)
                        let result = OutgoingRows(rows: super.outgoing, entity: entity)
                        result.setHeader(header: self.fields()!)
                        complete(result)

                    case .Error(let message):
                        Log.message(.error, message: message)
                        complete(nil)
                    }
                }
            } else {
                Log.message(.error, message: "Returning ************** After Star Validator")
                complete(nil)
            }
        }
    }

    func fields() -> [String]? {
        return [
            "company", "daily_energy_use", "pgne_measure_code", "purchase_price_per_unit",
            "rebate", "style_type", "total_volume", "vendor", "__hour_energy_use", "__cost"
        ]
    }
}

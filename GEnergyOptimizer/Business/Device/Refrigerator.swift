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

    func compute(complete: @escaping (OutgoingRows?) -> Void) {
        let electric = ElectricCost(rateStructure: rateStructure, operatingHours: super.operatingHours)
        let bestModel = BestModel(query: self.filterAlternateMatch)
        let hourEnergyUse = 10.0

        super.starValidator {
            bestModel.query(curr_values: self.mappedFeature) { freezers in
                freezers.map { freezer in
                    var entry = [String: String]()
                    if let fields = self.fields() {
                        fields.forEach { field in
                            if let value = freezer.data[field] { entry[field] = String(describing: value) }
                            else { entry[field] = "" }
                        }
                    }

                    //ToDo: Where does this value come from
                    var hourEnergyUse = 10.0
                    var totalCost = electric.cost(energyUsed: hourEnergyUse)
                    Log.message(.warning, message: "Calculated Energy Value Cost [Plugload : Refrigerator] - \(totalCost.description)")

                    entry["__hour_energy_use"] = hourEnergyUse.description
                    entry["__cost"] = totalCost.description
                    super.outgoing.append(entry)
                }

                let entity = EApplianceType.getFileName(type: .freezerFridge)
                let type = OutgoingRows.type.computed
                let result = OutgoingRows(rows: super.outgoing, entity: entity, type: type)
                complete(result)
            }
        }
    }

    func fields() -> [String]? {
        return [
            "company", "daily_energy_use", "pgne_measure_code", "purchase_price_per_unit",
            "rebate", "style_type", "total_volume", "vendor"
        ]
    }
}

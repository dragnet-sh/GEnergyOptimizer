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

    lazy var operatingHours: String = {
        GUtils.toString(subject: preAudit["Monday Operating Hours"]!)
    }()

    lazy var filterAlternateMatch: PFQuery<PFObject> = {
        let query = PlugLoad.query()!
        let type = mappedFeature["Product Type"]
        let volume = mappedFeature["Total Volume"]

        query.whereKey("data.style_type", equalTo: type)
        query.whereKey("data.total_volume", equalTo: volume)

        return query
    }()

    func compute() {
        let electric = ElectricCost(rateStructure: rateStructure, operatingHours: operatingHours)
        let bestModel = BestModel(query: self.filterAlternateMatch)
        let hourEnergyUse = 10.0

        super.starValidator {
            bestModel.query(curr_values: self.mappedFeature) { freezers in
                freezers.map { freezer in
                    //ToDo: Where does this value come from
                    var hourEnergyUse = 10.0
                    var totalCost = electric.cost(energyUsed: hourEnergyUse)
                    Log.message(.warning, message: "Calculated Energy Value Cost [Plugload : Refrigerator] - \(totalCost.description)")
                }
            }
        }
    }
}
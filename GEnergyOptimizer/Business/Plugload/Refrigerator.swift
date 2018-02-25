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
        let type = String(describing: mappedFeature["Product Type"]!)
        let volume = String(describing: mappedFeature["Total Volume"]!)

        query.whereKey("data.style_type", equalTo: type)
        query.whereKey("data.total_volume", equalTo: Double(volume))

        return query
    }()


    func compute() {
        let energyStar = EnergyStar(mappedFeature: self.mappedFeature)
        energyStar.query() { status in
            if (status) { return }
            Log.message(.warning, message: self.mappedFeature.debugDescription)

            var electric = ElectricCost(rateStructure: self.rateStructure, operatingHours: self.operatingHours)
            let bestModel = BestModel(query: self.filterAlternateMatch)
            bestModel.query(curr_values: self.mappedFeature) { freezers in
                Log.message(.warning, message: freezers.debugDescription)
                freezers.map { freezer in
                    var hourEnergyUse = 10.0 // ****** The final missing piece !!
                    var totalCost = electric.cost(energyUsed: hourEnergyUse)
                    Log.message(.warning, message: "Calculated Energy Value - \(totalCost.description)")
                }
            }
        }
    }
}

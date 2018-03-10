//
// Created by Binay Budhthoki on 2/26/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class HVAC: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        return nil
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - HVAC ###")
        let feature = super.mappedFeature
        Log.message(.warning, message: feature.debugDescription)

        guard   let btuPerHour = feature["Cooling Capacity (Btu/hr)"] as? Int64,
                let seer = feature["SEER"] as? Int64 else {

            Log.message(.error, message: "Cooling Capacity | SEER Nil")
            complete(nil)
            return
        }

        let annualOperationHours = super.annualOperatingHours()
        let power = Double(btuPerHour / seer) / 1000
        let energy = power * annualOperationHours

        Log.message(.info, message: "Calculated Energy Value [HVAC] - \(energy.description)")

        var entry = EnergyBase.createEntry(self, feature)
        entry["__annual_operation_hours"] = annualOperationHours.description
        entry["__power"] = power.description
        entry["__energy"] = energy.description

        super.outgoing.append(entry)

        let entity = EZone.hvac.rawValue
        let result = OutgoingRows(rows: super.outgoing, entity: entity)
        result.setHeader(header: fields()!)
        complete(result)
    }

    func fields() -> [String]? {
        return [
            "Cooling Capacity (Btu/hr)", "SEER",

            "__annual_operation_hours", "__power", "__energy"
        ]
    }
}
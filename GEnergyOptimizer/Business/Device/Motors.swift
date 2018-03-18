//
// Created by Binay Budhathoki on 3/18/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Motors: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        return nil
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Motors ###")
        let feature = super.mappedFeature
        Log.message(.warning, message: feature.debugDescription)

        guard   let srs = feature["Synchronous Rotational Speed (SRS)"] as? Int64,
                let mrs = feature["Measured Rotational Speed (MRS)"] as? Int64,
                let nrs = feature["Nameplate Rotational Speed (NRS)"] as? Int64,
                let hp = feature["Horsepower (HP)"] as? Int64,
                let efficiency = feature["Efficiency"] as? Int64,
                let hourPercentage = feature["Hours (%)"] as? Int64 else {

            Log.message(.error, message: "SRS | MRS | NRS | HP | Efficiency | Hours % Nil")
            complete(nil)
            return
        }

        let percentageLoad = Double(srs - mrs) / Double(srs - nrs)
        let power = Double(hp) * 0.746 * Double(percentageLoad) / Double(efficiency)
        let time = hourPercentage * 8760
        let energy = power * Double(time)

        Log.message(.info, message: "Calculated Energy Value [Motors] - \(energy.description)")
        var entry = EnergyBase.createEntry(self, feature)
        entry["__percentage_load"] = percentageLoad.description
        entry["__annual_operation_hours"] = time.description
        entry["__power"] = power.description
        entry["__energy"] = energy.description

        super.outgoing.append(entry)

        let entity = EZone.motors.rawValue
        let result = OutgoingRows(rows: super.outgoing, entity: entity)
        result.setHeader(header: fields()!)
        complete(result)
    }

    func fields() -> [String]? {
        return [
            "Synchronous Rotational Speed (SRS)", "Measured Rotational Speed (MRS)", "Nameplate Rotational Speed (NRS)",
            "Horsepower (HP)", "Efficiency", "Hours (%)",

            "__percentage_load", "__annual_operation_hours", "__power", "__energy"
        ]
    }
}
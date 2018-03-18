//
// Created by Binay Budhathoki on 3/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class Lighting: EnergyBase, Computable {

    override func filterQuery() -> PFQuery<PFObject>? {
        return nil
    }

    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        Log.message(.info, message: "### Computing - Lighting ###")
        let feature = super.mappedFeature
        Log.message(.warning, message: feature.debugDescription)

        guard   let actualWatts = feature["Actual Watts"] as? Int64,
                let ballastFixture = feature["Ballasts/Fixture"] as? Int64,
                let numberOfFixtures = feature["Number of Fixtures"] as? Int64,
                let hourPercentage = feature["Hours (%)"] as? Int64 else {

            Log.message(.error, message: "Actual Watts | Ballasts/Fixture | Number of Fixtures | Hour % Nil")
            complete(nil)
            return
        }

        let power = actualWatts * ballastFixture * numberOfFixtures
        let time = hourPercentage * 8760
        let energy = power * time

        Log.message(.info, message: "Calculated Energy Value [Lighting] - \(energy.description)")
        var entry = EnergyBase.createEntry(self, feature)
        entry["__annual_operation_hours"] = time.description
        entry["__power"] = power.description
        entry["__energy"] = energy.description

        super.outgoing.append(entry)

        let entity = EZone.lighting.rawValue
        let result = OutgoingRows(rows: super.outgoing, entity: entity)
        result.setHeader(header: fields()!)
        complete(result)
    }

    func fields() -> [String]? {
        return [
            "Measured Lux", "Area", "Lamp Type", "Ballasts/Fixture", "Number of Fixtures", "Model Number",

            "__annual_operation_hours", "__power", "__energy"
        ]
    }
}
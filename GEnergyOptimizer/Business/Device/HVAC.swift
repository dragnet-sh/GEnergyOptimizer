//
// Created by Binay Budhthoki on 2/26/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class HVAC: EnergyBase, Computable {
    func compute(_ complete: @escaping (OutgoingRows?) -> Void) {
        let feature = super.mappedFeature
        let preaudit = super.preAudit

        Log.message(.warning, message: feature.debugDescription)
        if let btuPerHour = feature["Cooling Capacity (Btu/hr)"] as? Int64, let seer = feature["SEER"] as? Int64 {
            let annualOperationHours: Double = PeakHourMapper().annualOperatingHours(super.operatingHours)
            let power = Double(btuPerHour / seer) / 1000
            let energy: Double = power * annualOperationHours

            Log.message(.warning, message: "Calculated Energy Value [HVAC] - \(energy.description)")

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
    }

    func fields() -> [String]? {
        return [
             "Cooling Capacity (Btu/hr)", "SEER", "__annual_operation_hours", "__power", "__energy"
        ]
    }
}
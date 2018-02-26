//
// Created by Binay Budhthoki on 2/26/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class HVAC: EnergyBase, Computable {
    func compute() {
        let feature = super.mappedFeature
        let preaudit = super.preAudit

        Log.message(.warning, message: feature.debugDescription)
        if let btuPerHour = feature["Cooling Capacity (Btu/hr)"], let seer = feature["SEER"] {
            let annualOperationHours = 8760.00
            let power = Double(String(describing: btuPerHour))! / Double(String(describing: seer))! / 1000
            let energy: Double = power * annualOperationHours

            Log.message(.warning, message: "Calculated Energy Value [HVAC] - \(energy.description)")
        }
    }
}
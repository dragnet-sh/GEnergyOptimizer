//
// Created by Binay Budhthoki on 2/22/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class UtilityMapper {

    func getBillData(bill_type: String) -> Dictionary<EPeak, Double> {
        let rows = GUtils.openCSV(filename: "pge_electric")!
        var outgoing = Dictionary<EPeak, Double>()
        for row in rows {
            if row["rate"]! == bill_type {
                let key = "\(row["season"]!)-\(row["ec_period"]!)"
                outgoing[GUtils.getEPeak(rawValue: key)] = Double(row["energy_charge"]!)
            }
        }

        return outgoing
    }
}
//
// Created by Binay Budhthoki on 2/22/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

// **** Needs to give both Gas and Electric Rate Structure Mapped on a Standard Layout ****

protocol UtilityMapper {
    func getBillData() -> Dictionary<ERateKey, Double>
}

public class ElectricRate: UtilityMapper {
    var type: String
    var utilityCompany: String

    init(type: String) {
        self.type = type
        self.utilityCompany = "pge_electric"
    }

    func getBillData() -> Dictionary<ERateKey, Double>? {
        let rows = GUtils.openCSV(filename: utilityCompany)!
        var outgoing = Dictionary<ERateKey, Double>()
        let gas = ERateKey.getAllGas
        gas.forEach() { outgoing[$0] = 0.0 }



        rows.forEach { row in

            guard   let rate = row["rate"],
                    let season = row["season"],
                    let period = row["ec_period"] else {
                Log.message(.error, message: "Utility Rate CSV is probably invalid.")
                return nil
            }

            if rate == type {
                let key = "\(season)-\(period)"
                outgoing[GUtils.getEPeak(rawValue: key)] = Double(row["energy_charge"]!)
            }
        }

        return outgoing
    }
}

// *** Averages the Gas Rate *** //
public class GasRate: UtilityMapper {
    var utilityCompany: String

    init() {
        self.utilityCompany = "pge_gas"
    }

    func getBillData() -> Dictionary<ERateKey, Double> {
        let rows = GUtils.openCSV(filename: utilityCompany)!
        var outgoing = Dictionary<ERateKey, Double>()
        let gas = ERateKey.getAllGas
        gas.forEach() { outgoing[$0] = 0.0 }

        rows.forEach { row in
            gas.forEach() { outgoing[$0]! += Double(row[$0.rawValue]! as String)! }
        }

        gas.forEach() { outgoing[$0] = outgoing[$0]! / Double(rows.count) }

        return outgoing
    }
}
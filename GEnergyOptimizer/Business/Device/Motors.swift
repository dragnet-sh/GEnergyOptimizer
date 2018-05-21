//
// Created by Binay Budhathoki on 3/18/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

//ToDo: Use the Peak Hours which are the placeholders as of now and calculate the Peak Hours Cost on the basis
//of operating hours -- the difference would be the savings if used efficiently
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
                let efficiency = feature["Efficiency"] as? Double,
                let hourPercentage = feature["Hours (%)"] as? Double else {

            Log.message(.error, message: "SRS | MRS | NRS | HP | Efficiency | Hours % Nil")
            complete(nil)
            return
        }

        let percentageLoad = Double(srs - mrs) / Double(srs - nrs)
        let power = Double(hp) * 0.746 * Double(percentageLoad) / Double(efficiency)
        let time = hourPercentage * 8760
        let energy = Double(power) * Double(time)
        let electricCost = super.electricCost().cost(energyUsed: Double(power))

        // Motor Cost
        // -- New Motor depends on the Motor Size HP
        // -- Minimum Allowable Efficiency for that HP
        // -- Cross Reference this

        var totalHours : Double = 0.0

        if let peakHours = feature["Peak Hours"] as? Double {totalHours += peakHours}
        if let partPeakHours = feature["Part Peak Hours"] as? Double {totalHours += partPeakHours}
        if let offPeakHours = feature["Off Peak Hours"] as? Double {totalHours += offPeakHours}
        let operationHoursActual: Double = totalHours * 365.00

        Log.message(.error, message: totalHours.description)
        let electricCostActual = super.electricCostActual(totalHours: operationHoursActual).cost(energyUsed: Double(power))

        Log.message(.info, message: "Calculated Energy Value [Motors] - \(energy.description)")
        var entry = EnergyBase.createEntry(self, feature)
        entry["__percentage_load"] = percentageLoad.description
        entry["__annual_operation_hours_%h"] = time.description
        entry["__power"] = power.description
        entry["__energy"] = energy.description
        entry["__total_cost"] = electricCost.description

        entry["__annual_operation_hours_actual"] = operationHoursActual.description
        entry["__total_cost_actual"] = electricCostActual.description
        entry["__annual_operation_hours_pa"] = super.annualOperatingHours().description
        Log.message(.error, message: entry.description)

        super.outgoing.append(entry)

        let entity = EZone.motors.rawValue
        let result = OutgoingRows(rows: super.outgoing, entity: entity, zone: self.zone)
        result.setHeader(header: fields()!)
        complete(result)
    }

    func fields() -> [String]? {
        return [
            "Synchronous Rotational Speed (SRS)", "Measured Rotational Speed (MRS)", "Nameplate Rotational Speed (NRS)",
            "Horsepower (HP)", "Efficiency", "Hours (%)",

            "__percentage_load", "__annual_operation_hours_%h", "__power", "__energy", "__total_cost",
            "__annual_operation_hours_actual", "__total_cost_actual", "__annual_operation_hours_pa"
        ]
    }
}
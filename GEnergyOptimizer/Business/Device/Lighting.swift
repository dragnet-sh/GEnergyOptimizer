//
// Created by Binay Budhathoki on 3/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse


//ToDo: Use the Peak Hours which are the placeholders as of now and calculate the Peak Hours Cost on the basis
//ToDo: of operating hours -- the difference would be the savings if used efficiently
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
                let hourPercentage = feature["Hours (%)"] as? Double else {

            Log.message(.error, message: "Actual Watts | Ballasts/Fixture | Number of Fixtures | Hour % Nil")
            complete(nil)
            return
        }

        let power = Double(actualWatts * ballastFixture * numberOfFixtures) / 1000.00
        let time = hourPercentage * 8760
        let energy = Double(power) * Double(time)
        let electricCost = super.electricCost().cost(energyUsed: Double(power))

        var totalHours : Double = 0.0

        if let peakHours = feature["Peak Hours"] as? Double {totalHours += peakHours}
        if let partPeakHours = feature["Part Peak Hours"] as? Double {totalHours += partPeakHours}
        if let offPeakHours = feature["Off Peak Hours"] as? Double {totalHours += offPeakHours}
        let operationHoursActual: Double = totalHours * 365.00

        Log.message(.error, message: totalHours.description)
        let electricCostActual = super.electricCostActual(totalHours: operationHoursActual).cost(energyUsed: Double(power))

        Log.message(.info, message: "Calculated Energy Value [Lighting] - \(energy.description)")
        var entry = EnergyBase.createEntry(self, feature)
        entry["__annual_operation_hours_%h"] = time.description
        entry["__power"] = power.description
        entry["__energy"] = energy.description
        entry["__total_cost"] = electricCost.description

        entry["__annual_operation_hours_actual"] = operationHoursActual.description
        entry["__total_cost_actual"] = electricCostActual.description
        entry["__annual_operation_hours_pa"] = super.annualOperatingHours().description
        Log.message(.error, message: entry.description)

        super.outgoing.append(entry)

        let entity = EZone.lighting.rawValue
        let result = OutgoingRows(rows: super.outgoing, entity: entity, zone: self.zone)
        result.setHeader(header: fields()!)
        complete(result)
    }

    func fields() -> [String]? {
        return [
            "Measured Lux", "Area", "Lamp Type", "Ballasts/Fixture", "Number of Fixtures", "Model Number",

            "__annual_operation_hours_%h", "__power", "__energy", "__total_cost",
            "__annual_operation_hours_actual", "__total_cost_actual", "__annual_operation_hours_pa"
        ]
    }
}
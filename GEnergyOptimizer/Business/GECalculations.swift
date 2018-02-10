//
//  GECalculations.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/5/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import CSV
import CSwiftV

public class GEnergyCalculations {

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var state = StateController.sharedInstance

    func test() {
        Log.message(.warning, message: "******* DEBUG MESSAGE FROM XCTest !! *******")
        state.registerAuditIdentifier(auditIdentifier: "test-001")
        compute()
    }
}


extension GEnergyCalculations {

    func compute() {
        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                guard let results = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Zone")
                    return
                }

                for zone in results {
                    // *** Model | Company *** //
                    // *** Extract the Plugload Feature Data *** //

                    guard let feature = zone.hasFeature?.allObjects as? [CDFeatureData] else {
                        Log.message(.error, message: "Guard Failed : Feature Data - Core Data Zone")
                        return
                    }

                    switch GUtils.getEAppliance(rawValue: zone.type!) {
                    case .freezerFridge: __compute__freezer__fridge(feature: feature)
                    case .fryer: __compute__fryer(feature: feature)
                    default: Log.message(.warning, message: zone.type!)
                    }
                }
            }
        }
    }


    func __compute__freezer__fridge(feature: [CDFeatureData]) {

        var curr_values = mapFeatureData(feature: feature)
        Log.message(.warning, message: curr_values.debugDescription)

        let model_number = String(describing: curr_values["Model Number"]!)
        let company = String(describing: curr_values["Company"]!)

        // **** Check to see if the device is already an Energy Star Rated **** //

        let energy_star = is_energy_star(model_number: model_number, company: company) { status in
            if (status) {
                Log.message(.warning, message: "**** Energy Star - \(company) - \(model_number) ****")
                return
            }

            // **** Proceed with finding the Energy Efficient Device **** //

            let best_model_num = self.find_best_model_fridge_freezer(curr_values: curr_values) { freezers in

                Log.message(.warning, message: freezers.debugDescription)

                for freezer in freezers {
                    var pricing_chart = self.get_bill_data(bill_type: "A-1 TOU")
                    let peak = PeakHourCalculator()
                    var peak_hour_schedule = peak.run(usage: "14:30 21:30,6:30 12:30")
                    var hour_energy_use = 10.0

                    var summer = Double(peak_hour_schedule["summer-on-peak"]!) * hour_energy_use * Double(pricing_chart["summer-on-peak"]!)
                    summer += Double(peak_hour_schedule["summer-part-peak"]!) * hour_energy_use * Double(pricing_chart["summer-part-peak"]!)
                    summer += Double(peak_hour_schedule["summer-off-peak"]!) * hour_energy_use * Double(pricing_chart["summer-off-peak"]!)

                    var winter = Double(peak_hour_schedule["winter-part-peak"]!) * hour_energy_use * Double(pricing_chart["winter-part-peak"]!)
                    winter += Double(peak_hour_schedule["winter-off-peak"]!) * hour_energy_use * Double(pricing_chart["winter-off-peak"]!)

                    var total_electric = summer + winter
                    var total_cost = total_electric

                    Log.message(.warning, message: "Calculated Energy Value - \(total_cost.description)")
                }
            }
        }
    }

    func __compute__fryer(feature: [CDFeatureData]) {

        var curr_values = mapFeatureData(feature: feature)
        Log.message(.warning, message: curr_values.debugDescription)
    }

    func find_best_model_fridge_freezer(curr_values: Dictionary<String, Any>, complete: @escaping ([PlugLoad])->Void) {

        let prod_type = String(describing: curr_values["Product Type"]!)
        let total_volume = String(describing: curr_values["Total Volume"]!)
        let type = "solid_door_freezers_retrofits"

        if let query = PlugLoad.query() {

            query.whereKey("data.style_type", equalTo: prod_type)
            query.whereKey("data.total_volume", equalTo: Double(total_volume))
            query.findObjectsInBackground { object, error in
                if (error == nil) {
                    Log.message(.info, message: "Parse - Plugload Query - No Error")
                } else {
                    Log.message(.error, message: error.debugDescription)
                    return
                }

                guard let data = object as? [PlugLoad] else {
                    Log.message(.error, message: "Guard Failed : Plugload Data - Core Data Zone")
                    return
                }

                complete(data)
            }
        }


    }
}

// *** Helper Methods *** //
extension GEnergyCalculations {

    func mapFeatureData(feature: [CDFeatureData]) -> Dictionary<String, Any> {
        var curr_values = Dictionary<String, Any>()
        feature.map {
            let type = InitEnumMapper.sharedInstance.enumMap[$0.type!]
            if let eBaseType = type as? BaseRowType {
                switch eBaseType {
                case .intRow: curr_values[$0.key!] = $0.value_int
                case .decimalRow: curr_values[$0.key!] = $0.value_double
                default: curr_values[$0.key!] = $0.value_string
                }
            }
        }

        return curr_values
    }

    func is_energy_star(model_number: String, company: String, complete: @escaping (Bool)->Void) {
        Log.message(.warning, message: "Energy Star Check")

        if let query = PlugLoad.query() {

            query.whereKey("data.company", equalTo: company)
            query.whereKey("data.model_number", equalTo: model_number)

            query.findObjectsInBackground { object, error in
                if (error == nil) {
                    Log.message(.info, message: "Parse - Plugload Query - No Error")
                } else {
                    Log.message(.error, message: error.debugDescription)
                    return
                }

                guard let data = object as? [PlugLoad] else {
                    Log.message(.error, message: "Guard Failed : Plugload Data - Core Data Zone")
                    return
                }

                if (data.count > 0) {
                    complete(true)
                } else {
                    complete(false)
                }
            }
        }
    }

    func get_bill_data(bill_type: String) -> Dictionary<String, Double> {
        let rows = open_csv(filename: "pge_electric")!
        var outgoing = Dictionary<String, Double>()
        for row in rows {
            if row["rate"]! == bill_type {
                let key = "\(row["season"]!)-\(row["ec_period"]!)"
                outgoing[key] = Double(row["energy_charge"]!)
            }
        }

        return outgoing
    }

    func open_csv(filename: String) -> Array<Dictionary<String, String>>! {
        let url = Bundle.main.url(forResource: filename, withExtension: "csv")!
        let data = try! String(contentsOf: url)
        let csv = CSwiftV(with: data)

        return csv.keyedRows!
    }
}


class PeakHourCalculator {

    let dateFormatter = DateFormatter()
    var outgoing = Dictionary<String, Int>()

    init() {

        dateFormatter.dateFormat = "HH:mm"

        outgoing["summer-off-peak"] = 0
        outgoing["summer-part-peak"] = 0
        outgoing["summer-on-peak"] = 0
        outgoing["winter-off-peak"] = 0
        outgoing["winter-part-peak"] = 0
    }

    fileprivate func getTime(time: String) -> Date {
        return dateFormatter.date(from: time)!
    }

    fileprivate func inBetween(now: Date, start: Date, end: Date) -> Bool {
        let a = now.timeIntervalSince1970
        let b = start.timeIntervalSince1970
        let c = end.timeIntervalSince1970

        return (a >= b && a < c) ? true : false
    }

    fileprivate func isSummerPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "12:00"), end: getTime(time: "18:00"))
    }

    fileprivate func isSummerPartialPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "8:30"), end: getTime(time: "12:00")) ||
                inBetween(now: now, start: getTime(time: "18:00"), end: getTime(time: "21:30"))
    }

    fileprivate func isSummerOffPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "21:30"), end: getTime(time: "23:59")) ||
                inBetween(now: now, start: getTime(time: "00:00"), end: getTime(time: "8:30"))
    }

    fileprivate func isWinterPartialPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "8:30"), end: getTime(time: "9:30"))
    }

    fileprivate func isWinterOffPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "21:00"), end: getTime(time: "23:59")) ||
                inBetween(now: now, start: getTime(time: "00:00"), end: getTime(time: "8:30"))
    }

    public func run(usage: String) -> Dictionary<String, Int> {

//        let usage = "14:30 21:30,6:30 12:30"
        let usageSplit = usage.split(separator: ",")

        usageSplit.map {
            let timeRange = $0.split(separator: " ")
            let start = dateFormatter.date(from: String(timeRange[0]))!
            let end = dateFormatter.date(from: String(timeRange[1]))!
            let delta = 1

            let calendar = Calendar.autoupdatingCurrent
            var step = DateComponents()
            step.minute = delta

            var _date = start
            while _date < end {

                if isSummerOffPeak(now: _date) {outgoing["summer-off-peak"]! += delta}
                if isSummerPartialPeak(now: _date) {outgoing["summer-part-peak"]! += delta}
                if isSummerPeak(now: _date) {outgoing["summer-on-peak"]! += delta}

                if isWinterOffPeak(now: _date) {outgoing["winter-off-peak"]! += delta}
                if isWinterPartialPeak(now: _date) {outgoing["winter-part-peak"]! += delta}

                _date = calendar.date(byAdding: step, to: _date)!
            }
        }

        return outgoing
    }
}
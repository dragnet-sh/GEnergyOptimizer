//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

protocol Computable {
    func compute(_ complete: @escaping (OutgoingRows?) -> Void)
    func fields() -> [String]?
}

class EnergyBase {
    var preAudit = Dictionary<String, Any>()
    var mappedFeature = Dictionary<String, Any>()
    var operatingHours = Dictionary<EDay, String>()
    var outgoing: [[String: String]]

    init(_ feature: [CDFeatureData]) {
        let preAudit = try! AuditFactory.sharedInstance.setPreAudit()
        self.preAudit = GUtils.mapFeatureData(feature: preAudit)
        self.mappedFeature = GUtils.mapFeatureData(feature: feature)
        self.operatingHours = GUtils.mapOperationHours(preAudit: preAudit)
        self.outgoing = [[String: String]]()
    }

    // ToDo: Relay this info back to the Main Class
    func starValidator(complete: @escaping (Bool, GError?) -> Void) {
        let energyStar = EnergyStar(mappedFeature: self.mappedFeature)
        energyStar.query() { status, error in
            complete(status, error)
        }
    }

    static func createEntry(_ object: Computable, _ feature: [String: Any]) -> [String: String] {
        var entry = [String: String]()
        if let fields = object.fields() {
            fields.filter {
                        !$0.starts(with: "__")
                    }
                    .forEach { field in
                        if let value = feature[field] {
                            entry[field] = String(describing: value)
                        } else {
                            entry[field] = ""
                        }
                    }
        }
        return entry
    }

    func utilityRate() -> String {
        let rate = GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
        return rate
    }

    func bestModel(complete: @escaping (Result<[PlugLoad]>) -> Void) {
        if let query = filterQuery() {
            BestModel(query: query).query { result in
                complete(result)
            }
            return
        }
        complete(.Error("Filter Query Not Set"))
    }

    open func filterQuery() -> PFQuery<PFObject>? {
        fatalError("Must be over-ridden")
    }

}

extension EnergyBase {
    func electricCost() -> EnergyCost {
        return ElectricCost(rateStructure: utilityRate(), operatingHours: operatingHours)
    }

    func gasCost() -> EnergyCost {
        return GasCost()
    }

    func annualOperatingHours() -> Double {
        return PeakHourMapper().annualOperatingHours(operatingHours)
    }

    func dailyOperatingHours() -> Double {
        return PeakHourMapper().dailyOperatingHours(operatingHours)
    }
}

extension EnergyBase {
    typealias FeatureDataEntry = (Dictionary<String, Any>) -> [String: String]?

    func __compute(delegate: Computable, type: EApplianceType,
                   handler: @escaping FeatureDataEntry, completed: @escaping (OutgoingRows?) -> Void) {

        starValidator { status, error in
            if error == .none {
                self.bestModel { result in
                    switch result {
                    case .Success(let data):
                        data.forEach { appliance in

                            // *** 1. Calculate Energy Consumption
                            // *** 2. Calculate Cost
                            // *** 3. Append the computed value to entry

                            if let _entry = handler(appliance.data) {
                                Log.message(.info, message: _entry.debugDescription)
                                self.outgoing.append(_entry)
                            } else {
                                Log.message(.error, message: "Entry Row Nil")
                                completed(nil)
                                return
                            }
                        }

                        let entity = EApplianceType.getFileName(type: type)
                        print(self.outgoing.debugDescription)

                        if let header = delegate.fields() {
                            let rows = OutgoingRows(rows: self.outgoing, entity: entity)
                            rows.setHeader(header: header)

                            completed(rows)
                        } else {completed(nil)}

                    case .Error(let message):
                        Log.message(.error, message: message)
                        completed(nil)
                    }
                }
            } else {
                Log.message(.error, message: "\(EApplianceType.rackOven.rawValue) : Star Validator Returned Nil")
                completed(nil)
            }
        }
    }
}


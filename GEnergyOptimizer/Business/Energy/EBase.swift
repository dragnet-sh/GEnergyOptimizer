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
            fields.filter { !$0.starts(with: "__") }
                    .forEach { field in
                        if let value = feature[field] { entry[field] = String(describing: value) }
                        else { entry[field] = "" }
                    }
        }
        return entry
    }

    func utilityRate() -> String {
        let rate = GUtils.toString(subject: preAudit["Electric Rate Structure"]!)
        Log.message(.info, message: "Utility Rate - \(rate.description)")
        return rate
    }

    func bestModel(complete: @escaping (Result<[PlugLoad]>) -> Void) {
        if let query = filterQuery() {
            BestModel(query: query).query {result in complete(result)}
            return
        }
        complete(.Error("Filter Query Not Set"))
    }

    open func filterQuery() -> PFQuery<PFObject>? {
        fatalError("Must be over-ridden")
    }
}



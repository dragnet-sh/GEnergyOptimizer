//
// Created by Binay Budhthoki on 2/22/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class EnergyStar {
    var filter: PFQuery<PFObject>?

    init(mappedFeature: Dictionary<String, Any>) {
        self.filter = matchFilter(query: PlugLoad.query()!, mappedFeature: mappedFeature)
    }

    func matchFilter(query: PFQuery<PFObject>, mappedFeature: Dictionary<String, Any>) -> PFQuery<PFObject>? {

        if let model_number = mappedFeature["Model Number"], let company = mappedFeature["Company"] {
            query.whereKey("data.company", equalTo: GUtils.toString(subject: company))
            query.whereKey("data.model_number", equalTo: GUtils.toString(subject: model_number))
            return query
        } else {
            Log.message(.error, message: "Alternate Match Filter - Query Parameters Nil.")
            return nil
        }
    }

    func query(complete: @escaping (Bool, GError?) -> Void) {
        Log.message(.warning, message: "Energy Star Check")

        guard let filter = self.filter else {
            Log.message(.error, message: "Guard Failed - Energy Star - Filter")
            complete(false, .guardFailed)
            return
        }

        filter.findObjectsInBackground { object, error in

            if let error = error as? NSError {
                if (error.code == 100) {
                    Log.message(.error, message: "Parse Network Not Available !!")
                    complete(false, .noNetwork)
                } else {
                    Log.message(.error, message: error.debugDescription)
                    complete(false, .parseResponseError)
                }
                return
            }

            guard let data = object as? [PlugLoad] else {
                Log.message(.error, message: "Guard Failed : PlugLoad Data - Core Data Zone")
                complete(false, .guardFailed)
                return
            }

            if (data.count > 0) {complete(true, .none)}
            else {complete(false, .none)}
        }
    }
}
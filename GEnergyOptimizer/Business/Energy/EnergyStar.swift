//
// Created by Binay Budhthoki on 2/22/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class EnergyStar {
    var filter: PFQuery<PFObject>!

    init(mappedFeature: Dictionary<String, Any>) {
        self.filter = matchFilter(query: PlugLoad.query()!, mappedFeature: mappedFeature)
    }

    func matchFilter(query: PFQuery<PFObject>, mappedFeature: Dictionary<String, Any>) -> PFQuery<PFObject> {
        let model_number = String(describing: mappedFeature["Model Number"]!)
        let company = String(describing: mappedFeature["Company"]!)

        query.whereKey("data.company", equalTo: company)
        query.whereKey("data.model_number", equalTo: model_number)

        return query
    }

    func query(complete: @escaping (Bool, GError?) -> Void) {
        Log.message(.warning, message: "Energy Star Check")

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
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

    func query(complete: @escaping (Bool) -> Void) {
        Log.message(.warning, message: "Energy Star Check")

        filter.findObjectsInBackground { object, error in
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

            if (data.count > 0) {complete(true)}
            else {complete(false)}
        }
    }
}
//
// Created by Binay Budhthoki on 2/22/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse
import CleanroomLogger

class BestModel {

    var filter: PFQuery<PFObject>

    init(query: PFQuery<PFObject>) {
        self.filter = query
    }

    func query(curr_values: Dictionary<String, Any>, complete: @escaping (Result<[PlugLoad]>) -> Void) {
        Log.message(.info, message: "Entry - Best Model")

        filter.findObjectsInBackground { object, error in

            if let error = error as? NSError {
                if (error.code == 100) {
                    Log.message(.error, message: "Parse Network Not Available")
                    complete(.Error("Parse Network Not Available"))
                } else {
                    Log.message(.error, message: error.debugDescription)
                    complete(.Error("Other Parse Network Error"))
                }
                return
            }

            guard let data = object as? [PlugLoad] else {
                Log.message(.error, message: "Guard Failed : PlugLoad Data - Core Data Zone")
                complete(.Error("Guard Failed : PlugLoad Data - Care Data Zone"))
                return
            }

            Log.message(.info, message: "Best Model Matches - \(data.count.description)")
            complete(.Success(data))
        }
    }
}
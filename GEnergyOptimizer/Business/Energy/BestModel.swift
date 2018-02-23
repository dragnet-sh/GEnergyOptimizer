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

    func query(curr_values: Dictionary<String, Any>, complete: @escaping ([PlugLoad]) -> Void) {
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

            complete(data)
        }
    }
}
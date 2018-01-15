//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

public class ZonePresenter {
    var data = [ZoneListDTO]()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = GEStateController.sharedInstance
}


extension ZonePresenter {
    func loadData(finished: @escaping (Source)->Void) {
        modelLayer.loadZoneData { [weak self] source, data in
            self?.data = data
            finished(source)
        }
    }

    func getActiveZone() -> String? {
        return state.getActiveZone()
    }

    func createZone(name: String, type: String) {
        Log.message(.info, message: "Creating Zone")
    }
}
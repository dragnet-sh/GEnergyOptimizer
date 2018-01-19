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
    func loadData() {
        modelLayer.loadZone { source, data in
            self.data = data
            NotificationCenter.default.post(name: .updateZoneTableData, object: nil)
        }
    }

    func getActiveZone() -> String? {
        return state.getActiveZone()
    }

    func createZone(name: String, type: String) {
        modelLayer.createZone(name: name, type: type) {
            self.loadData()
        }
    }

    func setActiveCDZone(cdZone: CDZone) {
        state.registerCDZone(cdZone: cdZone)
    }
}
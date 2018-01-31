//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

public class ZonePresenter: BasePresenter {
    var data = [ZoneDTO]()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance

    func loadData() {
        modelLayer.loadZone { source, data in
            self.data = data
            NotificationCenter.default.post(name: .updateZoneTableData, object: nil)
        }
    }
}

//Mark: - Zone Model CRUD

extension ZonePresenter {
    func deleteZone(guid: String) {
        modelLayer.deleteZone(guid: guid) {
            self.loadData()
        }
    }
}

//Mark: - Helper Methods

extension ZonePresenter {

    func getActiveZone() -> String? {
        return state.getActiveZone()
    }

    func setActiveCDZone(cdZone: CDZone) {
        state.registerCDZone(cdZone: cdZone)
    }

    func counter(action: EAction, dto: ZoneDTO? = nil) {
        state.counter(action: action, dto: dto)
    }

    func getCount() -> ENode {
        return state.getCount()
    }

    func getZoneHeader() -> String {
        if (getCount() == .child) { return "Appliances" }
        else {
            if let zone = state.getActiveZone() {
                return zone
            }
        }

        return EZone.none.rawValue
    }
}
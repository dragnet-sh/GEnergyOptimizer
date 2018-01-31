//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

public class RoomPresenter: BasePresenter {
    var data = [RoomDTO]()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance

    func loadData() {
        modelLayer.loadRoom { source, data in
            self.data = data
            NotificationCenter.default.post(name: .updateRoomTableData, object: nil)
        }
    }
}

extension RoomPresenter {
    func createRoom(name: String) {
        modelLayer.createRoom(name: name) {
            self.loadData()
        }
    }

    func deleteRoom(guid: String) {
        modelLayer.deleteRoom(guid: guid) {
            self.loadData()
        }
    }

    func updateRoom(guid: String, name: String) {
        modelLayer.updateRoom(guid: guid, name: name) {
            self.loadData()
        }
    }

    func setActiveCDRoom(cdRoom: CDRoom) {
        state.registerCDRoom(cdRoom: cdRoom)
    }

    func setActiveZone(zone: String) {
        state.registerActiveZone(zone: zone)
    }
}
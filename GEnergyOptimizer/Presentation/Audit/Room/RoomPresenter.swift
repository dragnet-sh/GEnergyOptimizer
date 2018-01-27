//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

public class RoomPresenter {
    var data = [RoomDTO]()
    fileprivate var modelLayer = ModelLayer()
}

extension RoomPresenter {
    func loadData() {
        modelLayer.loadRoom { source, data in
            self.data = data
            NotificationCenter.default.post(name: .updateRoomTableData, object: nil)
        }
    }

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
}
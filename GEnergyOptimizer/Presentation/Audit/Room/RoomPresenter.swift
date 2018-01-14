//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

public class RoomPresenter {
    var data = [RoomListDTO]()
    fileprivate var modelLayer = ModelLayer()
}


extension RoomPresenter {
    func loadData(finished: @escaping (Source)->Void) {
        modelLayer.loadRoomData { [weak self] source, data in
            self?.data = data
            finished(source)
        }
    }
}
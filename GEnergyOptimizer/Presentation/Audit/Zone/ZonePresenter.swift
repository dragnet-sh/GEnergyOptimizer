//
// Created by Binay Budhthoki on 1/14/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

public class ZonePresenter {
    var data = [ZoneListDTO]()
    fileprivate var modelLayer = ModelLayer()
}


extension ZonePresenter {
    func loadData(finished: @escaping (Source)->Void) {
        modelLayer.loadZoneData { [weak self] source, data in
            self?.data = data
            finished(source)
        }
    }
}
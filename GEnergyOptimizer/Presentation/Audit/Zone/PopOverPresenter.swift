//
// Created by Binay Budhthoki on 1/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class PopOverPresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance

    func loadData(vc: PopOverViewController) {
        modelLayer.loadPopOverData(vc: vc) { source, data in
            self.data = data
        }
    }
}

extension PopOverPresenter {
    func getCount() -> Int {
        return state.getCount()
    }

    func saveData(data: [String: Any?], vc: PopOverViewController, finished: @escaping (Bool)->Void) {
        modelLayer.savePopOverData(data: data, vc: vc) { status in
            finished(status)
        }
    }
}
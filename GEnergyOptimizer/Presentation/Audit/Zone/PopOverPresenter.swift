//
// Created by Binay Budhthoki on 1/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class PopOverPresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance
}

extension PopOverPresenter {
    func getCount() -> ENode {
        return state.getCount()
    }

    func saveData(data: [String: Any?], vc: PopOverViewController, delegate: ZonePresenter) {
        modelLayer.savePopOverData(data: data, vc: vc) { status in
            if (status) {
                delegate.loadData()
                GUtils.message(title: "N/A", msg: "Operation Complete", vc: vc, type: .toast)
            }
        }
    }
}
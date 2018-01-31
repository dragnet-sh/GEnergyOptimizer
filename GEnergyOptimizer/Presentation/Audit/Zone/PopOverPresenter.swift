//
// Created by Binay Budhthoki on 1/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class PopOverPresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance

    func loadData() {
        modelLayer.loadPopOverData() { source, data in
            self.data = data
            NotificationCenter.default.post(name: .loadPopOverDataForm, object: nil)
        }
    }
}

extension PopOverPresenter {
    func getCount() -> ENode {
        return state.getCount()
    }

    func saveData(data: [String: Any?], vc: PopOverViewController, delegate: BasePresenter) {
        modelLayer.savePopOverData(data: data, vc: vc) { status in
            if (status) {
                delegate.loadData()
                GUtils.message(msg: "Operation Complete")
            }
        }
    }

    func updateData(data: [String: Any?], delegate: BasePresenter) {
        modelLayer.updatePopOverData(data: data) { status in
            if (status) {
                delegate.loadData()
                GUtils.message(msg: "Operation Complete")
            }
        }
    }
}
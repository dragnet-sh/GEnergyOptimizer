//
// Created by Binay Budhthoki on 1/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class FeaturePresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = GEStateController.sharedInstance
}

extension FeaturePresenter {
    func loadData(vc: GEFormViewController) {
        modelLayer.loadPreAudit(vc: vc) { source, data in
            self.data = data
            NotificationCenter.default.post(name: .loadFeatureDataForm, object: nil)
        }
    }

    func saveData(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController,finished: @escaping (Bool)->Void) {
        modelLayer.savePreAudit(data: data, model: model, vc: vc) { status in
           finished(status)
        }
    }

    func getActiveZone() -> String {
        if let zone = state.getActiveZone() { return zone }
        else { return EZone.none.rawValue }
    }
}
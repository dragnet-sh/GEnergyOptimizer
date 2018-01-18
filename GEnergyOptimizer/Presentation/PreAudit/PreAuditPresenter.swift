//
// Created by Binay Budhthoki on 1/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class PreAuditPresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
}

extension PreAuditPresenter {
    func loadData() {
        modelLayer.loadPreAudit() { source, data in
            self.data = data
            NotificationCenter.default.post(name: .loadPreAuditForm, object: nil)
        }
    }

    func saveData(data: [String: Any?], model: GEnergyFormModel, finished: @escaping (Bool)->Void) {
        modelLayer.savePreAudit(data: data, model: model) { status in
           finished(status)
        }
    }
}
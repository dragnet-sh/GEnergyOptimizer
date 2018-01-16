//
// Created by Binay Budhthoki on 1/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class PreAuditPresenter {
    fileprivate var data = [String: [String]]()
    fileprivate var modelLayer = ModelLayer()
}

extension PreAuditPresenter {
    func loadData() {
        modelLayer.loadPreAudit() { source, data in
            self.data = data
        }
    }
}
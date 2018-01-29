//
// Created by Binay Budhthoki on 1/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

class FeaturePresenter {
    var data = Dictionary<String, Any?>()
    fileprivate var modelLayer = ModelLayer()
    fileprivate var state = StateController.sharedInstance

    func loadData(vc: GEFormViewController) {
        modelLayer.loadFeatureData(vc: vc) { source, data in
            self.data = data
            NotificationCenter.default.post(name: .loadFeatureDataForm, object: nil)
        }
    }
}

extension FeaturePresenter {

    func saveData(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController,finished: @escaping (Bool)->Void) {
        modelLayer.saveFeatureData(data: data, model: model, vc: vc) { status in
           finished(status)
        }
    }

    func getActiveZone() -> String {
        if let zone = state.getActiveZone() { return zone }
        else { return EZone.none.rawValue }
    }

    func bundleResource(entityType: EntityType?, applianceType: EApplianceType?) -> String {
        if let entityType = entityType {
            switch entityType {
            case .preaudit: return FileResource.preaudit.rawValue
            case .appliances: return EApplianceType.getFileName(type: applianceType!)
            case .zone: return getActiveZone().lowercased()
            default: Log.message(.error, message: "Entity Type : None"); return EntityType.none.rawValue
            }
        } else { Log.message(.error, message: "Entity Type : None"); return EntityType.none.rawValue }
    }
}
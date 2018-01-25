//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import Parse

typealias HomeDTOSourceBlock = (Source, [HomeListDTO])->Void
typealias ZoneDTOSourceBlock = (Source, [ZoneListDTO])->Void
typealias RoomDTOSourceBlock = (Source, [RoomListDTO])->Void
typealias FeatureDataSourceBlock = (Source, [String: Any?])->Void
typealias FeatureDataSaveBlock = (Bool)->Void

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = StateController.sharedInstance

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var pfRoomAPI = PFRoomAPI.sharedInstance
    fileprivate var pfZoneAPI = PFZoneAPI.sharedInstance
    fileprivate var pfPreAuditAPI = PFPreAuditAPI.sharedInstance

    var persistentContainer = DataLayer.sharedInstance.persistentContainer
    var managedContext = DataLayer.sharedInstance.persistentContainer.viewContext
}

extension ModelLayer {

    func initGEnergyOptimizer(identifier: String, initialized: @escaping ()->Void) {

        state.registerAuditIdentifier(auditIdentifier: identifier)

        func mainWork() {

            loadFromDB(from: .local)

            dataLayer.loadAuditNetwork(identifier: identifier) {
                self.dataLayer.sync() {
                    Log.message(.info, message: "Sync -- Callback")
                }
                loadFromDB(from: .network)
            }
        }

        func loadFromDB(from source: Source) {
            dataLayer.loadAuditLocal(identifier: identifier) {
                // Load Audit - Core Data : Call Back
            }
        }

        mainWork()
    }
}

//Mark: - Room Data Model
extension ModelLayer {
    func loadRoom(finished: @escaping RoomDTOSourceBlock) {
        Log.message(.info, message: "Loading Room Data Model")

        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                guard let results = audit.hasRoom?.sortedArray(using: [sortDescriptor]) as? [CDRoom] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Room")
                    return
                }

                let data = results.map { RoomListDTO(identifier: "N/A", title: $0.name!, guid: $0.guid!) }
                finished(.local, data)
            }
        }
    }

    func createRoom(name: String, finished: @escaping ()->Void) {
        coreDataAPI.createRoom(name: name) { result in
            switch result {
            case .Success(let data): self.pfRoomAPI.initialize(name: name) { status in }
            case .Error(let message): Log.message(.info, message: message)
            }
            finished()
        }
    }

    func deleteRoom(guid: String, finished: @escaping ()->Void) {
        coreDataAPI.deleteRoom(guid: guid) { status in
            finished()
        }
    }

    func updateRoom(guid: String, name: String, finished: @escaping ()->Void) {
        coreDataAPI.updateRoom(guid: guid, name: name) { status in
            finished()
        }
    }
}

//Mark: - Zone Data Model
extension ModelLayer {
    func loadZone(finished: @escaping ZoneDTOSourceBlock) {
        Log.message(.info, message: "Loading Zone Data Model")

        if let identifier = state.getIdentifier(), let zone = state.getActiveZone() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                guard let results = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Zone")
                    return
                }

                let data = results.filter { $0.type! == zone }.map {
                    ZoneListDTO(identifier: "N/A", title: $0.name!, type: $0.type!, cdZone: $0, guid: $0.guid!)
                }

                finished(.local, data)
            }
        }
    }

    func createZone(name: String, type: String, finished: @escaping ()->Void) {
        coreDataAPI.createZone(type: type, name: name) { result in
            switch result {
            case .Success(let data): self.pfZoneAPI.initialize(name: name, type: type) { status, pfZone in
                if (status) {
                    Log.message(.info, message: "Parse API : Initialize Zone - Registering Crosswalk")
                    self.state.registerCrosswalk(guid: data.guid!, pfZone: pfZone)
                }
            }
            finished()

            case .Error(let message): Log.message(.info, message: message)
            }
        }
    }

    func deleteZone(guid: String, finished: @escaping ()->Void) {
        coreDataAPI.deleteZone(guid: guid) { status in
            finished()
        }
    }

    func updateZone(guid: String, name: String, finished: @escaping ()->Void) {
        coreDataAPI.updateZone(guid: guid, name: name) { status in
            finished()
        }
    }
}


//Mark: - Home Data Model
extension ModelLayer {
    func loadHome(finished: @escaping HomeDTOSourceBlock) {
        Log.message(.info, message: "Loading Home Data Model")

        var data = [HomeListDTO]()

        let countHVAC = 5
        let countLighting = 7
        let countPlugLoad = 10

        data.append(contentsOf: [
            HomeListDTO(auditZone: "HVAC", count: countHVAC.description),
            HomeListDTO(auditZone: "Lighting", count: countLighting.description),
            HomeListDTO(auditZone: "PlugLoad", count: countPlugLoad.description)
        ])

        finished(.local, data)
    }
}


//Mark: - Form Data Model
extension ModelLayer {
    func loadFeatureData(vc: GEFormViewController, finished: @escaping FeatureDataSourceBlock) {
        Log.message(.info, message: "Loading Feature Data")

        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {

                switch vc.dataBelongsTo() {
                case .preaudit: {
                    guard let fetchResults = audit.hasPreAuditFeature?.allObjects as? [CDFeatureData] else {
                        Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                        return
                    }

                    finished(.local, mapToFormData(featureData: fetchResults))
                }()
                case .zone: {
                    if let cdZone = state.getActiveCDZone() {
                        guard let fetchResults = cdZone.hasFeature?.allObjects as? [CDFeatureData] else {
                            Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                            return
                        }

                        finished(.local, mapToFormData(featureData: fetchResults))
                    }
                }()
                default: Log.message(.error, message: "Unable to figure out Entity to Associate !!")
                }
            }
        }

        func mapToFormData(featureData: [CDFeatureData]) -> [String: Any?] {
            var data = featureData.reduce(into: [String: Any?]()) { (aggregate, data) in
                if let key = data.formId, let label = data.key, let type = data.type {
                    if let value = transform(type: type, data: data) {
                        aggregate[key] = value
                    }
                }
            }

            return data
        }

        func transform(type: String, data: CDFeatureData) -> Any? {
            if let eBaseType = InitEnumMapper.sharedInstance.enumMap[type] as? BaseRowType {
                switch eBaseType {
                case .intRow: return (data.value_int as NSNumber?)?.intValue
                case .decimalRow: return data.value_double
                default: return data.value_string
                }
            }
            return nil
        }
    }

    func saveFeatureData(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController, finished: @escaping FeatureDataSaveBlock) {

        coreDataAPI.saveFeatureData(data: data, model: model, vc: vc) { result in
            switch result {
            case .Success(let data): Log.message(.info, message: "Success Callback - Save Feature Data"); finished(true) //saveOnNetwork()
            case .Error(let message): Log.message(.error, message: message); finished(false)
            }
        }

        func saveOnNetwork() {
            switch vc.dataBelongsTo() {
            case .preaudit: {
                guard let pfAudit = self.state.getPFAudit() else {
                    Log.message(.error, message: "Guard Failed : PF Audit Object Unavailable")
                    finished(false)
                    return
                }

                pfPreAuditAPI.get(objectId: pfAudit.preAudit.objectId!) { status, object in
                    if (status) {
                        let idToElement = BuilderHelper.mapIdToElements(model: model)

                        guard let pfPreAudit = object as? PFPreAudit else {
                            Log.message(.error, message: "Guard Failed : PFPreAudit")
                            finished(false)
                            return
                        }

                        data.forEach { tuple in
                            if let value = tuple.value {
                                pfPreAudit.featureData[tuple.key] = [idToElement![tuple.key]?.param, value, idToElement![tuple.key]?.dataType]
                            }
                        }
                        self.pfPreAuditAPI.save(pfPreAudit: pfPreAudit) { status in
                            finished(status)
                        }
                    } else {
                        finished(false)
                    }
                }
            }()
            case .zone: {
                if let cdZone = self.state.getActiveCDZone() {
                    if let pfZone = self.state.getLinkedPFZone(guid: cdZone.guid!) {

                        let idToElement = BuilderHelper.mapIdToElements(model: model)

                        data.forEach { tuple in
                            if let value = tuple.value {
                                pfZone.featureData[tuple.key] = [idToElement![tuple.key]?.param, value, idToElement![tuple.key]?.dataType]
                            }
                        }
                        self.pfZoneAPI.save(pfZone: pfZone) { status in
                            finished(status)
                        }
                    } else {
                        finished(false)
                    }
                }

            }()
            default: Log.message(.error, message: "Unable to figure out Entity to save over Network !!")
            }
        }
    }
}

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
typealias PreAuditSourceBlock = (Source, [String: [String]])->Void
typealias PreAuditSaveBlock = (Bool)->Void

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = GEStateController.sharedInstance

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
        Log.message(.info, message: "Loadieg Room Data Model")

        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                guard let results = audit.hasRoom?.sortedArray(using: [sortDescriptor]) as? [CDRoom] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Room")
                    return
                }

                let data = results.map { RoomListDTO(identifier: "N/A", title: $0.name!) }
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

                let data = results.filter { $0.type == zone }.map {
                    ZoneListDTO(identifier: "N/A", title: $0.name!, type: $0.type!)
                }

                finished(.local, data)
            }
        }
    }

    func createZone(name: String, type: String, finished: @escaping ()->Void) {
        coreDataAPI.createZone(type: type, name: name) { result in
            switch result {
            case .Success(let data): self.pfZoneAPI.initialize(name: name, type: type) { status in }
            case .Error(let message): Log.message(.info, message: message)
            }
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
    func loadPreAudit(finished: @escaping PreAuditSourceBlock) {
        Log.message(.info, message: "Loading PreAudit Data")

        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {
                guard let fetchResults = audit.hasPreAuditFeature?.allObjects as? [CDPreAudit] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                    return
                }

                var data = fetchResults.reduce(into: [String: [String]]()) { (aggregate, data) in
                    if let key = data.formId, let label = data.key, let value = data.value {
                        aggregate[key] = [label, value]
                    }
                }

                finished(.local, data)
            }
        }
    }

    func savePreAudit(data: [String: Any?], model: GEnergyFormModel, finished: @escaping PreAuditSaveBlock) {
        guard let pfAudit = self.state.getPFAudit() else {
            Log.message(.error, message: "Guard Failed : PF Audit Object Unavailable")
            finished(false)
            return
        }

        pfPreAuditAPI.get(objectId: pfAudit.preAudit.objectId!) { status, object in
            if (status) {
                let idToElement = BuilderHelper.mapIdToElements(model: model)

                guard let object = object as? PFPreAudit else {
                    Log.message(.error, message: "Guard Failed : PFPreAudit")
                    finished(false)
                    return
                }

                data.forEach { tuple in
                    if let value = tuple.value {
                        object.featureData[tuple.key] = [idToElement![tuple.key]?.param, value]
                    }
                }
                self.pfPreAuditAPI.save(pfPreAudit: object) { status in
                    finished(status)
                }
            } else { finished(false) }
        }
    }
}

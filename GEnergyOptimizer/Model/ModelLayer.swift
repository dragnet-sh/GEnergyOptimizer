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

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = GEStateController.sharedInstance

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var pfRoomAPI = PFRoomAPI.sharedInstance
    fileprivate var pfZoneAPI = PFZoneAPI.sharedInstance

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

                guard let fetchedResults = audit.hasRoom?.sortedArray(using: [sortDescriptor]) as? [CDRoom] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Room")
                    return
                }

                let data = fetchedResults.map { RoomListDTO(identifier: "N/A", title: $0.name!) }
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

                guard let fetchedResults = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Zone")
                    return
                }

                let dataByZone = fetchedResults.filter { $0.type == zone }
                let data = dataByZone.map { ZoneListDTO(identifier: "N/A", title: $0.name!, type: $0.type!) }

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
    func loadHome(resultsLoaded: @escaping HomeDTOSourceBlock) {
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

        resultsLoaded(.local, data)
    }
}


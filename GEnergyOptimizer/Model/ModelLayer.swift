//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData

typealias HomeDTOSourceBlock = (Source, [HomeListDTO])->Void
typealias ZoneDTOSourceBlock = (Source, [ZoneListDTO])->Void
typealias RoomDTOSourceBlock = (Source, [RoomListDTO])->Void

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = GEStateController.sharedInstance

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
                Log.message(.info, message: "Loading Audit - Local")
            }
        }

        mainWork()
    }
}


//Mark: - Audit Data Model
extension ModelLayer {
    func getAudit(id: String) -> CDAudit? {
        Log.message(.info, message: "Core Data : Get Audit")
        let fetchRequest: NSFetchRequest<CDAudit> = CDAudit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [id])

        guard let audit = try! managedContext.fetch(fetchRequest).first as? CDAudit else {
            Log.message(.error, message: "Guard Failed : Core Data - Audit")
            return nil
        }

        return audit
    }
}


//Mark: - Room Data Model
extension ModelLayer {
    func loadRoom(finished: @escaping RoomDTOSourceBlock) {
        Log.message(.info, message: "Loading Room Data Model")

        if let identifier = state.getIdentifier() {
            if let audit = getAudit(id: identifier) {
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
        Log.message(.info, message: "Core Data : Create Room")

        if let identifier = state.getIdentifier() {
            guard let cdAudit = getAudit(id: identifier) else {
                Log.message(.error, message: "Guard Failed : CDAudit")
                return
            }

            let room = CDRoom(context: managedContext)
            room.name = name
            room.createdAt = NSDate()
            room.belongsToAudit = cdAudit

            do {
                try managedContext.save()
            } catch let error as NSError {
                Log.message(.error, message: error.userInfo.debugDescription)
            }

            finished()
        }
    }
}

//Mark: - Zone Data Model
extension ModelLayer {
    func loadZone(resultsLoaded: @escaping ZoneDTOSourceBlock) {
        Log.message(.info, message: "Loading Zone Data Model")

        var data = [ZoneListDTO]()
        data.append(contentsOf: [
            ZoneListDTO(identifier: "HVAC-1", title: "Zone Title 1", type: "HVAC"),
            ZoneListDTO(identifier: "HVAC-2", title: "Zone Title 2", type: "HVAC"),
            ZoneListDTO(identifier: "HVAC-3", title: "Zone Title 3", type: "HVAC"),
            ZoneListDTO(identifier: "HVAC-4", title: "Zone Title 4", type: "HVAC"),
            ZoneListDTO(identifier: "HVAC-5", title: "Zone Title 5", type: "HVAC"),
        ])

        resultsLoaded(.local, data)
    }

    func createZone(name: String, type: String, finished: @escaping ()->Void) {
        Log.message(.info, message: "Core Data : Create Zone")


        guard let cdAudit = state.getCDAudit() as? CDAudit else {
            Log.message(.error, message: "Guard Failed : CDAudit")
            return
        }

        let zone = CDZone(context: managedContext)
        zone.type = type
        zone.name = name
        zone.belongsToAudit = cdAudit

        do {
            try managedContext.save()
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
        }

        finished()
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


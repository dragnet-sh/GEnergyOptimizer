//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

typealias HomeDTOSourceBlock = (Source, [HomeListDTO])->Void
typealias ZoneDTOSourceBlock = (Source, [ZoneListDTO])->Void
typealias RoomDTOSourceBlock = (Source, [RoomListDTO])->Void

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = GEStateController.sharedInstance
}

extension ModelLayer {

    func initGEnergyOptimizer(identifier: String, initialized: @escaping ()->Void) {

        state.registerAuditIdentifier(auditIdentifier: identifier)

        func mainWork() {

            loadFromDB(from: .local)

            dataLayer.loadAuditNetwork(identifier: identifier) {
                self.state.sync() {
                    Log.message(.info, message: "Sync -- Callback")
                }
                loadFromDB(from: .network)
            }
        }

        func loadFromDB(from source: Source) {
            dataLayer.loadAuditLocal(identifier: identifier) {
                translationLayer.mapObjectModel()
            }
        }

        mainWork()
    }
}

//Mark: - Room Data Model
extension ModelLayer {
    func loadRoomData(resultsLoaded: @escaping RoomDTOSourceBlock) {
        Log.message(.info, message: "Loading Room Data Model")

        var data = [RoomListDTO]()
        data.append(contentsOf: [
            RoomListDTO(identifier: "room-1", title: "Room Title 1"),
            RoomListDTO(identifier: "room-2", title: "Room Title 2"),
            RoomListDTO(identifier: "room-3", title: "Room Title 3"),
            RoomListDTO(identifier: "room-4", title: "Room Title 4"),
            RoomListDTO(identifier: "room-5", title: "Room Title 5")
        ])

        resultsLoaded(.local, data)
    }
}

//Mark: - Zone Data Model
extension ModelLayer {
    func loadZoneData(resultsLoaded: @escaping ZoneDTOSourceBlock) {
        Log.message(.info, message: "Loading Zone Data Model")

        var data = [ZoneListDTO]()
        data.append(contentsOf: [
            ZoneListDTO(identifier: "HVAC-1", title: "Zone Title 1"),
            ZoneListDTO(identifier: "HVAC-2", title: "Zone Title 2"),
            ZoneListDTO(identifier: "HVAC-3", title: "Zone Title 3"),
            ZoneListDTO(identifier: "HVAC-4", title: "Zone Title 4"),
            ZoneListDTO(identifier: "HVAC-5", title: "Zone Title 5"),
        ])

        resultsLoaded(.local, data)
    }
}


//Mark: - Home Data Model
extension ModelLayer {
    func loadHomeData(resultsLoaded: @escaping HomeDTOSourceBlock) {
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


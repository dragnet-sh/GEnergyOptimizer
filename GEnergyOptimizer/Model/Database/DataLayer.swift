//
//  DataLayer.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 1/10/18.
//  Copyright © 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData

typealias AuditServerBlock = (Result<PFAudit?>) -> Void
typealias AuditCoreDataBlock = (Result<CDAudit?>) -> Void
typealias InitCompleteBlock = (Source) -> Void

class DataLayer {

    class var sharedInstance: DataLayer {
        struct Singleton {
            static let instance = DataLayer()
        }
        return Singleton.instance
    }

    let state = GEStateController.sharedInstance
    let pfAuditAPI = PFAuditAPI.sharedInstance
    let pfPreAuditAPI = PFPreAuditAPI.sharedInstance
    let pfZoneAPI = PFZoneAPI.sharedInstance
    let pfRoomAPI = PFRoomAPI.sharedInstance

    let coreDataAPI = CoreDataAPI.sharedInstance
    let persistentContainer = CoreDataAPI.sharedInstance.persistentContainer

    public func sync(complete: @escaping ()->Void) {
        Log.message(.info, message: "Data Sync - In Progress")

        guard let auditIdentifier = self.state.getIdentifier() else {
            Log.message(.error, message: "Audit Identifier is Nil")
            return
        }

        guard let pfAudit = self.state.getPFAudit() else  {
            Log.message(.error, message: "PFAudit in Nil")
            return
        }

        let managedContext = persistentContainer.viewContext
        if let copy = coreDataAPI.getAudit(id: auditIdentifier) {
            Log.message(.info, message: "Deleting Older Copy - Core Data - Audit")
            managedContext.delete(copy)
        }

        // 1. Sync Audit
        let audit = CDAudit(context: managedContext)
        audit.identifier = auditIdentifier
        audit.name = pfAudit.name

        try! managedContext.save()

        // 2. Sync PreAudit
        if let preAuditId = pfAudit.preAudit.objectId {
            pfPreAuditAPI.get(objectId: preAuditId) { status, object in
                guard let object = object as? PFPreAudit else {
                    Log.message(.error, message: "Guard Failed : Parse PreAudit")
                    return
                }

                for (elementId, data) in object.featureData {
                    let formId = elementId
                    let formTitle = data[0] as? String
                    let formValue = data[1] as? String

                    let data = CDPreAudit(context: managedContext)
                    data.belongsToAudit = audit
                    data.formId = formId
                    data.key = formTitle
                    data.value = formValue
                }

                try! managedContext.save()
            }
        }

        try! managedContext.save()

        // 3. Sync Zone
        let zoneType = EZone.getAll
        zoneType.forEach { zone in
            let rawValue = zone.rawValue
            guard let objects = pfAudit.zoneCollection[rawValue] as? [PFZone] else {
                return
            }

            objects.forEach { zone in

                guard let id = zone.objectId else {
                    Log.message(.error, message: "Guard Fail")
                    return
                }

                pfZoneAPI.get(objectId: id) { status, object in
                    let dataZone = CDZone(context: managedContext)
                    dataZone.belongsToAudit = audit
                    dataZone.name = zone.name
                    dataZone.type = zone.type

                    for (elementId, data) in zone.featureData {
                        let formId = elementId
                        let formTitle = data[0] as? String
                        let formValue = data[1] as? String

                        let dataFeature = CDZoneFeature(context: managedContext)
                        dataFeature.belongsToZone = dataZone
                        dataFeature.form_id = formId
                        dataFeature.key = formTitle
                        dataFeature.value = formValue
                    }

                    try! managedContext.save()
                }
            }
        }

        // 4. Sync Room
        guard let objects = pfAudit.roomCollection as? [PFRoom] else {
            return
        }

        objects.forEach { room in

            guard let id = room.objectId else {
                Log.message(.error, message: "Guard Fail")
                return
            }

            pfRoomAPI.get(objectId: id) { status, object in
                let dataRoom = CDRoom(context: managedContext)
                dataRoom.belongsToAudit = audit
                dataRoom.name = room.name
                dataRoom.objectId = room.objectId

                try! managedContext.save()
            }
        }

        complete()
    }

    func loadAuditLocal(identifier: String, finished: () -> Void) {
        Log.message(.info, message: "Loading Audit Local - Core Data")
        GUtils.applicationDocumentsDirectory()
        if let audit = self.coreDataAPI.getAudit(id: identifier) {
            state.registerCDAudit(cdAudit: audit)
        }
    }

    func loadAuditNetwork(identifier: String, finished: @escaping () -> Void) {
        Log.message(.info, message: "Loading Audit Via Network - Parse Server")

        func fetchAudit(complete: @escaping ()->Void) {
            self.pfAuditAPI.get(id: identifier) { status, object in
                guard let object = object as? PFAudit else {
                    Log.message(.error, message: "Guard Failed - PFAudit")
                    self.pfAuditAPI.initialize(identifier: identifier) { status, object in
                        guard let object = object as? PFAudit else {
                            Log.message(.error, message: "Guard Failed")
                            return
                        }
                        self.state.registerPFAudit(pfAudit: object)
                        complete()
                    }
                    return
                }
                self.state.registerPFAudit(pfAudit: object)
                complete()
            }
        }

        fetchAudit() {
            finished()
        }
    }
}

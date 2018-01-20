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

    let state = StateController.sharedInstance
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
        //ToDo: Alternative to not wipe out the complete data state - Incremental Sync
        //ToDo: What if there were some residual data that was not being synced earlier due to Network Failure
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

                var featureDataToSave = [CDFeatureData]()
                for (elementId, data) in object.featureData {
                    let formId = elementId
                    let formTitle = String(describing: data[0])
                    let formValue = data[1]
                    let formDataType = data[2] as! String

                    let preAudit = CDFeatureData(context: managedContext)
                    preAudit.belongsToAudit = audit
                    preAudit.formId = formId
                    preAudit.key = formTitle
                    preAudit.dataType = formDataType

                    if let eBaseType = InitEnumMapper.sharedInstance.enumMap[formDataType] as? BaseRowType {
                        switch eBaseType {
                        case .intRow: preAudit.value_int = (formValue as! NSNumber).int64Value
                        case .decimalRow: preAudit.value_double = formValue as! Double
                        default: preAudit.value_string = String(describing: formValue)
                        }
                    }

                    featureDataToSave.append(preAudit)
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

            pfZoneAPI.getAll(objects: objects) { status, objects in
                if (status) {
                    guard let pfZones = objects as? [PFZone] else {
                        Log.message(.error, message: "Guard Fails - Bulk Fetch PFZones")
                        return
                    }

                    var zoneToSave = [CDZone]()
                    var featureDataToSave = [CDFeatureData]()

                    for pfZone in pfZones {
                        let cdZone = CDZone(context: managedContext)
                        cdZone.belongsToAudit = audit
                        cdZone.name = pfZone.name
                        cdZone.type = pfZone.type
                        cdZone.objectId = pfZone.objectId

                        let uuid = UUID().uuidString
                        cdZone.uuid = uuid
                        self.state.registerCrosswalk(uuid: uuid, pfZone: pfZone)

                        zoneToSave.append(cdZone)

                        for(elementId, data) in pfZone.featureData {
                            let formId = elementId
                            let formTitle = String(describing: data[0])
                            let formValue = data[1]
                            let formDataType = data[2] as! String

                            let zone = CDFeatureData(context: managedContext)
                            zone.belongsToZone = cdZone
                            zone.formId = formId
                            zone.key = formTitle
                            zone.dataType = formDataType

                            if let eBaseType = InitEnumMapper.sharedInstance.enumMap[formDataType] as? BaseRowType {
                                switch eBaseType {
                                case .intRow: zone.value_int = (formValue as! NSNumber).int64Value
                                case .decimalRow: zone.value_double = formValue as! Double
                                default: zone.value_string = String(describing: formValue)
                                }
                            }

                            featureDataToSave.append(zone)
                        }
                    }

                    try! managedContext.save()
                }
            }
        }

        // 4. Sync Room
        guard let rooms = pfAudit.roomCollection as? [PFRoom] else {
            return
        }

        pfRoomAPI.getAll(objects: rooms) { status, objects in
            guard let pfRooms = objects as? [PFRoom] else {
                Log.message(.error, message: "Guard Failed - Bulk PFRoom")
                return
            }

            _ = pfRooms.map {
                let room = CDRoom(context: managedContext)
                room.belongsToAudit = audit
                room.name = $0.name
                room.objectId = $0.objectId
            }

            try! managedContext.save()
        }

        complete()
    }

    func loadAuditLocal(identifier: String, finished: () -> Void) {
        Log.message(.info, message: "Loading Audit Local - Core Data")
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

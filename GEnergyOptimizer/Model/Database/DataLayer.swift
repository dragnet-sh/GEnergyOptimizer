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

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GEModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func loadCoreData(identifier: String) {

        Log.message(.info, message: "Core Data : Initializing Audit")
        let managedContext = persistentContainer.viewContext

        guard let auditEntity = NSEntityDescription.entity(forEntityName: "CDAudit", in: managedContext) else {
            Log.message(.error, message: "Guard failed for NSEntityDescription")
            return
        }
        guard let zoneEntity = NSEntityDescription.entity(forEntityName: "CDZone", in: managedContext) else {
            return
        }

        // ### AUDIT
        Log.message(.info, message: "Creating CDAudit")
        let audit = CDAudit(context: managedContext)
        audit.identifier = identifier
        audit.name = "GEnergy Audit \(identifier)"

        // ### Saving the CDAudit Context
        try! managedContext.save()

        // ### ZONE
        Log.message(.info, message: "Creating CDZone - 1")
        let zone1 = CDZone(context: managedContext)
        zone1.name = "Zone One"
        zone1.type = "HVAC"
        zone1.belongsToAudit = audit

        Log.message(.info, message: "Creating CDZone - 2")
        let zone2 = CDZone(context: managedContext)
        zone2.name = "Zone Two"
        zone2.type = "PlugLoad"
        zone2.belongsToAudit = audit

        // ### Saving the CDZone Context
        do {
            try managedContext.save()
        } catch let error as NSError {
            Log.message(.error, message: "Could Not Save \(error.userInfo)")
        }

    }

    func loadAuditLocal(identifier: String, finished: () -> Void) {

        GUtils.applicationDocumentsDirectory()

        let fetchRequest: NSFetchRequest<CDAudit> = CDAudit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
        Log.message(.info, message: fetchRequest.debugDescription)
        do {
            let audit = try persistentContainer.viewContext.fetch(fetchRequest)

            guard let record = audit.first as? CDAudit else {
                Log.message(.error, message: "Guard failed for CDAudit")
                return
            }

            state.registerCDAudit(cdAudit: record)

            if let zones = record.hasZone {
                for eachZone in zones {
                    guard let zone = eachZone as? CDZone else {
                        Log.message(.error, message: "Guard failed for Zone")
                        return
                    }

                    if let name = zone.name, let type = zone.type {
                        Log.message(.info, message: name)
                        Log.message(.info, message: type)
                    }
                }
            }

        } catch let error as NSError {
            Log.message(.error, message: "Audit Fetch Error \(error.userInfo)")
            finished()
        }
    }

    func loadAuditNetwork(identifier: String, finished: @escaping () -> Void) {
        Log.message(.info, message: "PFAudit - Loading form Server : Audit Identifier - \(identifier)")


        pfAuditAPI.get(id: identifier) { status, object in
            guard let object = object as? PFAudit else {
                Log.message(.error, message: "Guard Failed - PFAudit")
                self.pfAuditAPI.initialize(identifier: identifier)
                return
            }

            self.state.registerPFAudit(pfAudit: object)
        }

    }
}

//
// Created by Binay Budhthoki on 1/16/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData

class CoreDataAPI {
    class var sharedInstance: CoreDataAPI {
        struct Singleton {
            static let instance = CoreDataAPI()
        }
        return Singleton.instance
    }

    let state = GEStateController.sharedInstance

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GEModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var managedContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

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

    func createZone(type: String, name: String, finished: @escaping ()->Void) {
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
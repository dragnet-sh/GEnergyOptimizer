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

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GEModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getAudit(id: String) -> CDAudit? {
        Log.message(.info, message: "Core Data : Get Audit")
        let fetchRequest: NSFetchRequest<CDAudit> = CDAudit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [id])

        let managedContext = persistentContainer.viewContext
        guard let audit = try! managedContext.fetch(fetchRequest).first as? CDAudit else {
            Log.message(.error, message: "Guard Failed : Core Data - Audit")
            return nil
        }

        return audit
    }
}
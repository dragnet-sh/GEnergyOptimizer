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

    func createRoom(name: String, finished: @escaping (Result<CDRoom>)->Void) {
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
                finished(.Success(room))
            } catch let error as NSError {
                Log.message(.error, message: error.userInfo.debugDescription)
                finished(.Error(error.userInfo.debugDescription))
            }
        }
    }

    func createZone(type: String, name: String, finished: @escaping (Result<CDZone>)->Void) {
        Log.message(.info, message: "Core Data : Create Zone")
        guard let cdAudit = state.getCDAudit() as? CDAudit else {
            Log.message(.error, message: "Guard Failed : CDAudit")
            return
        }

        let zone = CDZone(context: managedContext)
        zone.type = type
        zone.name = name
        zone.createdAt = NSDate()
        zone.belongsToAudit = cdAudit

        do {
            try managedContext.save()
            finished(.Success(zone))
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(.Error(error.userInfo.debugDescription))
        }
    }

    func getPreAudit(finished: @escaping (Result<[CDPreAudit]>)->Void) {
        if let identifier = state.getIdentifier() {
            if let audit = getAudit(id: identifier) {
                guard let preAudit = audit.hasPreAuditFeature?.allObjects as? [CDPreAudit] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                    finished(.Error("Unable to Fetch PreAudit"))
                    return
                }
                finished(.Success(preAudit))
            }
        }
    }

    func savePreAudit(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController, finished: @escaping (Result<[CDPreAudit]>)->Void) {
        let preAudit = getPreAudit { result in
            switch result {
                case .Success(let data): data.forEach { cdPreAudit in self.managedContext.delete(cdPreAudit) }
                case .Error(let message): return
            }
        }

        guard let idToElement = BuilderHelper.mapIdToElements(model: model) else {
            Log.message(.error, message: "Guard Failed : GElements")
            return
        }

        if let audit = state.getCDAudit() {

            var preAudit = [CDPreAudit]()

            do {
                data.forEach { tuple in

                    let formId = tuple.key
                    if let value = tuple.value {
                        if let dataType = idToElement[formId]?.dataType, let label = idToElement[formId]?.param {

                            let pa = CDPreAudit(context: self.managedContext)
                            pa.formId = formId
                            pa.dataType = dataType
                            pa.key = label

                            switch vc.dataBelongsTo() {
                            case .preaudit: pa.belongsToAudit = audit
                            case .zone: {
                                if let activeCDZone = self.state.getActiveCDZone() {
                                    pa.belongsToZone = activeCDZone
                                } else {
                                    finished(.Error("Active Core Data Zone is NIL - Core Data Save Failed !!"))
                                }
                            }()
                            default: finished(.Error("Unable to figure out Entity to Associate !!"))
                            }

                            if let eBaseType = InitEnumMapper.sharedInstance.enumMap[dataType] as? BaseRowType {
                                switch eBaseType {
                                case .intRow: pa.value_int = (value as! NSNumber).int64Value
                                case .decimalRow: pa.value_double = value as! Double
                                default: pa.value_string = value as! String
                                }
                            }

                            preAudit.append(pa)
                        }
                    }
                }

                try managedContext.save()
                finished(.Success(preAudit))
            } catch let error as NSError {
                Log.message(.error, message: error.userInfo.debugDescription)
                finished(.Error(error.userInfo.debugDescription))
            }
        }
    }
}
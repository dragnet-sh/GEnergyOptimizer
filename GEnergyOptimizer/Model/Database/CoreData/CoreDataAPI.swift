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

    let state = StateController.sharedInstance

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
}

//Mark: - Audit

extension CoreDataAPI {

    // *** Audit : GET *** //

    func getAudit(id: String) -> CDAudit? {
        Log.message(.info, message: "Core Data : Get Audit")
        let fetchRequest: NSFetchRequest<CDAudit> = CDAudit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", argumentArray: [id])

        guard let audit = try! managedContext.fetch(fetchRequest).first as? CDAudit else {
            Log.message(.error, message: "Guard Failed : Core Data - Audit")

            // Let's initialize the Audit // ToDo: Change this later !! IMP

            let audit = CDAudit(context: managedContext)
            audit.identifier = id
            audit.name = "Test - \(id.description)"

            try! managedContext.save()

            state.registerCDAudit(cdAudit: audit)

            return nil
        }

        return audit
    }
}


//Mark: - Room

extension CoreDataAPI {

    // *** POST *** //

    func createRoom(name: String, finished: @escaping (Result<CDRoom>) -> Void) {
        Log.message(.info, message: "Core Data : Create Room")
        if let identifier = state.getIdentifier() {
            guard let cdAudit = getAudit(id: identifier) else {
                Log.message(.error, message: "Guard Failed : Core Data - Create Room")
                return
            }

            let room = CDRoom(context: managedContext)
            room.name = name
            room.createdAt = NSDate()
            room.guid = UUID().uuidString
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

    // *** DELETE *** //

    func deleteRoom(guid: String, finished: @escaping (Bool) -> Void) {
        Log.message(.info, message: "Core Data : Delete Room")
        let fetchRequest: NSFetchRequest<CDRoom> = CDRoom.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [guid])

        do {
            guard let room = try managedContext.fetch(fetchRequest).first as? CDRoom else {
                Log.message(.error, message: "Guard Failed : Core Data - Get Room")
                finished(false)
                return
            }

            try managedContext.delete(room)
            finished(true)
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(false)
        }
    }

    // *** UPDATE *** //

    func updateRoom(guid: String, name: String, finished: @escaping (Bool) -> Void) {
        Log.message(.info, message: "Core Data : Update Room")
        let fetchRequest: NSFetchRequest<CDRoom> = CDRoom.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [guid])

        do {
            guard let room = try managedContext.fetch(fetchRequest).first as? CDRoom else {
                Log.message(.error, message: "Guard Failed : Core Data - Get Room")
                finished(false)
                return
            }

            room.name = name
            room.updatedAt = NSDate()

            try managedContext.save()
            finished(true)
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(false)
        }
    }
}

//Mark: - Zone

extension CoreDataAPI {


    // *** GET *** //

    func getZone(id: String, finished: @escaping (Result<CDZone>) -> Void) {
        Log.message(.info, message: "Core Data : Get Zone")
        let fetchRequest: NSFetchRequest<CDZone> = CDZone.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [id])

        guard let zone = try! managedContext.fetch(fetchRequest).first as? CDZone else {
            Log.message(.error, message: "Guard Failed : CDZone")
            return
        }

        finished(.Success(zone))
    }

    func getChild(parent: CDZone, finished: @escaping ([CDZone]) -> Void) {
        Log.message(.info, message: "Core Data : Zone - Get Children")

        let fetchRequest: NSFetchRequest<CDZone> = CDZone.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parent = %@", argumentArray: [parent])

        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [CDZone] else {
                Log.message(.error, message: "Guard Failed : Child CDZone")
                return
            }
            finished(result)
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.description)
        }
    }

    // *** POST *** //

    func createZone(type: String, name: String, parent: CDZone? = nil, finished: @escaping (Result<CDZone>) -> Void) {
        Log.message(.info, message: "Core Data : Create Zone")
        guard let cdAudit = state.getCDAudit() as? CDAudit else {
            Log.message(.error, message: "Guard Failed : CDAudit")
            return
        }

        if (type.isEmpty || name.isEmpty) {
            Log.message(.error, message: "Type or Name is Empty")
            return
        }

        let zone = CDZone(context: managedContext)
        zone.type = type
        zone.name = name
        zone.createdAt = NSDate()
        zone.belongsToAudit = cdAudit
        zone.guid = UUID().uuidString

        if let parent = parent {
            zone.parent = parent
        }

        do {
            try managedContext.save()
            finished(.Success(zone))
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(.Error(error.userInfo.debugDescription))
        }
    }

    // *** DELETE *** //

    func deleteZone(guid: String, finished: @escaping (Bool) -> Void) {
        Log.message(.info, message: "Core Data : Delete Zone")
        let fetchRequest: NSFetchRequest<CDZone> = CDZone.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [guid])

        do {
            guard let zone = try managedContext.fetch(fetchRequest).first as? CDZone else {
                Log.message(.error, message: "Guard Failed : Core Data - Get Zone")
                finished(false)
                return
            }

            try managedContext.delete(zone)
            finished(true)
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(false)
        }
    }

    // *** UPDATE *** //

    func updateZone(guid: String, name: String, type: String, finished: @escaping (Bool) -> Void) {
        Log.message(.info, message: "Core Data : Update Zone")
        let fetchRequest: NSFetchRequest<CDZone> = CDZone.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", argumentArray: [guid])

        do {
            guard let zone = try managedContext.fetch(fetchRequest).first as? CDZone else {
                Log.message(.error, message: "Guard Failed : Core Data - Get Zone")
                finished(false)
                return
            }

            zone.name = name
            zone.type = type
            zone.updatedAt = NSDate()

            try managedContext.save()
            finished(true)
        } catch let error as NSError {
            Log.message(.error, message: error.userInfo.debugDescription)
            finished(false)
        }
    }
}

//Mark: - Feature Data

extension CoreDataAPI {

    // *** Feature Data : GET *** //

    func getFeatureData(type: EntityType, finished: @escaping (Result<[CDFeatureData]>)->Void) {
        Log.message(.info, message: "Core Data : Fetch Feature Data")
        switch type {
        case .preaudit: {
            Log.message(.info, message: "Core Data : PreAudit - Feature Data")
            if let identifier = self.state.getIdentifier() {
                if let audit = getAudit(id: identifier) {
                    guard let preAudit = audit.hasPreAuditFeature?.allObjects as? [CDFeatureData] else {
                        Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                        finished(.Error("Unable to Fetch PreAudit"))
                        return
                    }
                    finished(.Success(preAudit))
                }
            }
        }()
        case .zone: {
            Log.message(.info, message: "Core Data : Zone - Feature Data")
            if let activeZone = self.state.getActiveCDZone() {
                guard let zone = activeZone.hasFeature?.allObjects as? [CDFeatureData] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data - ZONE")
                    finished(.Error("Unable to Fetch PreAudit - Zone"))
                    return
                }
                finished(.Success(zone))
            }
        }()
        case .appliances: {
            Log.message(.info, message: "Core Data : Zone - Appliances - Feature Data")
            if let activeZone = self.state.getActiveCDZone() {
                guard let zone = activeZone.hasFeature?.allObjects as? [CDFeatureData] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data - ZONE")
                    finished(.Error("Unable to Fetch PreAudit - Zone"))
                    return
                }
                finished(.Success(zone))
            }
        }()
        default: Log.message(.error, message: "Unknown Entity Type")
        }
    }

    // *** Feature Data : POST *** //

    func saveFeatureData(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController, finished: @escaping (Result<[CDFeatureData]>)->Void) {
        Log.message(.info, message: "Core Data : Save Feature Data")
        let preAudit = self.getFeatureData(type: vc.dataBelongsTo()) { result in
            switch result {
                //Note: Deleting the previous set of Feature Data and saving the fresh one from the Form
                case .Success(let data): data.forEach { cdPreAudit in self.managedContext.delete(cdPreAudit) }
                case .Error(let message): Log.message(.error, message: "Core Data : Unable to Get Feature Data"); return
            }
        }

        guard let idToElement = BuilderHelper.mapIdToElements(model: model) else {
            Log.message(.error, message: "Guard Failed : GElements")
            return
        }

        if let audit = self.state.getCDAudit() {

            var preAudit = [CDFeatureData]()

            do {
                data.forEach { tuple in

                    let formId = tuple.key
                    if let value = tuple.value {
                        if let dataType = idToElement[formId]?.dataType, let label = idToElement[formId]?.param {

                            let pa = CDFeatureData(context: self.managedContext)
                            pa.formId = formId
                            pa.type = dataType
                            pa.key = label
                            pa.createdAt = NSDate()
                            pa.updatedAt = NSDate()
                            pa.sync = false
                            //ToDo - Code Review !!
                            switch vc.dataBelongsTo() {
                            case .preaudit: pa.belongsToAudit = audit
                            case .zone: {
                                if let activeCDZone = self.state.getActiveCDZone() {
                                    pa.belongsToZone = activeCDZone
                                } else {
                                    finished(.Error("Active Core Data Zone is NIL - Core Data Save Failed !!"))
                                }
                            }()
                            case .appliances: {
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

                try self.managedContext.save()
                finished(.Success(preAudit))
            } catch let error as NSError {
                Log.message(.error, message: error.userInfo.debugDescription)
                finished(.Error(error.userInfo.debugDescription))
            }
        }
    }
}

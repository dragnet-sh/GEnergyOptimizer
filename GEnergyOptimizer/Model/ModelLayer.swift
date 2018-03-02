//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import CoreData
import Parse

typealias HomeDTOSourceBlock = (Source, [HomeDTO])->Void
typealias ZoneDTOSourceBlock = (Source, [ZoneDTO])->Void
typealias RoomDTOSourceBlock = (Source, [RoomDTO])->Void
typealias FeatureDataSourceBlock = (Source, [String: Any?])->Void
typealias FeatureDataSaveBlock = (Bool)->Void
typealias PopOverDataSourceBlock = (Source, [String: Any?])->Void
typealias PopOverDataSaveBlock = (Bool)->Void
typealias PopOverDataUpdateBlock = (Bool)->Void

class ModelLayer {

    fileprivate var dataLayer = DataLayer.sharedInstance
    fileprivate var translationLayer = TranslationLayer.sharedInstance
    fileprivate var state = StateController.sharedInstance

    fileprivate var coreDataAPI = CoreDataAPI.sharedInstance
    fileprivate var pfRoomAPI = PFRoomAPI.sharedInstance
    fileprivate var pfZoneAPI = PFZoneAPI.sharedInstance
    fileprivate var pfPreAuditAPI = PFPreAuditAPI.sharedInstance

    var persistentContainer = DataLayer.sharedInstance.persistentContainer
    var managedContext = DataLayer.sharedInstance.persistentContainer.viewContext
}

extension ModelLayer {

    func initGEnergyOptimizer(identifier: String, initialized: @escaping ()->Void) {

        state.registerAuditIdentifier(auditIdentifier: identifier)

        func mainWork() {

            loadFromDB(from: .local)

//            dataLayer.loadAuditNetwork(identifier: identifier) {
//                self.dataLayer.sync() {
//                    Log.message(.info, message: "Sync -- Callback")
//                }
//                loadFromDB(from: .network)
//            }
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

                guard let results = audit.hasRoom?.sortedArray(using: [sortDescriptor]) as? [CDRoom] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Room")
                    return
                }

                let data = results.map { RoomDTO(identifier: "N/A", title: $0.name!, guid: $0.guid!, cdRoom: $0) }
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

    func deleteRoom(guid: String, finished: @escaping ()->Void) {
        coreDataAPI.deleteRoom(guid: guid) { status in
            finished()
        }
    }

    func updateRoom(guid: String, name: String, finished: @escaping ()->Void) {
        coreDataAPI.updateRoom(guid: guid, name: name) { status in
            finished()
        }
    }
}

//Mark: - Zone Data Model
extension ModelLayer {
    func loadZone(finished: @escaping ZoneDTOSourceBlock) {

        func mainLoader() {
            Log.message(.info, message: "Loading Zone Data Model")

            switch state.getActiveZone()! {
            case EZone.plugload.rawValue:
                switch state.getCount() {
                case .parent: loadParent()
                case .child: loadChild()
                }

            case EZone.lighting.rawValue: loadParent()
            case EZone.motors.rawValue: loadParent()

            default: Log.message(.info, message: "MUST BE - HVAC")
            }
        }

        func loadChild() {
            let parent = state.counterZLV[ENode.parent.rawValue] as? ZoneDTO
            let fetchRequest: NSFetchRequest<CDZone> = CDZone.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "parent = %@", argumentArray: [parent?.cdZone])

            let result = try! managedContext.fetch(fetchRequest)

            let data = result.map {
                ZoneDTO(identifier: "N/A", title: $0.name!,
                        type: $0.type!, cdZone: $0, guid: $0.guid!)
            }

            finished(.local, data)
        }

        func loadParent() {

            if let identifier = state.getIdentifier(), let zone = state.getActiveZone() {
                if let audit = coreDataAPI.getAudit(id: identifier) {
                    let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                    guard let results = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] else {
                        Log.message(.error, message: "Guard Failed : Fetched Results - Core Data Zone")
                        return
                    }

                    let data = results.filter {
                        $0.type! == zone
                    }.map {
                        ZoneDTO(identifier: "N/A", title: $0.name!,
                                type: $0.type!, cdZone: $0, guid: $0.guid!)
                    }

                    finished(.local, data)
                }
            }
        }

        mainLoader()
    }

//    func createZone(name: String, type: String, finished: @escaping ()->Void) {
//        coreDataAPI.createZone(type: type, name: name) { result in
//            switch result {
//            case .Success(let data): self.pfZoneAPI.initialize(name: name, type: type) { status, pfZone in
//                if (status) {
//                    Log.message(.info, message: "Parse API : Initialize Zone - Registering Crosswalk")
//                    self.state.registerCrosswalk(guid: data.guid!, pfZone: pfZone)
//                }
//            }
//            finished()
//
//            case .Error(let message): Log.message(.info, message: message)
//            }
//        }
//    }

    func deleteZone(guid: String, finished: @escaping () -> Void) {
        func mainLoader() {
            Log.message(.info, message: "Data Model : Deleting Zone")

            switch state.getCount() {
            case .parent: deleteParent()
            case .child: deleteChild()
            }
        }

        func deleteParent() {
            Log.message(.info, message: "Deleting - Parent")
            coreDataAPI.getZone(id: guid) { result in
                switch result {
                case .Success(let data):
                    self.coreDataAPI.getChild(parent: data) { result in
                        for item in result {
                            if let guid = item.guid {
                                self.coreDataAPI.deleteZone(guid: guid) { status in

                                }
                            }
                        }
                        deleteChild()
                    }
                case .Error(let msg): Log.message(.error, message: msg.debugDescription)
                }
            }
        }

        func deleteChild() {
            Log.message(.info, message: "Deleting - Child")
            coreDataAPI.deleteZone(guid: guid) { status in
                finished()
            }
        }

        mainLoader()
    }

    func updateZone(data: [String: Any?], finished: @escaping (Bool)->Void) {
        if let zone = state.getActiveCDZone() {
            guard let id = zone.guid, let _name = data[ETagPO.name.rawValue]! else {
                Log.message(.error, message: "Guard Failed : Zone GUID or Zone Name")
                return
            }

            let name = String(describing: _name)
            var type: String = ""

            switch state.getActiveZone()! {
            case EZone.plugload.rawValue:
                switch state.getCount() {
                case .parent: type = EZone.plugload.rawValue
                case .child:
                    guard let _type = data[ETagPO.type.rawValue]! else {
                        Log.message(.error, message: "Guard Failed: Extracting Type form Form Data")
                        return
                    }
                    type = String(describing: _type)
                }

            case EZone.lighting.rawValue: type = EZone.lighting.rawValue
            case EZone.hvac.rawValue: type = EZone.hvac.rawValue
            case EZone.motors.rawValue: type = EZone.motors.rawValue
            default: {}()
            }

            coreDataAPI.updateZone(guid: id, name: name, type: type) { result in
                finished(result)
            }
        }
    }
}


//Mark: - Home Data Model
extension ModelLayer {
    func loadHome(finished: @escaping HomeDTOSourceBlock) {
        Log.message(.info, message: "Loading Home Data Model")

        var data = [HomeDTO]()
        if let id = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: id) {
                guard let zones = audit.hasZone?.allObjects as? [CDZone] else {
                    Log.message(.error, message: "Guard Failed : Fetched Results - Audit Zones")
                    return
                }

                let countHVAC = zones.filter { $0.type! == EZone.hvac.rawValue }.count
                let countLighting = zones.filter { $0.type! == EZone.lighting.rawValue }.count
                let countPlugLoad = zones.filter { $0.type! == EZone.plugload.rawValue }.count
                let countMotors = zones.filter { $0.type! == EZone.motors.rawValue }.count

                data.append(contentsOf: [
//                    HomeListDTO(auditZone: EZone.hvac.rawValue, count: countHVAC.description),
                    HomeDTO(auditZone: EZone.lighting.rawValue, count: countLighting.description),
                    HomeDTO(auditZone: EZone.plugload.rawValue, count: countPlugLoad.description),
                    HomeDTO(auditZone: EZone.motors.rawValue, count: countMotors.description)
                ])

                finished(.local, data)
            }
        }
    }
}


//Mark: - Form Data Model
extension ModelLayer {
    func loadFeatureData(vc: GEFormViewController, finished: @escaping FeatureDataSourceBlock) {
        Log.message(.info, message: "Loading Feature Data")

        if let identifier = state.getIdentifier() {
            if let audit = coreDataAPI.getAudit(id: identifier) {

                switch vc.dataBelongsTo() {
                case .preaudit: {
                    guard let fetchResults = audit.hasPreAuditFeature?.allObjects as? [CDFeatureData] else {
                        Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                        return
                    }

                    finished(.local, mapToFormData(featureData: fetchResults))
                }()
                case .zone: {
                    if let cdZone = state.getActiveCDZone() {
                        guard let fetchResults = cdZone.hasFeature?.allObjects as? [CDFeatureData] else {
                            Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                            return
                        }

                        finished(.local, mapToFormData(featureData: fetchResults))
                    }
                }()
                case .appliances: {
                    if let cdZone = state.getActiveCDZone() {
                        guard let fetchResults = cdZone.hasFeature?.allObjects as? [CDFeatureData] else {
                            Log.message(.error, message: "Guard Failed : Fetched Results - PreAudit Data")
                            return
                        }

                        finished(.local, mapToFormData(featureData: fetchResults))
                    }
                }()
                default: Log.message(.error, message: "Unable to figure out Entity to Associate !!")
                }
            }
        }

        func mapToFormData(featureData: [CDFeatureData]) -> [String: Any?] {
            var data = featureData.reduce(into: [String: Any?]()) { (aggregate, data) in
                if let key = data.formId, let label = data.key, let type = data.type {
                    if let value = transform(type: type, data: data) {
                        aggregate[key] = value
                    }
                }
            }

            return data
        }

        func transform(type: String, data: CDFeatureData) -> Any? {
            if let eBaseType = InitEnumMapper.sharedInstance.enumMap[type] as? BaseRowType {
                switch eBaseType {
                case .intRow: return (data.value_int as NSNumber?)?.intValue
                case .decimalRow: return data.value_double
                default: return data.value_string
                }
            }
            return nil
        }
    }

    func saveFeatureData(data: [String: Any?], model: GEnergyFormModel, vc: GEFormViewController, finished: @escaping FeatureDataSaveBlock) {

        coreDataAPI.saveFeatureData(data: data, model: model, vc: vc) { result in
            switch result {
            case .Success(let data): Log.message(.info, message: "Success Callback - Save Feature Data"); finished(true) //saveOnNetwork()
            case .Error(let message): Log.message(.error, message: message); finished(false)
            }
        }

        func saveOnNetwork() {
            switch vc.dataBelongsTo() {
            case .preaudit: {
                guard let pfAudit = self.state.getPFAudit() else {
                    Log.message(.error, message: "Guard Failed : PF Audit Object Unavailable")
                    finished(false)
                    return
                }

                pfPreAuditAPI.get(objectId: pfAudit.preAudit.objectId!) { status, object in
                    if (status) {
                        let idToElement = BuilderHelper.mapIdToElements(model: model)

                        guard let pfPreAudit = object as? PFPreAudit else {
                            Log.message(.error, message: "Guard Failed : PFPreAudit")
                            finished(false)
                            return
                        }

                        data.forEach { tuple in
                            if let value = tuple.value {
                                pfPreAudit.featureData[tuple.key] = [idToElement![tuple.key]?.param, value, idToElement![tuple.key]?.dataType]
                            }
                        }
                        self.pfPreAuditAPI.save(pfPreAudit: pfPreAudit) { status in
                            finished(status)
                        }
                    } else {
                        finished(false)
                    }
                }
            }()
            case .zone: {
                if let cdZone = self.state.getActiveCDZone() {
                    if let pfZone = self.state.getLinkedPFZone(guid: cdZone.guid!) {

                        let idToElement = BuilderHelper.mapIdToElements(model: model)

                        data.forEach { tuple in
                            if let value = tuple.value {
                                pfZone.featureData[tuple.key] = [idToElement![tuple.key]?.param, value, idToElement![tuple.key]?.dataType]
                            }
                        }
                        self.pfZoneAPI.save(pfZone: pfZone) { status in
                            finished(status)
                        }
                    } else {
                        finished(false)
                    }
                }

            }()
            default: Log.message(.error, message: "Unable to figure out Entity to save over Network !!")
            }
        }
    }
}

//Mark: - Pop Over Data Model
extension ModelLayer {

    func loadPopOverData(finished: @escaping PopOverDataSourceBlock) {
        Log.message(.info, message: "Loading PopOver Data")

        //ToDo: Code Review !!

        var data = Dictionary<String, Any?>()
        switch state.getActiveZone()! {
        case EZone.none.rawValue:
            if let activeRoom = state.getActiveCDRoom() {
                data[ETagPO.name.rawValue] = activeRoom.name
                finished(.local, data)
            }
        default:
            if let zone = state.getActiveCDZone() {
                data[ETagPO.name.rawValue] = zone.name
                data[ETagPO.type.rawValue] = zone.type
                finished(.local, data)
            }
        }
    }

    func savePopOverData(data: [String: Any?], vc: PopOverViewController, finished: @escaping PopOverDataSaveBlock) {
        Log.message(.info, message: "Pop Over - Data Save")

        guard let _name = data[ETagPO.name.rawValue]! else {
            Log.message(.error, message: "Guard Failed : Extracting Name from Form Data")
            return
        }

        let name = String(describing: _name)

        switch state.getActiveZone()! {
        case EZone.plugload.rawValue:
            switch state.getCount() {

            case .parent:
                let type = EZone.plugload.rawValue
                coreDataAPI.createZone(type: type, name: name) { result in
                    finished(true)
                }

            case .child:
                guard let _type = data[ETagPO.type.rawValue]! else {
                    Log.message(.error, message: "Guard Failed: Extracting Type form Form Data")
                    return
                }

                let type = String(describing: _type)
                let parent = state.counterZLV[ENode.parent.rawValue] as ZoneDTO
                coreDataAPI.createZone(type: type, name: name, parent: parent.cdZone) { result in
                    finished(true)
                }
            }

        case EZone.lighting.rawValue:
            let type = EZone.lighting.rawValue
            coreDataAPI.createZone(type: type, name: name) { result in
                finished(true)
            }

        case EZone.motors.rawValue:
            let type = EZone.motors.rawValue
            coreDataAPI.createZone(type: type, name: name) { result in
                finished(true)
            }

        case EZone.none.rawValue:
            coreDataAPI.createRoom(name: name) { result in
                finished(true)
            }

        default: Log.message(.info, message: "MUST BE - HVAC")
        }
    }

    func updatePopOverData(data: [String: Any?], finished: @escaping PopOverDataUpdateBlock) {
        guard let _name = data[ETagPO.name.rawValue]! else {
            Log.message(.error, message: "Guard Failed : Extracting Name from Form Data")
            return
        }

        let name = String(describing: _name)

        switch state.getActiveZone()! {
        case EZone.none.rawValue:
            if let activeRoom = state.getActiveCDRoom() {
                updateRoom(guid: activeRoom.guid!, name: name) { }
                finished(true)
            }
        default: updateZone(data: data) { status in finished(status) }
        }
    }
}

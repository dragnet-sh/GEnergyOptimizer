//
// Created by Binay Budhthoki on 12/15/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation

import Foundation
import Parse
import CleanroomLogger

class GEStateController {

    class var sharedInstance: GEStateController {
        struct Singleton {
            static let instance = GEStateController()
        }
        return Singleton.instance
    }

    // *** Global Audit Identifier *** //
    fileprivate var auditIdentifier: String?
    fileprivate var activeZone: String?

    // *** Core Data Objects *** //
    fileprivate var cdAudit: CDAudit?
    fileprivate var cdPreAudit: CDPreAudit?
    fileprivate var cdRoom: [CDRoom]?
    fileprivate var cdZone: [CDZone]?
    fileprivate var cdZoneFeature: [CDZoneFeature]?

    // *** Parse Data Objects *** //
    fileprivate var pfAudit: PFAudit?
    fileprivate var pfPreAudit: PFPreAudit?
    fileprivate var pfRoom: [PFRoom]?
    fileprivate var pfZone: [PFZone]?


    // ### Data Sync - Core Data :: Parse Server ### //
    public func sync(complete: @escaping ()->Void) {
        Log.message(.info, message: "Data Sync - In Progress")

        guard let auditIdentifier = self.auditIdentifier else {
            Log.message(.error, message: "Audit Identifier is Nil")
            return
        }

        guard let pfAudit = self.pfAudit else  {
            Log.message(.error, message: "PFAudit in Nil")
            return
        }

        complete()
    }
}

//Mark: - Get | Set
extension GEStateController {

    public func getIdentifier() -> String? {
        guard let identifier = self.auditIdentifier else {
            Log.message(.error, message: "Audit Identifier Not Set")
            return nil
        }

        return identifier
    }

    public func getPFAudit() -> PFAudit? {
        guard let pfAudit = self.pfAudit else {
            Log.message(.error, message: "PFAudit Not Set")
            return nil
        }

        return pfAudit
    }

    public func getCDAudit() -> CDAudit? {
        guard let cdAudit = self.cdAudit else {
            Log.message(.error, message: "CDAudit Not Set")
            return nil
        }

        return cdAudit
    }

    public func getActiveZone() -> String? {
        guard let zone = self.activeZone else {
            Log.message(.error, message: "Zone Not Set")
            return nil
        }

        return zone
    }

    //### Global Audit Registration ###//

    public func registerActiveZone(zone: String) {
        Log.message(.info, message: "Register : Active Zone")
        self.activeZone = zone
    }

    public func registerAuditIdentifier(auditIdentifier: String) {
        Log.message(.info, message: "Register : Audit Identifier")
        self.auditIdentifier = auditIdentifier
    }

    public func registerPFAudit(pfAudit: PFAudit) {
        Log.message(.info, message: "Register : Parse Audit")
        self.pfAudit = pfAudit
    }

    public func registerCDAudit(cdAudit: CDAudit) {
        Log.message(.info, message: "Register : Core Data Audit")
        self.cdAudit = cdAudit
    }

    public func registerCDZone(cdZone: [CDZone]) {
        Log.message(.info, message: "Register : Core Data Zones")
        self.cdZone = cdZone
    }

    //### Flush Active Objects if Exists ###//
    fileprivate func flush() {
        Log.message(.info, message: "Flushing GEnergy State Controller")
        self.auditIdentifier = nil
        self.pfAudit = nil
        self.cdAudit = nil
    }
}

//Mark: - To Be Deleted
extension GEStateController {


    fileprivate func registerPreAuditDTO(preAuditDTO: PFPreAudit) {
        Log.message(.info, message: "Register : PreAudit DTO")
        self.pfPreAudit = preAuditDTO
    }

    fileprivate func registerRoomDTO(roomDTO: [PFRoom]) {
        Log.message(.info, message: "Register : Room DTO")
        self.pfRoom = roomDTO
    }

    public func getPreAuditDTO() -> PFPreAudit? {
        guard let preAuditDTO = self.pfPreAudit else {
            Log.message(.error, message: "Pre Audit DTO Not Set")
            return nil
        }

        return preAuditDTO
    }

    public func getRoomDTO() -> [PFRoom]? {
        guard let roomDTO = self.pfRoom else {
            Log.message(.error, message: "Room DTO Not Set")
            return nil
        }

        return roomDTO
    }
}

//Mark: - PreAudit CRUD
extension GEStateController {

    func initializePreAuditDTO() -> PFPreAudit {
        Log.message(.info, message: "Parse - Initializing PreAuditDTO")
        var preAudit = PFPreAudit()
        preAudit.featureData = Dictionary<String, [Any]>()

        savePreAudit(preAudit: preAudit) {
            //*** Global PreAuditDTO Registration ***//
            self.registerPreAuditDTO(preAuditDTO: preAudit)
        }

        return preAudit
    }

    func getPreAudit(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        if let query = PFPreAudit.query() {

            var status = false
            query.getObjectInBackground(withId: objectId) { object, error in
                if (error == nil) {
                    status = true
                    Log.message(.info, message: "Parse - PreAudit DTO Query - No Errors")
                } else {
                    Log.message(.error, message: error.debugDescription)
                }
                complete(status, object)
            }
        }
    }

    func savePreAudit(preAudit: PFPreAudit, complete: @escaping ()->Void) {
        preAudit.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - PreAudit Data Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete()
        }
    }

    func deletePreAudit(preAudit: PFPreAudit) {

    }
}

//Mark: - Audit CRUD
extension GEStateController {

    func initializeAuditDTO() {
        Log.message(.info, message: "Parse - Initializing AuditDTO")
        var audit = PFAudit()
        audit.identifier = auditIdentifier!
        audit.name = "GEnergy Audit - \(auditIdentifier!)"
        audit.preAudit = initializePreAuditDTO()
        audit.roomCollection = [PFObject]()
        audit.zoneCollection = [
            EZone.lighting.rawValue: [PFObject](),
            EZone.hvac.rawValue: [PFObject](),
            EZone.plugload.rawValue: [PFObject]()
        ]

        saveAudit(auditDTO: audit) {
            // *** Global AuditDTO Registration *** //
            self.registerPFAudit(pfAudit: audit)
        }
    }

    func getAudit(id: String, scope: EStorage, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Querying Audit Object for ID : \(id)")
        if let query = PFAudit.query() {

            if (scope == EStorage.local) { query.fromLocalDatastore() }
            else if (scope == EStorage.server) { }

            var status = false
            query.whereKey("identifier", equalTo: id)
            query.getFirstObjectInBackground { object, error in
                if (error == nil) {
                    status = true
                    Log.message(.info, message: "Parse - AuditDTO Query - No Errors")
                } else {
                    Log.message(.error, message: error.debugDescription)
                }
                complete(status, object)
            }
        }
    }

    func saveAudit(auditDTO: PFAudit, complete: @escaping ()->Void) {

        auditDTO.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Audit DTO Saved - Successful")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete()
        }

    }

    func deleteAudit() {

    }

}

//Mark: - Zone CRUD
extension GEStateController {

    func initializeZoneDTO(name: String, type: String, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Initializing ZoneDTO")
        var zone = PFZone()
        zone.type = type
        zone.name = name
        zone.room = [PFObject]()
        zone.featureData = Dictionary<String, [Any]>()

        saveZone(zoneDTO: zone) {
            self.getAudit(id: self.getIdentifier()!, scope: GUtils.activeStorage()) { status, object in
                guard let object = object as? PFAudit else {
                    Log.message(.error, message: "Audit DTO is NULL")
                    Log.message(.error, message: "Audit to Zone - Association Failed")
                    complete(false)
                    return
                }
                object.zoneCollection[type]!.append(zone)
                self.saveAudit(auditDTO: object) {
                    complete(true)
                }
            }
        }
    }

    func getZone(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        if let query = PFZone.query() {

            query.getObjectInBackground(withId: objectId) { object, error in
                if (error == nil) {
                    Log.message(.info, message: "Parse - ZoneDTO Query - No Errors")
                } else {
                    Log.message(.error, message: error.debugDescription)
                }
                complete(true, object)
             }
        }
    }

    func saveZone(zoneDTO: PFZone, complete: @escaping ()->Void) {

        zoneDTO.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - Zone DTO Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete()
        }
    }

    func deleteZone() {

    }

}

//Mark: - Room CRUD
extension GEStateController {

    func initializeRoomDTO(name: String, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Initializing RoomDTO")
        var room = PFRoom()
        room.name = name

        saveRoom(roomDTO: room) { status in
            if (status) {
                self.getAudit(id: self.getIdentifier()!, scope: GUtils.activeStorage()) { status, object in
                    guard let object = object as? PFAudit else {
                        Log.message(.error, message: "Audit DTO is NULL")
                        Log.message(.error, message: "Audit to Room - Association Failed")
                        complete(false)
                        return
                    }
                    object.roomCollection.append(room)
                    self.saveAudit(auditDTO: object) {
                        complete(true)
                    }
                }
            }

        }

    }

    func getRoom(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        if let query = PFRoom.query() {

            var status = false
            query.getObjectInBackground(withId: objectId) { object, error in
                if (error == nil) {
                    status = true
                    Log.message(.info, message: "Parse - Room DTO Query - No Errors")
                } else {
                    Log.message(.error, message: error.debugDescription)
                }
                complete(status, object)
            }
        }
    }

    // *** Note: Once the Room is saved successfully - Add this to Audit Room Collection
    func saveRoom(roomDTO: PFRoom, complete: @escaping (Bool)->Void) {
        var status = false
        roomDTO.saveInBackground { success, error in
            if (success) {
                status = true
                Log.message(.info, message: "Parser - Room Data Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete(status)
        }
    }

    // *** Note: Remove from the Zone Room Collection -- Audit Room Collection
    func deleteRoom() {

    }

}
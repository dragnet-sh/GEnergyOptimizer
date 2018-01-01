//
// Created by Binay Budhthoki on 12/15/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation

import Foundation
import Parse
import CleanroomLogger

// Audit API - Endpoints to [Create | Read | Update | Delete]

class GEStateController {

    enum StateError: Error {
        case auditIdentifierNotInitialized
    }

    fileprivate var auditIdentifier: String?
    fileprivate var auditDTO: AuditDTO?
    fileprivate var preAuditDTO: PreAuditDTO?
    fileprivate var roomDTO: [RoomDTO]?

    class var sharedInstance: GEStateController {
        struct Singleton {
            static let instance = GEStateController()
        }

        return Singleton.instance
    }

    //### GEnergy Optimizer - Initializer ###//

    public func initGEnergyOptimizer(identifier: String, complete: @escaping ()->Void) {

        // *** Clean PreExisting Objects *** //
        self.flush()

        // *** Global AuditIdentifier Registration *** //
        self.registerAuditIdentifier(auditIdentifier: identifier)

        //1. Verify if this Identifier is Associated to existing Audit Object
        //2. Object Association - True :: Load the AuditDTO Object
        //3. Object Association - False :: Initialize AuditDTO Object

        getAudit(id: identifier, scope: GUtils.activeStorage()) { status, object in

            Log.message(.info, message: "AuditDTO - Running GetAudit Closure")

            // ### Case 1 : Audit DTO is not found
            // Note: Initialize Audit DTO which also initializes PreAudit DTO + Registers

            guard let auditDTO = object as? AuditDTO else {
                Log.message(.error, message: "\(ELogScope.parse.rawValue) AuditDTO Object Conversion Failed")
                Log.message(.info, message: "This probably means - AuditDTO is brand new !!")
                self.initializeAuditDTO()

                complete()
                return
            }

            // ### Case 2: Audit DTO is available and already Queried - Just Register it !!
            // Note: What about PreAudit - We need to query and register it !! *** IMP !!

            if (status) {
                self.registerAuditDTO(auditDTO: auditDTO)

                guard let preAuditPFObject = auditDTO.preAudit as? PreAuditDTO else {
                    auditDTO.preAudit = self.initializePreAuditDTO()
                    self.saveAudit(auditDTO: auditDTO) { /**Nothing to do**/ }

                    complete()
                    return
                }

                self.getPreAudit(objectId: preAuditPFObject.objectId!) { status, object in
                    if (status) {
                        guard let preAuditDTO = object as? PreAuditDTO else {
                            Log.message(.error, message: "Unable to cast PFObject to PreAuditDTO")
                            return
                        }
                        self.registerPreAuditDTO(preAuditDTO: preAuditDTO)
                        complete()
                    }
                }
            }

            complete()
         }
    }

    //### Getters Identifier | AuditDTO | PreAuditDTO ### //

    public func getIdentifier() -> String? {
        guard let identifier = self.auditIdentifier else {
            Log.message(.error, message: "Audit Identifier Not Set")
            return nil
        }

        return identifier
    }

    public func getAuditDTO() -> AuditDTO? {
        guard let auditDTO = self.auditDTO else {
            Log.message(.error, message: "Audit DTO Not Set")
            return nil
        }

        return auditDTO
    }

    public func getPreAuditDTO() -> PreAuditDTO? {
        guard let preAuditDTO = self.preAuditDTO else {
            Log.message(.error, message: "Pre Audit DTO Not Set")
            return nil
        }

        return preAuditDTO
    }

    public func getRoomDTO() -> [RoomDTO]? {
        guard let roomDTO = self.roomDTO else {
            Log.message(.error, message: "Room DTO Not Set")
            return nil
        }

        return roomDTO
    }

    //### Global Audit | PreAudit | Audit Identifier Registration ###//

    fileprivate func registerAuditIdentifier(auditIdentifier: String) {
        Log.message(.info, message: "Register : Audit Identifier")
        self.auditIdentifier = auditIdentifier
    }

    fileprivate func registerAuditDTO(auditDTO: AuditDTO) {
        Log.message(.info, message: "Register : Audit DTO")
        self.auditDTO = auditDTO
    }

    fileprivate func registerPreAuditDTO(preAuditDTO: PreAuditDTO) {
        Log.message(.info, message: "Register : PreAudit DTO")
        self.preAuditDTO = preAuditDTO
    }

    fileprivate func registerRoomDTO(roomDTO: [RoomDTO]) {
        Log.message(.info, message: "Register : Room DTO")
        self.roomDTO = roomDTO
    }

    //### Flush Active Objects if Exists ###//
    fileprivate func flush() {
        Log.message(.info, message: "Flushing GEnergy State Controller")
        self.auditIdentifier = nil
        self.auditDTO = nil
        self.preAuditDTO = nil
        self.roomDTO = nil
    }
}


//Mark: - PreAudit CRUD

extension GEStateController {

    func initializePreAuditDTO() -> PreAuditDTO {
        Log.message(.info, message: "Parse - Initializing PreAuditDTO")
        var preAudit = PreAuditDTO()
        preAudit.data = Dictionary<String, [Any]>()

        savePreAudit(preAudit: preAudit) {
            //*** Global PreAuditDTO Registration ***//
            self.registerPreAuditDTO(preAuditDTO: preAudit)
        }

        return preAudit
    }

    func getPreAudit(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        if let query = PreAuditDTO.query() {

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

    func savePreAudit(preAudit: PreAuditDTO, complete: @escaping ()->Void) {
        preAudit.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - PreAudit Data Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete()
        }
    }

    func deletePreAudit(preAudit: PreAuditDTO) {

    }
}

//Mark: - Audit CRUD

extension GEStateController {

    func initializeAuditDTO() {
        Log.message(.info, message: "Parse - Initializing AuditDTO")
        var audit = AuditDTO()
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
            self.registerAuditDTO(auditDTO: audit)
        }
    }

    func getAudit(id: String, scope: EStorage, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Querying Audit Object for ID : \(id)")
        if let query = AuditDTO.query() {

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

    func saveAudit(auditDTO: AuditDTO, complete: @escaping ()->Void) {

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
        var zone = ZoneDTO()
        zone.type = type
        zone.name = name
        zone.room = [PFObject]()
        zone.featureData = Dictionary<String, [Any]>()

        saveZone(zoneDTO: zone) {
            self.getAudit(id: self.getIdentifier()!, scope: GUtils.activeStorage()) { status, object in
                guard let object = object as? AuditDTO else {
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
        if let query = ZoneDTO.query() {

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

    func saveZone(zoneDTO: ZoneDTO, complete: @escaping ()->Void) {

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
        var room = RoomDTO()
        room.name = name

        saveRoom(roomDTO: room) { status in
            if (status) {
                self.getAudit(id: self.getIdentifier()!, scope: GUtils.activeStorage()) { status, object in
                    guard let object = object as? AuditDTO else {
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
        if let query = RoomDTO.query() {

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
    func saveRoom(roomDTO: RoomDTO, complete: @escaping (Bool)->Void) {
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
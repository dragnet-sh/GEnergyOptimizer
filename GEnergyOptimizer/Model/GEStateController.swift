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

    public func registerPFPreAudit(pfPreAudit: PFPreAudit) {
        Log.message(.info, message: "Register : Parse Pre Audit")
        self.pfPreAudit = pfPreAudit
    }

    public func registerPFZone(pfZone: [PFZone]) {
        Log.message(.info, message: "Register : Parse Zone")
        self.pfZone = pfZone
    }

    public func registerPFRoom(pfRoom: [PFRoom]) {
        Log.message(.info, message: "Register : Parse Room")
        self.pfRoom = pfRoom
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
    public func getPreAuditDTO() -> PFPreAudit? {
        guard let preAuditDTO = self.pfPreAudit else {
            Log.message(.error, message: "Pre Audit DTO Not Set")
            return nil
        }

        return preAuditDTO
    }
}


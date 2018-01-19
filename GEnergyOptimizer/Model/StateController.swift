//
// Created by Binay Budhthoki on 12/15/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation

import Foundation
import CleanroomLogger

class StateController {

    class var sharedInstance: StateController {
        struct Singleton {
            static let instance = StateController()
        }
        return Singleton.instance
    }

    // *** Global Audit Identifier *** //
    fileprivate var auditIdentifier: String?
    fileprivate var activeZone: String?

    // *** Core Data Objects *** //
    fileprivate var cdAudit: CDAudit?
    fileprivate var cdZone: CDZone?

    // *** Parse Data Objects *** //
    fileprivate var pfAudit: PFAudit?
    fileprivate var pfPreAudit: PFPreAudit?
    fileprivate var pfZone: PFZone?

    // *** Parse - Core Data >> Cross Over Link *** //
    fileprivate var crosswalk: Dictionary<String, PFZone>

    init() {
        self.crosswalk = Dictionary<String, PFZone>()
    }
}

extension StateController {

    // *** Access Point *** //

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

    public func getActiveCDZone() -> CDZone? {
        guard let cdZone = self.cdZone else {
            Log.message(.error, message: "CDZone Not Set")
            return nil
        }

        return cdZone
    }

    public func getActiveZone() -> String? {
        guard let zone = self.activeZone else {
            Log.message(.error, message: "Zone Not Set")
            return nil
        }

        return zone
    }

    public func getLinkedPFZone(uuid: String) -> PFZone? {
        return crosswalk[uuid]
    }

    // *** Global Registration *** //

    public func registerActiveZone(zone: String) {
        Log.message(.info, message: "Register : Active Zone :: \(zone)")
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

    public func registerCDAudit(cdAudit: CDAudit) {
        Log.message(.info, message: "Register : Core Data Audit")
        self.cdAudit = cdAudit
    }

    public func registerCDZone(cdZone: CDZone) {
        Log.message(.info, message: "Register : Core Data Zone")
        self.cdZone = cdZone
    }

    public func registerCrosswalk(uuid: String, pfZone: PFZone) {
        Log.message(.info, message: "Register : Crosswalk")
        self.crosswalk[uuid] = pfZone
    }
}

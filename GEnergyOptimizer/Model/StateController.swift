//
// Created by Binay Budhthoki on 12/15/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

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

    // *** Zone List View Controller - Stack Counter *** //
    public var counterZLV: Dictionary<EZone, Array<Any>>

    init() {
        self.crosswalk = Dictionary<String, PFZone>()
        self.counterZLV = Dictionary<EZone, Array<Any>>()
        initCounter()
    }

    fileprivate func initCounter() {
            EZone.getAll.forEach { eZone in
                self.counterZLV[eZone] = Array<Any>()
        }
    }
}

extension StateController {

    // *** Access Point *** //

    public func getIdentifier() -> String? {
        Log.message(.info, message: "State : Get Identifier")
        guard let identifier = self.auditIdentifier else {
            Log.message(.error, message: "Audit Identifier Not Set")
            return nil
        }

        return identifier
    }

    public func getPFAudit() -> PFAudit? {
        Log.message(.info, message: "State : Get PFAudit")
        guard let pfAudit = self.pfAudit else {
            Log.message(.error, message: "PFAudit Not Set")
            return nil
        }

        return pfAudit
    }

    public func getCDAudit() -> CDAudit? {
        Log.message(.info, message: "State : Get CDAudit")
        guard let cdAudit = self.cdAudit else {
            Log.message(.error, message: "CDAudit Not Set")
            return nil
        }

        return cdAudit
    }

    public func getActiveCDZone() -> CDZone? {
        Log.message(.info, message: "State : Get Active CDZone")
        guard let cdZone = self.cdZone else {
            Log.message(.error, message: "CDZone Not Set")
            return nil
        }

        return cdZone
    }

    public func getActiveZone() -> String? {
        Log.message(.info, message: "State : Get Active Zone")
        guard let zone = self.activeZone else {
            Log.message(.error, message: "Zone Not Set")
            return nil
        }

        return zone
    }

    public func getLinkedPFZone(guid: String) -> PFZone? {
        Log.message(.info, message: "State : Get Linked PFZone via GUID Map")
        return crosswalk[guid]
    }

    func counter(action: Action, zone: String, vc: UIViewController) {
        switch action {
        case .push: counterZLV[GUtils.getEZone(rawValue: zone)]!.append(vc)
        case .pop: counterZLV[GUtils.getEZone(rawValue: zone)]!.popLast()
        }
    }

    func getCount(type: EZone) -> Int {
        return counterZLV[type]!.count
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

    public func registerCrosswalk(guid: String, pfZone: PFZone) {
        Log.message(.info, message: "Register : Crosswalk")
        self.crosswalk[guid] = pfZone
    }


}

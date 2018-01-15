//
// Created by Binay Budhthoki on 1/12/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

typealias PFGetReturnBlockAudit = (Result<PFAudit?>) -> Void

class PFAuditAPI  {

    class var sharedInstance: PFAuditAPI {
        struct Singleton {
            static let instance = PFAuditAPI()
        }
        return Singleton.instance
    } 

    func initialize(identifier: String, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Initializing PFAudit with Identifier - \(identifier)")
        var status = false
        var audit = PFAudit()
        audit.identifier = identifier
        audit.name = "GEnergy Audit - \(identifier)"
        audit.preAudit = PFPreAuditAPI.sharedInstance.initialize()
        audit.roomCollection = [PFObject]()
        audit.zoneCollection = [
            EZone.lighting.rawValue: [PFObject](),
            EZone.hvac.rawValue: [PFObject](),
            EZone.plugload.rawValue: [PFObject]()
        ]

        save(pfAudit: audit) { status in
            complete(status, audit)
        }
    }

    func get(id: String, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Querying Audit Object for ID : \(id)")
        if let query = PFAudit.query() {

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

    func save(pfAudit: PFAudit, complete: @escaping (Bool)->Void) {
        pfAudit.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - PFAudit Data Saved : Successful")
                complete(true)
            } else {
                Log.message(.error, message: error.debugDescription)
                complete(false)
            }
        }
    }

    func delete() {

    }
}
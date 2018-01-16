//
// Created by Binay Budhthoki on 1/12/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class PFZoneAPI {

    class var sharedInstance: PFZoneAPI {
        struct Singleton {
            static let instance = PFZoneAPI()
        }
        return Singleton.instance
    }

    func initialize(name: String, type: String, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Initializing ZoneDTO")
        var zone = PFZone()
        zone.type = type
        zone.name = name
        zone.room = [PFObject]()
        zone.featureData = Dictionary<String, [Any]>()

        save(pfZone: zone) { status in
            self.linkZoneToAudit(zone: zone) { status in
                if (status) {
                    complete(status)
                }
            }
        }
    }

    func get(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Get Zone")
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

    func save(pfZone: PFZone, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Save Zone")
        pfZone.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - Zone DTO Saved")
                complete(true)
            } else {
                Log.message(.error, message: error.debugDescription)
                complete(false)
            }
        }
    }

    func linkZoneToAudit(zone: PFZone, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Link Zone to Audit")
        if let identifier = GEStateController.sharedInstance.getIdentifier() {
            PFAuditAPI.sharedInstance.get(id: identifier) { status, object in
                guard let object = object as? PFAudit else {
                    Log.message(.error, message: "PFAudit is NULL")
                    Log.message(.error, message: "PFAudit to Zone - Association Failed")
                    complete(false)
                    return
                }
                object.zoneCollection[zone.type]!.append(zone)
                PFAuditAPI.sharedInstance.save(pfAudit: object) { status in
                    complete(status)
                }
            }
        } else {
            Log.message(.error, message: "Audit Identifier is not Registered")
            Log.message(.error, message: "PFAudit to Zone - Association Failed")
        }
    }

    func delete() {
        Log.message(.info, message: "Parse - Delete Zone")
    }
}
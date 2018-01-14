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

        save(pfZone: zone) {

            if let identifier = GEStateController.sharedInstance.getIdentifier() {
                PFAuditAPI.sharedInstance.get(id: identifier) { status, object in
                    guard let object = object as? PFAudit else {
                        Log.message(.error, message: "PFAudit is NULL")
                        Log.message(.error, message: "PFAudit to Zone - Association Failed")
                        complete(false)
                        return
                    }
                    object.zoneCollection[type]!.append(zone)
                    PFAuditAPI.sharedInstance.save(pfAudit: object) {
                        complete(true)
                    }
                }
            } else {
                Log.message(.error, message: "Audit Identifier is not Registered")
                Log.message(.error, message: "PFAudit to Zone - Association Failed")
            }
        }
    }

    func get(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
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

    func save(pfZone: PFZone, complete: @escaping ()->Void) {

        pfZone.saveInBackground { success, error in
            if (success) {
                Log.message(.info, message: "Parse - Zone DTO Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete()
        }
    }

    func delete() {

    }
}
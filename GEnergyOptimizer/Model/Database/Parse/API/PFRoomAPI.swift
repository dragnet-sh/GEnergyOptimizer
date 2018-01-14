//
// Created by Binay Budhthoki on 1/12/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

class PFRoomAPI {

    class var sharedInstance: PFRoomAPI {
        struct Singleton {
            static let instance = PFRoomAPI()
        }
        return Singleton.instance
    }

    func initialize(name: String, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Initializing PFRoom")
        var room = PFRoom()
        room.name = name

        save(pfRoom: room) { status in
            if (status) {
                if let identifier = GEStateController.sharedInstance.getIdentifier() {
                    PFAuditAPI.sharedInstance.get(id: identifier) { status, object in
                        guard let object = object as? PFAudit else {
                            Log.message(.error, message: "PFAudit is NULL")
                            Log.message(.error, message: "PFAudit to PFRoom - Association Failed")
                            complete(false)
                            return
                        }
                        object.roomCollection.append(room)
                        PFAuditAPI.sharedInstance.save(pfAudit: object) {
                            complete(true)
                        }
                    }
                } else {
                    Log.message(.error, message: "Audit Identifier is not Registered")
                    Log.message(.error, message: "PFAudit to PFRoom - Association Failed")
                }
            }
        }
    }

    func get(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        if let query = PFRoom.query() {

            var status = false
            query.getObjectInBackground(withId: objectId) { object, error in
                if (error == nil) {
                    status = true
                    Log.message(.info, message: "Parse - PFRoom Query - No Errors")
                } else {
                    Log.message(.error, message: error.debugDescription)
                }
                complete(status, object)
            }
        }
    }

    // *** Note: Once the Room is saved successfully - Add this to Audit Room Collection
    func save(pfRoom: PFRoom, complete: @escaping (Bool)->Void) {
        var status = false
        pfRoom.saveInBackground { success, error in
            if (success) {
                status = true
                Log.message(.info, message: "Parser - PFRoom Data Saved")
            } else {
                Log.message(.error, message: error.debugDescription)
            }

            complete(status)
        }
    }

    // *** Note: Remove from the Zone Room Collection -- Audit Room Collection
    func delete() {

    }
}
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
                self.linkRoomToAudit(room: room) { status in
                    complete(status)
                }
            }
        }
    }

    func get(objectId: String, complete: @escaping (Bool, PFObject?)->Void) {
        Log.message(.info, message: "Parse - Get Room")
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

    func getAll(objects: [PFObject], complete: @escaping (Bool, [PFObject])->Void) {
        Log.message(.info, message: "Parse - Bulk Get Room")
        PFRoom.fetchAll(inBackground: objects) { objects, error in
            guard let objects = objects as? [PFRoom] else {
                Log.message(.error, message: "Guard Failed - Bulk Fetch PFRoom")
                return
            }
            complete(true, objects)
        }
    }


    // *** Note: Once the Room is saved successfully - Add this to Audit Room Collection
    func save(pfRoom: PFRoom, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Save Room")
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

    func linkRoomToAudit(room: PFRoom, complete: @escaping (Bool)->Void) {
        Log.message(.info, message: "Parse - Link Room to Audit")
        if let identifier = StateController.sharedInstance.getIdentifier() {
            PFAuditAPI.sharedInstance.get(id: identifier) { status, object, error in
                guard let object = object as? PFAudit else {
                    Log.message(.error, message: "PFAudit is NULL")
                    Log.message(.error, message: "PFAudit to PFRoom - Association Failed")
                    complete(false)
                    return
                }
                object.roomCollection.append(room)
                PFAuditAPI.sharedInstance.save(pfAudit: object) { status in
                    complete(status)
                }
            }
        } else {
            Log.message(.error, message: "Audit Identifier is not Registered")
            Log.message(.error, message: "PFAudit to PFRoom - Association Failed")
        }
    }

    // *** Note: Remove from the Zone Room Collection -- Audit Room Collection
    func delete() {
        Log.message(.info, message: "Parse - Delete Room")
    }
}
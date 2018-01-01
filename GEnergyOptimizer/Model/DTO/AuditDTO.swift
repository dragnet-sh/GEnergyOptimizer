//
// Created by Binay Budhthoki on 12/4/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse

//PreAudit - Is a mandatory component of Audit

public class PreAuditDTO: PFObject {
    @NSManaged public var data: Dictionary<String, [Any]>
}

extension PreAuditDTO: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Audit - Has Multiple Zones of Type EZone

public class AuditDTO: PFObject {
    @NSManaged public var identifier: String //ID to track the Audit Object
    @NSManaged public var name: String
    @NSManaged public var preAudit: PFObject
    @NSManaged public var roomCollection: [PFObject]
    @NSManaged public var zoneCollection: Dictionary<String, [PFObject]>
}

extension AuditDTO: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Zone - Spans One or Many Rooms - Has a Set of Feature Data

public class ZoneDTO: PFObject {
    @NSManaged public var type: String
    @NSManaged public var name: String
    @NSManaged public var room: [PFObject]
    @NSManaged public var featureData: Dictionary<String, [Any]>
}

extension ZoneDTO: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Room - Collection of Type ERoom
//ToDo: Additional Room Attributes - Area | Lighting | etc.

public class RoomDTO: PFObject {
    @NSManaged public var name: String
}

extension RoomDTO: PFSubclassing {
    public static func parseClassName() -> String {
        return String(describing: self)
    }
}


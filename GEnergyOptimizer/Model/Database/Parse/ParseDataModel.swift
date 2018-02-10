//
// Created by Binay Budhthoki on 12/4/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Parse

//PreAudit - Is a mandatory component of Audit

public class PFPreAudit: PFObject {
    @NSManaged public var featureData: Dictionary<String, [Any]>
}

extension PFPreAudit: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Audit - Has Multiple Zones of Type EZone
//Audit - Has A PreAudit
//Audit - Has A Collection of Room

public class PFAudit: PFObject {
    @NSManaged public var identifier: String //ID to track the Audit Object
    @NSManaged public var name: String
    @NSManaged public var preAudit: PFObject
    @NSManaged public var roomCollection: [PFObject]
    @NSManaged public var zoneCollection: Dictionary<String, [PFObject]>
}

extension PFAudit: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Zone - Spans One or Many Rooms
//Zone - Has A Set of Feature Data

public class PFZone: PFObject {
    @NSManaged public var type: String
    @NSManaged public var name: String
    @NSManaged public var room: [PFObject]
    @NSManaged public var featureData: Dictionary<String, [Any]>
}

extension PFZone: PFSubclassing {
    public class func parseClassName() -> String {
        return String(describing: self)
    }
}

//Room - Collection of Type ERoom

public class PFRoom: PFObject {
    @NSManaged public var name: String
}

extension PFRoom: PFSubclassing {
    public static func parseClassName() -> String {
        return String(describing: self)
    }
}


//Plugload

public class PlugLoad: PFObject {
    @NSManaged public var type: String
    @NSManaged public var data: Dictionary<String, Any>
}

extension PlugLoad: PFSubclassing {
    public static func parseClassName() -> String {
        return String(describing: self)
    }
}


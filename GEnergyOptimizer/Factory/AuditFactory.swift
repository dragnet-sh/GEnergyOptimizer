//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

enum GEnergyError: Error {
    case IdentifierNotSet
    case AuditNone
    case PreAuditNone
    case ZoneNone
}

class AuditFactory {
    class var sharedInstance: AuditFactory {
        struct Singleton {
            static let instance = AuditFactory()
        }

        return Singleton.instance
    }

    var coreDataAPI: CoreDataAPI
    var state: StateController

    init() {
        self.coreDataAPI = CoreDataAPI.sharedInstance
        self.state = StateController.sharedInstance
    }

    func getIdentifier() throws -> String {
        if let identifier = state.getIdentifier() {return identifier}
        else {throw GEnergyError.IdentifierNotSet}
    }

    func setAudit() throws -> CDAudit {
        if let audit = coreDataAPI.getAudit(id: try! getIdentifier()) {return audit}
        else {throw GEnergyError.AuditNone}
    }

    func setPreAudit() throws -> [CDFeatureData] {
        let audit = try! setAudit()
        if let preAudit = audit.hasPreAuditFeature?.allObjects as? [CDFeatureData] {return preAudit}
        else {throw GEnergyError.PreAuditNone}
    }

    func setZone() throws -> [CDZone] {
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let audit = try! setAudit()
        if let zone = audit.hasZone?.sortedArray(using: [sortDescriptor]) as? [CDZone] {return zone}
        else {throw GEnergyError.ZoneNone}
    }
}
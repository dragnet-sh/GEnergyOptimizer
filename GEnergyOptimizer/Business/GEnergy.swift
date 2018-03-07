//
// Created by Binay Budhthoki on 2/27/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import MBProgressHUD
import SwiftyDropbox
import Alamofire
import Parse

class GEnergy {
    private var gAudit: GAudit
    private var gHVAC: GHVAC
    private var gPlugload: GPlugLoad
    private var delegate: UIViewController
    var status: Bool = true

    init(_ delegate: UIViewController) {
        self.gAudit = GAudit()
        self.gHVAC = GHVAC()
        self.gPlugload = GPlugLoad()
        self.delegate = delegate
    }

    public func crunch() {

        // -- 1. Check Internet Connectivity
        guard let net = NetworkReachabilityManager() else {
            GUtils.message(msg: "No Internet Connection")
            return
        }
        net.startListening()
        let isReachable = net.isReachable
        net.stopListening()
        guard isReachable else {GUtils.message(msg: "No Internet Connection"); return}

        // -- 2. Check DropBox Authorization
        guard let client = DropboxClientsManager.authorizedClient else {
            Log.message(.error, message: "Un-Authorized")
            GUtils.message(msg: "Unable to Connect to DropBox")
            return
        }

        let hud = MBProgressHUD.showAdded(to: delegate.view, animated: true)
        hud.label.text = "Processing"
        let group = DispatchGroup()
        let backgroundQ = DispatchQueue.global(priority: .background)

        group.enter()
        self.gHVAC._calculate(hud) {group.leave()}

        group.enter()
        self.gPlugload._calculate(hud) {group.leave()}

        group.notify(queue: .main) {
            if self.gHVAC.status && self.gPlugload.status {
                GUtils.showSucceeded(hud)
            } else {
                GUtils.showFailed(hud)
                GUtils.message(msg: "There were one or more errors while processing !!")
            }

            hud.hide(animated: true, afterDelay: 1)
        }
    }

    public func backup() {
        gAudit.backup()
    }
}

protocol CalculateAndUpload {
    func _features() -> [CDFeatureData]?
    func _calculate(_ hud: MBProgressHUD, completed: @escaping () -> Void)
}

class GAudit {
    public var audit: CDAudit
    public var preaudit: [CDFeatureData]
    public var zone: [CDZone]
    let factory = AuditFactory.sharedInstance
    var status: Bool = true

    init() {
        self.audit = try! factory.setAudit()
        self.preaudit = try! factory.setPreAudit()
        self.zone = try! factory.setZone()
    }

    func backup() {
        // Create OutgoingRows and call it's upload Method // -- Simple : )
    }
}

class GHVAC: GAudit, CalculateAndUpload {
    func _features() -> [CDFeatureData]? {
        let model = BuilderHelper.decodeJSON(bundleResource: FileResource.preaudit.rawValue)!
        let sId2Ele = BuilderHelper.mapSectionIdsToElements(model: model)!
        let sId2Name = BuilderHelper.mapSectionIdsToName(model: model)!

        var hvacSId = Array<String>()
        for (sectionId, sectionName) in sId2Name {
            if sectionName.starts(with: "HVAC") {
                hvacSId.append(sectionId)}
        }

        var gElements = Array<GElements>()
        hvacSId.forEach {gElements.append(contentsOf: sId2Ele[$0]!)}

        let hvacEId = gElements.map {$0.elementId!}
        let feature = super.preaudit.filter { feature in
            return hvacEId.contains(feature.formId!)
        }

        return feature
    }

    func _calculate(_ hud: MBProgressHUD, completed: @escaping () -> Void) {
        guard let feature = _features() else {return}
        let group = DispatchGroup()
        let backgroundQ = DispatchQueue.global(qos: .background)

        group.enter()
        backgroundQ.async(group: group, execute: {
            HVAC(feature).compute { rows in
                guard let rows = rows else {
                    super.status = false; group.leave()
                    return
                }
                rows.upload { error in
                    if error != .none {self.status = false}
                    group.leave()
                }
            }
        })

        group.notify(queue: .main) {
            completed()
        }
    }
}

class GPlugLoad: GAudit, CalculateAndUpload {
    var plZone: CDZone?

    override init() {
        super.init()
    }

    init(plZone: CDZone) {
        self.plZone = plZone
    }

    func _features() -> [CDFeatureData]? {
        return plZone!.hasFeature?.allObjects as? [CDFeatureData]
    }

    func type() -> EApplianceType {
        return GUtils.getEAppliance(rawValue: plZone!.type!)
    }

    func _calculate(_ hud: MBProgressHUD, completed: @escaping () -> Void) {
        let group = DispatchGroup()
        let backgroundQ = DispatchQueue.global(priority: .background)
        let _zone = self.zone.filter { zone in GUtils.getEAppliance(rawValue: zone.type!) != .none }

        for eachZone in _zone {
            let plugLoad = GPlugLoad(plZone: eachZone)
            guard let feature = plugLoad._features() else {
                Log.message(.error, message: "Zone - Feature Data Null.")
                super.status = false; return
            }

            group.enter()
            switch plugLoad.type() {
            case .freezerFridge: Refrigerator(feature).compute { rows in
                guard let rows = rows else {
                    self.status = false; group.leave()
                    return
                }
                rows.upload { error in
                    if error != .none {self.status = false}
                    group.leave()
                }
            }

            case .fryer: Fryer(feature).compute { rows in
                guard let rows = rows else {
                    self.status = false; group.leave()
                    return
                }
                rows.upload { error in
                    if error != .none {self.status = false}
                    group.leave()
                }
            }

            default: Log.message(.warning, message: "UNKNOWN"); group.leave()
            }
        }

        group.notify(queue: .main) {
            completed()
        }
    }
}

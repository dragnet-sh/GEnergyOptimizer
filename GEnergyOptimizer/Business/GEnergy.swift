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
    private var gLighting: GLighting
    private var gMotors: GMotors
    private var delegate: UIViewController
    var status: Bool = true

    init(_ delegate: UIViewController) {
        self.gAudit = GAudit()
        self.gHVAC = GHVAC()
        self.gPlugload = GPlugLoad()
        self.gLighting = GLighting()
        self.gMotors = GMotors()
        self.delegate = delegate
    }

    public func crunch() {

        // ****** Note : Before Crunch - Make sure all the required constraints are Met ****** //

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
        guard let _ = DropboxClientsManager.authorizedClient else {
            Log.message(.error, message: "Un-Authorized")
            GUtils.message(msg: "Unable to Connect to DropBox")
            return
        }

        // -- 3. Check Utility Rate Structure
        let preAudit = GUtils.mapFeatureData(feature: gAudit.preaudit)
        guard let _ = preAudit["Electric Rate Structure"] else {
            Log.message(.error, message: "Empty Rate Structure")
            GUtils.message(msg: "Empty Rate Structure")
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

        group.enter()
        self.gLighting._calculate(hud) {group.leave()}

        group.enter()
        self.gMotors._calculate(hud) {group.leave()}

        group.notify(queue: .main) {
            if self.gHVAC.status && self.gPlugload.status && self.gLighting.status {
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

        let plugloadZone: [CDZone] = zone.filter {zone in zone.type! == EZone.plugload.rawValue}
        let motorZone: [CDZone] = zone.filter {zone in zone.type! == EZone.motors.rawValue}
        let lightingZone: [CDZone] = zone.filter {zone in zone.type! == EZone.lighting.rawValue}

        Log.message(.info, message: "###### Zone - Plugload ######")
        plugloadZone.forEach { parent in
            let child = self.zone.filter { zone in GUtils.getEAppliance(rawValue: zone.type!) != .none }
            child.forEach { zone in
                let plugload = GPlugLoad(plZone: zone)
                if let features = plugload._features() {
                    let data = GUtils.mapFeatureData(feature: features)

                    Log.message(.info, message: "**********************")
                    Log.message(.info, message: parent.name.debugDescription)
                    Log.message(.info, message: zone.name.debugDescription)
                    Log.message(.info, message: data.debugDescription)
                }
            }
        }

        Log.message(.info, message: "###### Zone - Motors ######")
        motorZone.forEach { zone in
            if let features = zone.hasFeature?.allObjects as? [CDFeatureData] {
                let data = GUtils.mapFeatureData(feature: features)

                Log.message(.info, message: "**********************")
                Log.message(.info, message: zone.name.debugDescription)
                Log.message(.info, message: data.debugDescription)
            }
        }

        Log.message(.info, message: "###### Zone - Lighting ######")
        lightingZone.forEach { zone in
            if let features = zone.hasFeature?.allObjects as? [CDFeatureData] {
                let data = GUtils.mapFeatureData(feature: features)

                Log.message(.info, message: "**********************")
                Log.message(.info, message: zone.name.debugDescription)
                Log.message(.info, message: data.debugDescription)
            }
        }

        Log.message(.info, message: "###### Zone - HVAC ######")
        if let features = GHVAC()._features() {
            let data = GUtils.mapFeatureData(feature: features)

            Log.message(.info, message: "**********************")
            Log.message(.info, message: "HVAC")
            Log.message(.info, message: data.debugDescription)
        }

        Log.message(.info, message: "###### PreAudit ######")
        Log.message(.info, message: "PreAudit")
        let data = GUtils.mapFeatureData(feature: preaudit)
        Log.message(.info, message: data.debugDescription)
    }

    func upload(_ group: DispatchGroup, _ rows: OutgoingRows?) {
        guard let rows = rows else {
            group.leave()
            return
        }

        rows.upload { error in
            if error != .none {self.status = false}
            group.leave()
        }
    }

    func compute(_ group: DispatchGroup, _ device: Computable) {
        device.compute { rows in
           self.upload(group, rows)
        }
    }
}

class GMotors: GAudit, CalculateAndUpload {
    var mZone: CDZone?

    override init() {
        super.init()
    }

    init(zone: CDZone) {
        self.mZone = zone
    }

    func _features() -> [CDFeatureData]? {
        return mZone!.hasFeature?.allObjects as? [CDFeatureData]
    }

    func _calculate(_ hud: MBProgressHUD, completed: @escaping () -> Void) {
        let group = DispatchGroup()
        let backgroundQ = DispatchQueue.global(priority: .background)
        let _zone = super.zone.filter {zone in zone.type! == EZone.motors.rawValue}

        for eachZone in _zone {
            let lighting = GMotors(zone: eachZone)
            guard let feature = lighting._features() else {
                Log.message(.error, message: "Zone - Feature Data Null.")
                super.status = false;
                return
            }

            group.enter()
            self.compute(group, Motors(feature))
        }

        group.notify(queue: .main) {completed()}
    }
}

class GLighting: GAudit, CalculateAndUpload {
    var lZone: CDZone?

    override init() {
        super.init()
    }

    init(zone: CDZone) {
        self.lZone = zone
    }

    func _features() -> [CDFeatureData]? {
        return lZone!.hasFeature?.allObjects as? [CDFeatureData]
    }

    func _calculate(_ hud: MBProgressHUD, completed: @escaping () -> Void) {
        let group = DispatchGroup()
        let backgroundQ = DispatchQueue.global(priority: .background)
        let _zone = super.zone.filter {zone in zone.type! == EZone.lighting.rawValue}

        for eachZone in _zone {
            let lighting = GLighting(zone: eachZone)
            guard let feature = lighting._features() else {
                Log.message(.error, message: "Zone - Feature Data Null.")
                super.status = false;
                return
            }

            group.enter()
            self.compute(group, Lighting(feature))
        }

        group.notify(queue: .main) {completed()}
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
            self.compute(group, HVAC(feature))
        })

        group.notify(queue: .main) {completed()}
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
        let _zone = super.zone.filter { zone in GUtils.getEAppliance(rawValue: zone.type!) != .none }

        for eachZone in _zone {
            let plugLoad = GPlugLoad(plZone: eachZone)
            guard let feature = plugLoad._features() else {
                Log.message(.error, message: "Zone - Feature Data Null.")
                super.status = false; return
            }

            group.enter()
            switch plugLoad.type() {
            case .freezerFridge: compute(group, Refrigerator(feature))
            case .fryer: compute(group, Fryer(feature))
            case .rackOven: compute(group, RackOven(feature))
            case .combinationOven: compute(group, CombinationOven(feature))
            case .convectionOven: compute(group, ConvectionOven(feature))
            case .conveyorOven: compute(group, ConveyorOven(feature))
            case .griddle: compute(group, Griddle(feature))
            case .steamCooker: compute(group, SteamCooker(feature))
            case .iceMaker: compute(group, IceMaker(feature))
            default: Log.message(.warning, message: "UNKNOWN"); group.leave()
            }
        }

        group.notify(queue: .main) {completed()}
    }
}

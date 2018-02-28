//
//  AppDelegate.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/24/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Parse
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let runtime = DEnv.local

    var parseKeys = [
        DEnv.local: [
            "applicationId": Constants.Parse.Local.applicationId,
            "clientKey": Constants.Parse.Local.clientKey,
            "server": Constants.Parse.Local.server
        ],

        DEnv.prod: [
            "applicationId": Constants.Parse.Prod.applicationId,
            "clientKey": Constants.Parse.Prod.clientKey,
            "server": Constants.Parse.Prod.server
        ]
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Log.enable(configuration: LoggerUtils.getConfig())
        Log.message(.info, message: "GEnergy - Entry Point")

        registerPSub()
        configureParse()
        GUtils.applicationDocumentsDirectory()
        DropboxClientsManager.setupWithAppKey(Constants.Dropbox.kDBAppKey)

        return true
    }

    fileprivate func configureParse() {
        Log.message(.info, message: "Parse - Initialization - Processing")
        let configuration = ParseClientConfiguration {
            $0.applicationId = self.parseKeys[self.runtime]!["applicationId"]!
            $0.clientKey = self.parseKeys[self.runtime]!["clientKey"]!
            $0.server = self.parseKeys[self.runtime]!["server"]!
            $0.isLocalDatastoreEnabled = true
        }

        Parse.initialize(with: configuration)
        Log.message(.info, message: "Parse - Initialization - Complete")
    }

    fileprivate func registerPSub() {
        Log.message(.info, message: "Parse - Registering DTO - PFObjects")

        PFPreAudit.registerSubclass()
        PFAudit.registerSubclass()
        PFZone.registerSubclass()
        PFRoom.registerSubclass()
        PlugLoad.registerSubclass()
    }
}


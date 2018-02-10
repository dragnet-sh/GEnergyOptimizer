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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let runtime = "LOCAL"

    var applicationId = ""
    var clientKey = ""
    var server = ""

    //*** Parse Configuration - Local Server ***//
    let applicationIdLocal = "NLI214vDqkoFTJSTtIE2xLqMme6Evd0kA1BbJ20S"
    let clientKeyLocal = "lgEhciURXhAjzITTgLUlXAEdiMJyIF4ZBXdwfpUr"
    let serverLocal = "http://localhost:1337/parse"

    //*** Parse Configuration - Test Server ***//
    let applicationIdProd = "47f916f7005d19ddd78a6be6b4bdba3ca49615a0"
    let clientKeyProd = "275302fd8b2b56dca85f127a6123f281b670c787"
    let serverProd = "http://ec2-18-220-200-115.us-east-2.compute.amazonaws.com:80/parse"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        switch runtime {
            case "LOCAL":
                applicationId = applicationIdLocal
                clientKey = clientKeyLocal
                server = serverLocal

            case "PROD":
                applicationId = applicationIdProd
                clientKey = clientKeyProd
                server = serverProd

            default: Log.message(.error, message: "GEnergy Invalid Runtime.")
        }

        Log.enable(configuration: LoggerUtils.getConfig())
        Log.info?.message("GEnergy - Entry Point")
        Log.message(.info, message: "Parse - Registering DTO - PFObjects")

        PFPreAudit.registerSubclass()
        PFAudit.registerSubclass()
        PFZone.registerSubclass()
        PFRoom.registerSubclass()
        PlugLoad.registerSubclass()

        Log.message(.info, message: "Parse - Initialization - Processing")
        let configuration = ParseClientConfiguration {
            $0.applicationId = self.applicationId
            $0.clientKey = self.clientKey
            $0.server = self.server
            $0.isLocalDatastoreEnabled = true
        }

        Parse.initialize(with: configuration)
        Log.message(.info, message: "Parse - Initialization - Complete")

        GUtils.applicationDocumentsDirectory()

        return true
    }
}


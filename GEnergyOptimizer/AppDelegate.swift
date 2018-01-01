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

    //*** Parse Configuration - Local ***//
//    let applicationId = "NLI214vDqkoFTJSTtIE2xLqMme6Evd0kA1BbJ20S"
//    let clientKey = "lgEhciURXhAjzITTgLUlXAEdiMJyIF4ZBXdwfpUr"
//    let server = "http://localhost:1337/parse"

    //*** Parse Configuration - Test Server ***//
    let applicationId = "47f916f7005d19ddd78a6be6b4bdba3ca49615a0"
    let clientKey = "275302fd8b2b56dca85f127a6123f281b670c787"
    let server = "http://ec2-18-220-200-115.us-east-2.compute.amazonaws.com:80/parse"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Log.enable(configuration: LoggerUtils.getConfig())
        Log.info?.message("GEnergy - Entry Point")
        Log.message(.info, message: "Parse - Registering DTO - PFObjects")

        PreAuditDTO.registerSubclass()
        AuditDTO.registerSubclass()
        ZoneDTO.registerSubclass()
        RoomDTO.registerSubclass()

        Log.message(.info, message: "Parse - Initialization")
        let configuration = ParseClientConfiguration {
            $0.applicationId = self.applicationId
            $0.clientKey = self.clientKey
            $0.server = self.server
            $0.isLocalDatastoreEnabled = true
        }

        Parse.initialize(with: configuration)

        return true
    }
}


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

        setupDefaults()
        registerPSub()
        configureParse()
        GUtils.applicationDocumentsDirectory()
        DropboxClientsManager.setupWithAppKey(Constants.Dropbox.kDBAppKey)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                enableDropboxSettings()
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        return true
    }
}

extension AppDelegate {

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

    private func setupDefaults() {
        var bundlePath = Bundle.main.bundlePath
        bundlePath.append("/Settings.bundle/Root.inApp.plist")

        if let settingsDictionary = NSDictionary(contentsOfFile: bundlePath),
                let preferencesArray = settingsDictionary["PreferenceSpecifiers"] as? NSArray {
            let defaults = UserDefaults.standard
            preferencesArray.forEach { element in
                if let element = element as? NSDictionary, let key = element["Key"] as? String {
                    if let defaultValue = element["DefaultValue"], defaults.object(forKey: key) == nil {
                        defaults.set(defaultValue, forKey: key)
                        Log.message(.error, message: "Set default value \(defaultValue) for \(key)")
                    }
                }
            }
        }
    }

    private func enableDropboxSettings() {
        Settings.dropboxLinkButtonTitle = "Unlink Dropbox"
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response { (response, _) in
                if let account = response {
                    Settings.dropboxAccount = account.name.displayName
                }
            }
        }
    }
}


//
//  HomeViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/30/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger

class LoginViewController: UIViewController {

    @IBOutlet weak var lblAuditIdentifier: UITextField!
    var auditIdentifier: String?
    var state = GEStateController.sharedInstance
    var delegate: HomeListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.message(.info, message: "GEnergy - Home View Loaded")
    }
}

//Mark: - Touch Events
extension LoginViewController {

    //Loads the HomeListViewController ie. the Zones Listing with their specific entry count
    @IBAction func loginButtonPressed(_ sender: Any) {
        auditIdentifier = lblAuditIdentifier.text?.trimmingCharacters(in: .whitespaces)

        if (auditIdentifier == "") {
            GUtils.message(title: "Alert", message: "Empty Audit Identifier", vc: self)
            return
        }

        Log.message(.info, message: "Audit Identifier: \(auditIdentifier!)")

        state.initGEnergyOptimizer(identifier: auditIdentifier!) {
            Log.message(.info, message: "Callback -> initGEnergyOptimizer")
            self.delegate.loadData()
        }

        self.dismiss(animated: true)
    }
}

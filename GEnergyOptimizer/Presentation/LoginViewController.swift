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
    var presenter = HomePresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.message(.info, message: "GEnergy - Login View Loaded")
    }
}

//Mark: - Touch Events
extension LoginViewController {

    @IBAction func loginButtonPressed(_ sender: Any) {
        if let id = lblAuditIdentifier.text?.trimmingCharacters(in: .whitespaces) {
            if (id.isEmpty) {
                GUtils.message(title: "Alert", message: "Empty Audit Identifier", vc: self)
                return
            }

            Log.message(.info, message: "Audit Identifier: \(id)")
            presenter.initGEnergyOptimizer(auditIdentifier: id)
            self.dismiss(animated: true)
        }
    }
}

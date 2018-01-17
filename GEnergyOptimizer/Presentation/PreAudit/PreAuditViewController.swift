//
//  PreAuditViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/24/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Eureka
import Toaster

class PreAuditViewController: GEFormViewController {

    let resource = FileResource.preaudit.rawValue
    let state = GEStateController.sharedInstance
    let presenter = PreAuditPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info?.message("GEnergy - PreAudit View Controller")

        self.form +++ ButtonRow("SAVE") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }

        .onCellSelection { cellOf, rowOf in
            self.saveFormData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadPreAuditForm), name: .loadPreAuditForm, object: nil)

        presenter.loadData()
    }

    override func getBundleResource() -> String! {
        return resource
    }
}

extension PreAuditViewController{
    @objc func loadPreAuditForm() {
        self.loadFormData()
    }

    fileprivate func saveFormData() {
        Log.message(.info, message: "PreAudit - Data Save")

        presenter.saveData(data: self.form.values(), model: super.getFormDTO()) { status in
            if (status) {
                GUtils.message(title: "PreAudit Save", message: "PreAudit Data Save - Successful", vc: self, type: .toast)
                self.navigationController?.popViewController(animated: true)
            } else {
                GUtils.message(title: "PreAudit Save", message: "PreAudit Data Save - Failed", vc: self, type: .toast)
            }
        }
    }

    fileprivate func loadFormData() {
        Log.message(.info, message: "PreAudit - Loading Form Data")

        self.form.setValues(presenter.data)
        self.tableView.reloadData()
    }
}

extension Notification.Name {
    static let loadPreAuditForm = Notification.Name(rawValue: "loadPreAuditForm")
}


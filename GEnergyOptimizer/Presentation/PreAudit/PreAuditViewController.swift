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

class PreAuditViewController: GEFormViewController {

    let resource = "preaudit"
    let state = GEStateController.sharedInstance
    var activeZone: PFZone?

    let presenter = PreAuditPresenter()
    let modelLayer = ModelLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info?.message("GEnergy - PreAudit View Controller")

        // *** Inserting the SAVE Button Row *** //
        self.form +++ ButtonRow("SAVE") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }

        .onCellSelection { cellOf, rowOf in
            self.saveFormData()
        }

        loadFormData()
        presenter.loadData()
    }

    // This holds the bundle reference to Parse //
    override func getBundleResource() -> String! {
        return resource
    }
}

//Mark: - Save Form Data

extension PreAuditViewController {

    // *** Loading the Form Data *** //
    fileprivate func loadFormData() {
        Log.message(.info, message: "PreAudit - Loading Form Data")

        guard let auditDTO = self.state.getPFAudit() else {
            Log.message(.error, message: "Audit DTO Object Unavailable")
            return
        }

        modelLayer.loadPreAudit { source, collection in
            var formData = Dictionary<String, Any?>()
            for (elementId, data) in collection {
                formData[elementId] = data[1]
            }

            Log.message(.warning, message: formData.debugDescription)
            self.form.setValues(formData)
            self.tableView.reloadData()
        }
    }

    // *** Saving the Form Data *** //
    fileprivate func saveFormData() {
        Log.message(.info, message: "PreAudit - Data Save")
        let formData = self.form.values()

        guard let auditDTO = self.state.getPFAudit() else {
            Log.message(.error, message: "Audit DTO Object Unavailable")
            return
        }

        PFPreAuditAPI.sharedInstance.get(objectId: auditDTO.preAudit.objectId!) { status, object in
            if (status) {
                let idToElement = BuilderHelper.mapIdToElements(dto: super.getFormDTO())

                guard let object = object as? PFPreAudit else {
                    Log.message(.error, message: "Guard Failed : PFPreAudit")
                    return
                }

                formData.forEach { tuple in
                    if let value = tuple.value {
                        Log.message(.warning, message: tuple.key.description)
                        Log.message(.warning, message: tuple.value.debugDescription)

                        object.featureData[tuple.key] = [idToElement![tuple.key]?.param, value]
                    }
                }
                PFPreAuditAPI.sharedInstance.save(pfPreAudit: object) {
                    GUtils.message(title: "Parse-Server", message: "PreAudit : Data Saved", vc: self)
                }
            }
        }
    }
}


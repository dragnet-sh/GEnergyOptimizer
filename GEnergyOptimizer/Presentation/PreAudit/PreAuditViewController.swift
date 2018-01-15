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

        guard let preAuditDTO = self.state.getPreAuditDTO() else {
            Log.message(.error, message: "PreAudit DTO Object Unavailable")
            return
        }

        Log.message(.warning, message: preAuditDTO.debugDescription)
        var formData = Dictionary<String, Any?>()
        for (elementId, data) in preAuditDTO.featureData {
           formData[elementId] = data[1]
        }

        Log.message(.warning, message: formData.debugDescription)
        self.form.setValues(formData)
        self.tableView.reloadData()
    }

    // *** Saving the Form Data *** //
    fileprivate func saveFormData() {
        Log.message(.info, message: "PreAudit - Data Save")
        let formData = self.form.values()
        Log.message(.warning, message: formData.debugDescription)

        guard let preAuditDTO = self.state.getPreAuditDTO() else {
            Log.message(.error, message: "PreAudit DTO Object Unavailable")
            return
        }

        let idToElement = BuilderHelper.mapIdToElements(dto: super.getFormDTO())
        Log.message(.warning, message: idToElement.debugDescription)

        formData.forEach { tuple in
            //PreAudit Data Structure to Save
            //***** Id -> (name, value)

            if let value = tuple.value {
                Log.message(.warning, message: tuple.key.description)
                Log.message(.warning, message: tuple.value.debugDescription)

                preAuditDTO.featureData[tuple.key] = [idToElement![tuple.key]?.param, value] //ToDo: Forced Unwrapping - Recipe for disaster
            }
        }

        Log.message(.warning, message: preAuditDTO.debugDescription)

//        self.state.savePreAudit(preAudit: preAuditDTO) {
//            GUtils.message(title: "Parse-Server", message: "PreAudit : Data Saved", vc: self)
//        }
    }
}


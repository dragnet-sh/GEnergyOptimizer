//
//  FeatureViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/8/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Eureka
import CSV

class FeatureViewController: GEFormViewController {

    var activeEZone: EZone?
    var zoneDTO: ZoneDTO?
    let state = GEStateController.sharedInstance

    var documentsDirectoryUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.message(.info, message: "GEnergy - Feature View Controller")

        // *** Inserting the SAVE Button Row *** //
        self.form +++ ButtonRow("SAVE") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }

        .onCellSelection { cellOf, rowOf in
            self.saveFormData()
        }

        self.loadFormData()
    }

    override func getBundleResource() -> String! {
        if let activeEZone = self.activeEZone {
            return String(activeEZone.rawValue).lowercased()
        }
        return "none"
    }
}


//Mark: - Save | Load Form Data

extension FeatureViewController {

    // *** Loading the Form Data *** //
    public func loadFormData() {
        Log.message(.info, message: "Zone Feature - Loading Form Data")

        guard let zoneDTO = self.zoneDTO else {
            Log.message(.error, message: "Zone DTO Object Unavailable")
            return
        }

        Log.message(.warning, message: zoneDTO.debugDescription)
        var formData = Dictionary<String, Any?>()
        for (elementId, data) in zoneDTO.featureData {
            formData[elementId] = data[1]
        }

        Log.message(.warning, message: formData.debugDescription)
        self.form.setValues(formData)
        self.tableView.reloadData()
    }

    // *** Saving the Form Data *** //
    fileprivate func saveFormData() {
        Log.message(.info, message: "Feature - Data Save")
        let formData = self.form.values()
        Log.message(.warning, message: formData.debugDescription)

        guard let zoneDTO = self.zoneDTO else {
            Log.message(.error, message: "Zone DTO Object Unavailable")
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

                zoneDTO.featureData[tuple.key] = [idToElement![tuple.key]?.param, value] //ToDo: Forced Unwrapping - Recipe for disaster
            }
        }

        Log.message(.warning, message: zoneDTO.debugDescription)

        self.state.saveZone(zoneDTO: zoneDTO) {
            GUtils.message(title: "Parse-Server", message: "Zone Feature : Data Saved", vc: self)
        }
    }
}

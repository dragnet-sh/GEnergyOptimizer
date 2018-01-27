//
//  PopEditViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/7/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Presentr
import Eureka

class PopOverViewController: FormViewController {

    var activeHeader: String?
    var activeEditLine: String?
    let presenter = PopOverPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.loadData(vc: self)
        self.buildForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadPopOverDataForm), name: .loadPopOverDataForm, object: nil)

        presenter.loadData(vc: self)
    }
}

extension PopOverViewController {
    func buildForm() {

        //Name Row
        let sectionZoneInfo = Section("GEnergy : Zone Info")
        let nameRow = TextRow(tag: "po-name")
        nameRow.placeholder = "Name"
        sectionZoneInfo.append(nameRow)

        //Appliance Picker Row
        let sectionAppliance = Section("Select : Appliance Type")
        let applianceRow = PickerInputRow<String>(tag: "po-appliance")
        applianceRow.options = EApplianceType.getAllRaw
        sectionAppliance.append(applianceRow)

        //Save Button Row
        let sectionSave = Section()
        let saveRow = ButtonRow(tag: "po-save")
        saveRow.title = "SAVE"
        saveRow.onCellSelection { cellOf, rowOf in
            self.dismiss(animated: true, completion: nil)
            self.saveFormData()
        }
        sectionSave.append(saveRow)

        //Checking the Stack Count for PlugLoad to find if it's the Parent Node or the Child Node
        //For PlugLoad - Only the Child has Appliance Type
        form.append(sectionZoneInfo)
        if (presenter.getCount() == 2) {
            form.append(sectionAppliance)
        }
        form.append(sectionSave)
    }
}


extension PopOverViewController {
    @objc func loadPopOverDataForm() {
        //self.loadFormData()
    }

    fileprivate func saveFormData() {
        Log.message(.info, message: "PopOver - Saving Form Data")

        presenter.saveData(data: self.form.values(), vc: self) { status in
//            if (status) {
//                GUtils.message(title: "Feature Save", message: "Feature Data Save - Successful", vc: self, type: .toast)
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                GUtils.message(title: "Feature Save", message: "Feature Data Save - Failed", vc: self, type: .toast)
//            }
        }
    }

    fileprivate func loadFormData() {
        Log.message(.info, message: "PopOver - Loading Form Data")

//        self.form.setValues(presenter.data)
//        self.tableView.reloadData()
    }
}

extension Notification.Name {
    static let loadPopOverDataForm = Notification.Name(rawValue: "loadPopOverDataForm")
}

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

    var delegate: BasePresenter?
    var action: EAction?
    let presenter = PopOverPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadPopOverDataForm), name: .loadPopOverDataForm, object: nil)

        if (action == EAction.update) {
            presenter.loadData()
        }
    }
}

extension PopOverViewController {
    func buildForm() {

        //Name Row
        let sectionZoneInfo = Section("GEnergy Optimizer : Info")
        let nameRow = TextRow(tag: ETagPO.name.rawValue)
        nameRow.placeholder = "Name"
        nameRow.add(rule: RuleRequired())
        sectionZoneInfo.append(nameRow)

        //Appliance Picker Row
        let sectionAppliance = Section("Select : Appliance Type")
        let applianceRow = PickerInputRow<String>(tag: ETagPO.type.rawValue)
        applianceRow.options = EApplianceType.getAllRaw
        sectionAppliance.append(applianceRow)

        //Save Button Row
        let sectionSave = Section()
        let saveRow = ButtonRow(tag: ETagPO.save.rawValue)
        saveRow.title = "SAVE"
        saveRow.onCellSelection { cellOf, rowOf in
            nameRow.validate()
            applianceRow.validate()

            if (nameRow.isValid && applianceRow.isValid) {

                if let action = self.action {
                    switch action {
                    case .create: self.saveFormData()
                    case .update: self.updateFormData()
                    default: Log.message(.error, message: "Unknown - Action")
                    }
                }

                self.dismiss(animated: true, completion: nil)
            } else { GUtils.message(msg: "Data Incomplete") }

        }
        sectionSave.append(saveRow)

        //Checking the Stack Count for PlugLoad to find if it's the Parent Node or the Child Node
        //For PlugLoad - Only the Child has Appliance Type
        form.append(sectionZoneInfo)
        if (presenter.getCount() == ENode.child) {
            applianceRow.add(rule: RuleRequired())
            form.append(sectionAppliance)
        }
        form.append(sectionSave)
    }
}


extension PopOverViewController {
    @objc func loadPopOverDataForm() {
        self.loadFormData()
    }

    fileprivate func loadFormData() {
        Log.message(.info, message: "PopOver - Loading Form Data")

        self.form.setValues(presenter.data)
        self.tableView.reloadData()
    }

    fileprivate func saveFormData() {
        Log.message(.info, message: "PopOver - Saving Form Data")
        presenter.saveData(data: self.form.values(), vc: self, delegate: delegate!)
    }

    fileprivate func updateFormData() {
        Log.message(.info, message: "PopOver - Updating Form Data")
        presenter.updateData(data: self.form.values(), delegate: delegate!)
    }
}

extension Notification.Name {
    static let loadPopOverDataForm = Notification.Name(rawValue: "loadPopOverDataForm")
}

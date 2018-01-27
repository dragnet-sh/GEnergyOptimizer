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
    var delegate: ZonePresenter?
    let presenter = PopOverPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildForm()
    }
}

extension PopOverViewController {
    func buildForm() {

        //Name Row
        let sectionZoneInfo = Section("GEnergy : Zone Info")
        let nameRow = TextRow(tag: ETagPO.name.rawValue)
        nameRow.placeholder = "Name"
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
            self.dismiss(animated: true, completion: nil)
            self.saveFormData()
        }
        sectionSave.append(saveRow)

        //Checking the Stack Count for PlugLoad to find if it's the Parent Node or the Child Node
        //For PlugLoad - Only the Child has Appliance Type
        form.append(sectionZoneInfo)
        if (presenter.getCount() == ENode.child) {
            form.append(sectionAppliance)
        }
        form.append(sectionSave)
    }
}


extension PopOverViewController {
    fileprivate func saveFormData() {
        Log.message(.info, message: "PopOver - Saving Form Data")
        presenter.saveData(data: self.form.values(), vc: self, delegate: delegate!)
    }
}

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

class PopEditViewController: FormViewController {

    var activeHeader: String?
    var activeEditLine: String?
    let state = StateController.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        let sectionZoneInfo = Section("GEnergy : Zone Info")
        let nameRow = TextRow(tag: "GE-1")
        nameRow.placeholder = "Name"
        sectionZoneInfo.append(nameRow)

        let sectionAppliance = Section("Select : Appliance Type")
        let applianceRow = PickerInputRow<String>(tag: "GE-2")
        applianceRow.options = EApplianceType.getAllRaw
        sectionAppliance.append(applianceRow)

        let sectionSave = Section()
        let saveRow = ButtonRow(tag: "GE-3")
        saveRow.title = "SAVE"
        saveRow.onCellSelection { cellOf, rowOf in
            self.dismiss(animated: true, completion: nil)
        }
        sectionSave.append(saveRow)

        form.append(sectionZoneInfo)
        if (state.getCount(type: EZone.plugload) == 2) {
            form.append(sectionAppliance)
        }
        form.append(sectionSave)
    }
}


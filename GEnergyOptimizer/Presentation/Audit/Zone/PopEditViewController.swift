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
    var pickerDataSource = ["White", "Red", "Green", "Blue"]

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("Something New")
        <<< TextRow() {
            $0.title = "Text Row"
        }

                <<< PickerInputRow<String>("Picker Input Row"){
            $0.title = "Options"
            $0.options = []
            for i in 1...10{
                $0.options.append("option \(i)")
            }
            $0.value = $0.options.first
        }

    }
}


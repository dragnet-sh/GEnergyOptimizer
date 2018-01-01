//
//  PAHomeViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/12/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import Eureka
import CleanroomLogger

class PAHomeViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.message(.info, message: "GEnergy - Pre Audit Home View Controller")

        form +++ Section()
         <<< ButtonRow("Client Detailed Info") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }

         <<< ButtonRow("Room Configuration") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }

        <<< ButtonRow("General Configuration") { (row: ButtonRow) -> Void in
            row.title = row.tag
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

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

class FeatureViewController: GEFormViewController {

    let presenter = FeaturePresenter()
    //Note: Entity Type is to be set as a delegate.
    var entityType: EntityType?

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info?.message("GEnergy - Feature Data View Controller")

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
        notificationCenter.addObserver(self, selector: #selector(self.loadFeatureDataForm), name: .loadFeatureDataForm, object: nil)

        presenter.loadData(vc: self)
    }

    override func dataBelongsTo() -> EntityType {
        if let entityType = entityType {
            return entityType
        } else { Log.message(.error, message: "Entity Type : None"); return EntityType.none }
    }

    override func getBundleResource() -> String! {
        if let entityType = entityType {
            switch entityType {
            case .preaudit: return FileResource.preaudit.rawValue
            case .zone: return presenter.getActiveZone().lowercased()
            default: Log.message(.error, message: "Entity Type : None"); return EntityType.none.rawValue
            }
        } else { Log.message(.error, message: "Entity Type : None"); return EntityType.none.rawValue }
    }
}


//Mark: - Save | Load Form Data
extension FeatureViewController {
    @objc func loadFeatureDataForm() {
        self.loadFormData()
    }

    fileprivate func saveFormData() {
        Log.message(.info, message: "Feature - Data Save")

        presenter.saveData(data: self.form.values(), model: super.getFormDTO(), vc: self) { status in
            if (status) {
                GUtils.message(title: "Feature Save", message: "Feature Data Save - Successful", vc: self, type: .toast)
                self.navigationController?.popViewController(animated: true)
            } else {
                GUtils.message(title: "Feature Save", message: "Feature Data Save - Failed", vc: self, type: .toast)
            }
        }
    }

    fileprivate func loadFormData() {
        Log.message(.info, message: "Feature - Loading Form Data")

        self.form.setValues(presenter.data)
        self.tableView.reloadData()
    }
}

extension Notification.Name {
    static let loadFeatureDataForm = Notification.Name(rawValue: "loadFeatureDataForm")
}

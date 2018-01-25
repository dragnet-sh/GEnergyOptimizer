//
//  ZoneListingViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/3/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import PopupDialog

class ZoneListViewController: UIViewController {

    @IBOutlet weak var lblZoneHeader: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var presenter = ZonePresenter()
    static let cellIdentifier = CellIdentifiers.zone.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()

        Log.message(.info, message: "GEnergy - ZoneList View Controller")
        self.initTableView()
        self.setZoneHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateZoneTableData), name: .updateZoneTableData, object: nil)

        presenter.loadData()
    }
}

//Mark: - Touch Events
extension ZoneListViewController {

    @IBAction func btnAddZonePressed(_ sender: Any) {
        Log.message(.info, message: "Add New Zone")
        let popup = ControllerUtils.getPopEdit(headerLine: "Add Zone") { name in
            if (name.isEmpty) {
                GUtils.message(title: "Alert", message: "Zone Name Cannot be Empty", vc: self, type: .alert)
                return
            }

            if let zone = self.presenter.getActiveZone() {
                self.presenter.createZone(name: name, type: zone)
            }
        }

        self.present(popup, animated: true, completion: nil)
    }
}

//Mark: - Data Source
extension ZoneListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let zone = presenter.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ZoneListViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.text = zone.title

        return cell
    }
}

//Mark: - Delegate Event
extension  ZoneListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let featureViewController = ControllerUtils.fromStoryboard(reference: "FeatureViewController") as! FeatureViewController
        featureViewController.entityType = EntityType.zone
        presenter.setActiveCDZone(cdZone: presenter.data[indexPath.row].cdZone)
        navigationController?.pushViewController(featureViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let zone = self.presenter.data[indexPath.row]
        let actions = ControllerUtils.getTableEditActions(
                delete: { row in self.presenter.deleteZone(guid: zone.guid)},
                edit: { row in
                    let popup = ControllerUtils.getPopEdit(editLine: zone.title, headerLine: "Edit Zone") { name in
                        if self.isNameEmpty(name: name) {return}
                        self.presenter.updateZone(guid: zone.guid, name: name)
                    }
                    self.present(popup, animated: true, completion: nil)
                }
        )

        return actions
    }
}

//Mark: - Helper Methods
extension ZoneListViewController {

    func initTableView() {
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.rowHeight = 60
    }

    func setZoneHeader() {
        if let zone  = presenter.getActiveZone() {
            self.lblZoneHeader.text = "Zone - \(zone)"
        }
    }

    @objc func updateZoneTableData() {
        refreshTableData()
    }

    func refreshTableData() {
        Log.message(.info, message: "Zone List View Controller - Refreshing Table Data !!")
        self.tableView.reloadData()
    }

    fileprivate func isNameEmpty(name: String) -> Bool {
        if (name.isEmpty) {
            GUtils.message(title: "Alert", message: "Room Name Cannot be Empty", vc: self, type: .alert)
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let updateZoneTableData = Notification.Name(rawValue: "updateZoneTableData")
}
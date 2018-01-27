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
import Presentr

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
        Log.message(.info, message: "View Did Load")
        Log.message(.error, message: String(describing: presenter.getCount().rawValue))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateZoneTableData), name: .updateZoneTableData, object: nil)
        Log.message(.error, message: "View Will Appear")
        Log.message(.error, message: String(describing: presenter.getCount().rawValue))

        presenter.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.isMovingFromParentViewController) {
            if (presenter.getActiveZone() == EZone.plugload.rawValue) {
                Log.message(.error, message: "Moving From Parent View Controller")
                Log.message(.error, message: "POP")
                presenter.counter(action: .pop)
            }
        }
    }
}

//Mark: - Touch Events
extension ZoneListViewController {

    @IBAction func btnAddZonePressed(_ sender: Any) {
        Log.message(.info, message: "Add New Zone")

        let vc = ControllerUtils.fromStoryboard(reference: "PresenterModal") as! PopOverViewController
        vc.delegate = self.presenter
        let presenter = Presentr(presentationType: .popup)
        presenter.dismissOnSwipe = true
        customPresentViewController(presenter, viewController: vc, animated: true) {}

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
    //ToDo: Code Review
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        Log.message(.error, message: "Selection Zone List Item")
        Log.message(.error, message: String(describing: presenter.getCount().rawValue))

        if let activeZone = presenter.getActiveZone() {
            switch activeZone {
            case EZone.plugload.rawValue:

                if (presenter.getCount() == .parent) {

                    Log.message(.error, message: "PUSH")
                    presenter.counter(action: .push, dto: presenter.data[indexPath.row])

                    let vc = ControllerUtils.fromStoryboard(reference: "ZoneListViewController") as! ZoneListViewController
                    navigationController?.pushViewController(vc, animated: true)

                } else if (presenter.getCount() == .child) {

                    let vc = ControllerUtils.fromStoryboard(reference: "FeatureViewController") as! FeatureViewController
                    vc.entityType = EntityType.appliances
                    navigationController?.pushViewController(vc, animated: true)

                }

            default:
                let vc = ControllerUtils.fromStoryboard(reference: "FeatureViewController") as! FeatureViewController
                vc.entityType = EntityType.zone
                presenter.setActiveCDZone(cdZone: presenter.data[indexPath.row].cdZone)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let zone = self.presenter.data[indexPath.row]
        let actions = ControllerUtils.getTableEditActions(
                delete: { row in self.presenter.deleteZone(guid: zone.guid)},
                edit: { row in Log.message(.info, message: "Edit - Zone List View Controller")}
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
        self.lblZoneHeader.text = presenter.getZoneHeader()
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
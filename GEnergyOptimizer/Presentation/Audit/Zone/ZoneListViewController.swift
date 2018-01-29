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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateZoneTableData), name: .updateZoneTableData, object: nil)

        presenter.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.isMovingFromParentViewController) {
            if (presenter.getActiveZone() == EZone.plugload.rawValue) {
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

        let dto = presenter.data[indexPath.row]

        func switcher() {

            guard let zone = presenter.getActiveZone() else {
                Log.message(.error, message: "Guard Failed : Get Active Zone")
                return
            }

            if zone == EZone.plugload.rawValue {
                switch presenter.getCount() {
                case .parent:
                    presenter.counter(action: .push, dto: dto)
                    loadZone()
                case .child:
                    loadFeature() { vc in
                        vc.entityType = EntityType.appliances
                    }
                }
            } else {
                loadFeature() { vc in vc.entityType = EntityType.zone }
            }
        }


        func loadFeature(setEntityType:(FeatureViewController)->Void) {
            let vc = ControllerUtils.fromStoryboard(reference: "FeatureViewController") as! FeatureViewController
            setEntityType(vc)
            vc.applianceType = EApplianceType(rawValue: dto.type)

            presenter.setActiveCDZone(cdZone: dto.cdZone)
            navigationController?.pushViewController(vc, animated: true)
        }

        func loadZone() {
            let vc = ControllerUtils.fromStoryboard(reference: "ZoneListViewController") as! ZoneListViewController
            navigationController?.pushViewController(vc, animated: true)
        }

        switcher()
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
            GUtils.message(title: "Alert", msg: "Room Name Cannot be Empty", vc: self, type: .alert)
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let updateZoneTableData = Notification.Name(rawValue: "updateZoneTableData")
}
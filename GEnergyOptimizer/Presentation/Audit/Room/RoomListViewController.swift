//
//  RoomListViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/17/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import PopupDialog

class RoomListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var state = StateController.sharedInstance
    var presenter = RoomPresenter()

    static let cellIdentifier = CellIdentifiers.room.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
        Log.message(.info, message: "GEnergy - RoomList View Controller")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadData()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateRoomTableData), name: .updateRoomTableData, object: nil)
    }
}


//Mark: - Touch Events
extension RoomListViewController {

    @IBAction func addRoomButtonPressed(_ sender: Any) {
        let popup = ControllerUtils.getPopEdit(headerLine: "Add Room") { name in
            if self.isNameEmpty(name: name) {return}
            self.presenter.createRoom(name: name)
        }

        self.present(popup, animated: true, completion: nil)
    }
}

//Mark: - UITableViewDataSource
extension RoomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = presenter.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomListViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.text = room.title

        return cell
    }
}

//Mark: - UITableViewDelegate
extension RoomListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let room = self.presenter.data[indexPath.row]
        let actions = ControllerUtils.getTableEditActions(
                delete: { row in self.presenter.deleteRoom(guid: room.guid) },
                edit: { row in
                    let popup = ControllerUtils.getPopEdit(editLine: room.title, headerLine: "Edit Room") { name in
                        if self.isNameEmpty(name: name) {return}
                        self.presenter.updateRoom(guid: room.guid, name: name)
                    }
                    self.present(popup, animated: true, completion: nil)
                }
        )

        return actions
    }
}

//Mark: - Helper Methods
extension RoomListViewController {

    fileprivate func initTableView() {
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.rowHeight = 60
    }

    @objc func updateRoomTableData() {
        refreshTableData()
    }

    fileprivate func refreshTableData() {
        Log.message(.info, message: "Room List View Controller - Refreshing Table Data !!")
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
    static let updateRoomTableData = Notification.Name(rawValue: "updateRoomTableData")
}

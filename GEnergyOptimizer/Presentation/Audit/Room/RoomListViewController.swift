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
    var state = GEStateController.sharedInstance
    var presenter = RoomPresenter()

    static let cellIdentifier = "roomListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTableView()
        Log.message(.info, message: "GEnergy - RoomList View Controller")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.loadData { source in
            self.tableView.reloadData()
        }
    }
}


//Mark: - Touch Events
extension RoomListViewController {

    //Add Room Button Pressed
    @IBAction func addRoomButtonPressed(_ sender: Any) {
        Log.message(.info, message: "Add New Room")
        let popup = ControllerUtils.getPopEdit() { name in
            if (name.isEmpty) {
                GUtils.message(title: "Alert", message: "Room Name Cannot be Empty", vc: self)
                return
            }
        }

        //Present Dialog
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let actions = ControllerUtils.getTableEditActions(
                delete: { row in Log.message(.info, message: "Delete Action - Clouser Executed")},
                edit: { row in Log.message(.info, message: "Edit Action - Clouser Executed")}
        )

        return actions
    }
}

//Mark: - Helper Methods
extension RoomListViewController {

    func initTableView() {
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.rowHeight = 60
    }
}

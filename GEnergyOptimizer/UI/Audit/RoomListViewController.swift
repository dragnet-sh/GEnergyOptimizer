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

    static let cellIdentifier = "roomListCell"
    
    var activeZone: String?
    var activeEZone: EZone!
    var activeZoneDTO: ZoneDTO?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.rowHeight = 60

        Log.message(.info, message: "GEnergy - RoomList View Controller")


    }

    //Add Room Button Pressed
    @IBAction func addRoomButtonPressed(_ sender: Any) {
        Log.message(.info, message: "Add New Room")
        let popEditViewController = PopEditViewController(nibName: "PopEditViewController", bundle: nil)

        popEditViewController.activeHeader = "Add Room"
        popEditViewController.activeEditLine = ""

        let popup = PopupDialog(viewController: popEditViewController, buttonAlignment: .horizontal, gestureDismissal: true)

        let btnCancel = CancelButton(title: "Cancel", height: 40) {
            //1. Discard the changes
        }
        let btnAdd = DefaultButton(title: "Add", height: 40) {
            Log.message(.info, message: "Value: \(String(describing: popEditViewController.txtEditField.text))")

            //1. Save the updated Value
            let roomName = popEditViewController.txtEditField.text?.trimmingCharacters(in: .whitespaces)
            if (roomName == "") {
                GUtils.message(title: "Alert", message: "Room Name Cannot be Empty", vc: self)
                return
            }

            self.state.initializeRoomDTO(name: roomName!) { status in
                //2. Reload the Table
                if (status == true) {
                    self.tableView!.reloadData()
                } else { Log.message(.error, message: "Room Addition Failed") }
            }
        }
        popup.addButtons([btnCancel, btnAdd])

        //Present Dialog
        self.present(popup, animated: true, completion: nil)

    }
}

//Mark: - UITableViewDataSource
extension RoomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ToDo: Safely UnWrap
        if let roomList = state.getAuditDTO()?.roomCollection {
            Log.message(.info, message: roomList.debugDescription)
            return roomList.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomListViewController.cellIdentifier, for: indexPath)

        //ToDo: Review this section -- Was too tired when wrote this ?? :)
        if let auditDTO = state.getAuditDTO() {

        if let roomPFObject = auditDTO.roomCollection[indexPath.row] as? RoomDTO {
            Log.message(.warning, message: roomPFObject.debugDescription)
            state.getRoom(objectId: roomPFObject.objectId!) { status, object in
                if (status) {
                    guard let room = object as? RoomDTO else {
                        return
                    }
                    cell.textLabel?.text = room.name
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                }
            }
        }
    }


        return cell
    }
}

//Mark: - UITableViewDelegate
extension RoomListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    //ToDo: Maybe the update Logic should be moved on to the Model
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

//        let auditDTO = self.stateController.audit
//        let zoneDTO = auditDTO.zone[self.activeEZone]![indexPath.row]

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            Log.message(.info, message: "Delete Action Being Called !!")
//            auditDTO.zone[self.activeEZone]!.remove(at: indexPath.row)
//
            self.tableView.reloadData()
        }

        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in

//            Log.message(.info, message: zoneDTO.name)
//            Log.message(.info, message: self.activeEZone.rawValue)
            Log.message(.info, message: "Edit Action Being Called !!")

            let popEditViewController = PopEditViewController(nibName: "PopEditViewController", bundle: nil)
            popEditViewController.activeHeader = "Edit Room"
            popEditViewController.activeEditLine = "RoomDTO Name"

            let popup = PopupDialog(viewController: popEditViewController, buttonAlignment: .horizontal, gestureDismissal: true)

            let btnCancel = CancelButton(title: "Cancel", height: 40) {
                //1. Discard the changes
            }
            let btnEdit = DefaultButton(title: "Save", height: 40) {
                Log.message(.info, message: "Value: \(String(describing: popEditViewController.txtEditField.text))")
                //1. Save the updated Value

                let updatedZoneName = popEditViewController.txtEditField.text
                //zoneDTO.name = updatedZoneName!

                //2. Reload the Table
                //self.tableView!.reloadData()
            }
            popup.addButtons([btnCancel, btnEdit])

            //Present Dialog
            self.present(popup, animated: true, completion: nil)
        }

        deleteAction.backgroundColor = UIColor.red
        editAction.backgroundColor = UIColor.green

        return [deleteAction, editAction]
    }
}

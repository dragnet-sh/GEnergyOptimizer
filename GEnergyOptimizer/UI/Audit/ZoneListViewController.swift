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

    var state = GEStateController.sharedInstance

    var activeZone: String?
    var activeEZone: EZone!
    var activeZoneDTO: ZoneDTO?

    weak var delegate: HomeListViewController?

    static let cellIdentifier = "zoneListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.rowHeight = 60

        Log.message(.info, message: "GEnergy - ZoneList View Controller")
        Log.message(.info, message: "Active Zone: \(String(describing: activeZone))")

        //Set via Delegate from previous VC
        self.lblZoneHeader.text = "Zone - \(String(describing: activeZone!))"

        //Converting Raw Zone to EZone
        guard let eZone = EZone(rawValue: activeZone!) else {
            Log.message(.error, message: "Unable to Map Zone - EZone")
            return
        }
        self.activeEZone = eZone
    }

    //Add Zone Button Pressed
    @IBAction func btnAddZonePressed(_ sender: Any) {
        Log.message(.info, message: "Add New Zone")
        let popEditViewController = PopEditViewController(nibName: "PopEditViewController", bundle: nil)

        popEditViewController.activeHeader = "Add Zone - \(self.activeEZone.rawValue)"
        popEditViewController.activeEditLine = ""

        let popup = PopupDialog(viewController: popEditViewController, buttonAlignment: .horizontal, gestureDismissal: true)

        let btnCancel = CancelButton(title: "Cancel", height: 40) {
            //1. Discard the changes
        }
        let btnAdd = DefaultButton(title: "Add", height: 40) {
            Log.message(.info, message: "Value: \(String(describing: popEditViewController.txtEditField.text))")

            //1. Save the updated Value

            let zoneName = popEditViewController.txtEditField.text?.trimmingCharacters(in: .whitespaces)
            if (zoneName == "") {
                GUtils.message(title: "Alert", message: "Zone Name Cannot be Empty", vc: self)
                return
            }

            self.state.initializeZoneDTO(name: zoneName!, type: self.activeEZone.rawValue) { status in
                //2. Reload the Table
                if (status == true) {
                    self.tableView!.reloadData()
                    self.delegate!.stateController.loadData()
                    self.delegate!.tableView!.reloadData()
                } else { Log.message(.error, message: "Zone Addition Failed") }
            }
        }
        popup.addButtons([btnCancel, btnAdd])

        //Present Dialog
        self.present(popup, animated: true, completion: nil)
    }
}

//Mark: - UITableViewDataSource
extension ZoneListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ToDo: Safely UnWrap
        if let zoneList = state.getAuditDTO()?.zoneCollection[activeEZone.rawValue] {
            Log.message(.info, message: zoneList.debugDescription)
            return zoneList.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZoneListViewController.cellIdentifier, for: indexPath)

        //ToDo: Review this section -- Was too tired when wrote this ?? :) -- Every Row is Quering the database need to change this !!
        if let auditDTO = state.getAuditDTO() {
           if let zoneCollection = auditDTO.zoneCollection[activeEZone.rawValue] {
               if let zonePFObject = zoneCollection[indexPath.row] as? ZoneDTO {
                   Log.message(.warning, message: zonePFObject.debugDescription)
                   state.getZone(objectId: zonePFObject.objectId!) { status, object in
                       if (status) {
                           guard let zone = object as? ZoneDTO else {
                               return
                           }
                           cell.textLabel?.text = zone.name
                           cell.textLabel?.adjustsFontSizeToFitWidth = true
                       }
                   }
               }
           }
        }

        return cell
    }
}


//Mark: - UITableViewDelegate
extension  ZoneListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let featureViewController = ControllerUtils.fromStoryboard(reference: String(describing: FeatureViewController.self)) as? FeatureViewController
        featureViewController!.activeEZone = self.activeEZone

        if let auditDTO = state.getAuditDTO() {
            if let zoneCollection = auditDTO.zoneCollection[self.activeEZone.rawValue] {
                if let zoneDTO = zoneCollection[indexPath.row] as? ZoneDTO {
                    Log.message(.warning, message: "Zone DTO PFObject")
                    Log.message(.warning, message: zoneDTO.objectId.debugDescription)

                    guard let objectId = zoneDTO.objectId else {
                        return
                    }

                    state.getZone(objectId: objectId) { status, pfObject in
                        Log.message(.warning, message: pfObject.debugDescription)
                        featureViewController!.zoneDTO = pfObject as! ZoneDTO //ToDo: Forced Unwrapping
                        featureViewController!.loadFormData()
                    }
                }
            }
        }

        navigationController?.pushViewController(featureViewController!, animated: true)
    }
    
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
            if let delegate = self.delegate {
                delegate.loadData()
            }
        }

        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in

//            Log.message(.info, message: zoneDTO.name)
//            Log.message(.info, message: self.activeEZone.rawValue)
            Log.message(.info, message: "Edit Action Being Called !!")

            let popEditViewController = PopEditViewController(nibName: "PopEditViewController", bundle: nil)
            popEditViewController.activeHeader = "Edit Zone - \(self.activeEZone.rawValue)"
            popEditViewController.activeEditLine = "ZoneDTO Name"

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

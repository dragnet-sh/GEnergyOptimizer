//
//  HomeListViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/30/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger

class HomeListViewController: UIViewController, UINavigationBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var stateController = StateController.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = 110
        tableView.tableFooterView = UIView()

        HomeListCell.register(with: tableView)

        Log.message(.info, message: "GEnergy - HomeList View Controller")

        // *** Showing the Login View *** //
        self.present(getHomeViewController(), animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    @IBAction func btnLogout(_ sender: Any) {
        self.present(getHomeViewController(), animated: true)
    }
}


//Mark: - Touch Events
extension HomeListViewController {
    
    @IBAction func roomButtonPressed(_ sender: Any) {
        let roomListViewController = ControllerUtils.fromStoryboard(reference: String(describing: RoomListViewController.self)) as! RoomListViewController
        navigationController?.pushViewController(roomListViewController, animated: true)
    }

    @IBAction func preAuditButtonPressed(_ sender: Any) {
        let preAuditViewController = ControllerUtils.fromStoryboard(reference: String(describing: PreAuditViewController.self)) as! PreAuditViewController
        navigationController?.pushViewController(preAuditViewController, animated: true)
    }
}


//Mark: - UITableViewDataSource
extension HomeListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.homeListDataModel!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return HomeListCell.dequeue(from: tableView, for: indexPath, with: stateController.homeListDataModel![indexPath.item])
    }
}


//Mark: - UITableViewDelegate
extension HomeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedZone = stateController.homeListDataModel![indexPath.item]
        Log.message(.info, message: (selectedZone.auditZone?.debugDescription)!)

        let zoneListViewController = ControllerUtils.fromStoryboard(reference: String(describing: ZoneListViewController.self)) as! ZoneListViewController
        zoneListViewController.activeZone = selectedZone.auditZone!
        zoneListViewController.delegate = self

        navigationController?.pushViewController(zoneListViewController, animated: true)
    }
}


//Mark: - Helper Method
extension HomeListViewController {
    func loadData() {
        self.stateController.loadData()
        if (self.isViewLoaded) {
            self.tableView.reloadData()
        }
    }

    func getHomeViewController() -> LoginViewController {
        let homeListViewController = ControllerUtils.fromStoryboard(reference: String(describing: "Main"), vc: "HomeViewController") as! LoginViewController
        homeListViewController.delegate = self
        return homeListViewController
    }
}


//Mark: - Data Model | State Controller
extension HomeListViewController {

    // Note: Nested Class in used so that the global namespace is not polluted

    // ## To Refresh the Table Data ##
    //1. Update the Model
    //2. Call TableView - ReloadData

    class StateController {

        static let sharedInstance = StateController()
        var state = GEStateController.sharedInstance

        var homeListDataModel: [HomeListDataModel]?

        init() {
            Log.message(.info, message: "GEnergy - HomeListViewController - StateController - Init")
            loadData()
        }

        //ToDo: Create a protocol that all StateController adhere to so that these utility load methods will be consistent
        func loadData() {
            Log.message(.info, message: "Loading Zone Collection Count")

            var countHVAC = 0
            var countLighting = 0
            var countPlugLoad = 0

            if let auditDTO = state.getAuditDTO() {
                countHVAC = auditDTO.zoneCollection[EZone.hvac.rawValue]!.count
                countLighting = auditDTO.zoneCollection[EZone.lighting.rawValue]!.count
                countPlugLoad = auditDTO.zoneCollection[EZone.plugload.rawValue]!.count
            }

            homeListDataModel = [
                HomeListDataModel(auditZone: EZone.hvac.rawValue, count: countHVAC.description),
                HomeListDataModel(auditZone: EZone.lighting.rawValue, count: countLighting.description),
                HomeListDataModel(auditZone: EZone.plugload.rawValue, count: countPlugLoad.description)
            ]
        }
    }

    //ToDo: Need to work on this Data Model
    class HomeListDataModel {
        var auditZone: String?
        var count: String?

        init(auditZone: String, count: String) {
            self.auditZone = auditZone
            self.count = count
        }
    }
}

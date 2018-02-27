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
    fileprivate var presenter: HomePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        Log.message(.info, message: "GEnergy - HomeList View Controller")
        self.initTableView()
        self.present(getLoginViewController(), animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter = HomePresenter()
        presenter.loadData { source in
            Log.message(.info, message: "Fake - Data Loaded Form \(source)")
            self.tableView.reloadData() //ToDo : Use Notification Center Instead
        }
    }
}


//Mark: - Touch Events
extension HomeListViewController {

    // *** Loading the Room View Controller *** //
    @IBAction func roomButtonPressed(_ sender: Any) {
        let vc = ControllerUtils.fromStoryboard(reference: "RoomListViewController") as! RoomListViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    // *** Loading the PreAudit View Controller *** //
    @IBAction func preAuditButtonPressed(_ sender: Any) {
        let featureViewController = ControllerUtils.fromStoryboard(reference: "FeatureViewController") as! FeatureViewController
        featureViewController.entityType = EntityType.preaudit
        navigationController?.pushViewController(featureViewController, animated: true)
    }

    // *** Loading the Login View Controller post Logout *** //
    @IBAction func btnLogout(_ sender: Any) {
        self.present(getLoginViewController(), animated: true)
    }

    // *** Loading the Energy Calculator *** //
    @IBAction func btnCalculate(_ sender: Any) {
        Log.message(.warning, message: "Calling Energy Calculation !!")
        let energy = GEnergy()
        energy.calculate()
    }
}


//Mark: - Data Source
extension HomeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return presenter.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let zone = presenter.data[indexPath.row]
         let cell = HomeListCell.dequeue(from: tableView, for: indexPath, with: zone)

         return cell
    }
}


//Mark: - Delegate Events
extension HomeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedZone = presenter.data[indexPath.item].auditZone {
            presenter.setActiveZone(zone: selectedZone)

            let vc = ControllerUtils.fromStoryboard(reference: "ZoneListViewController") as! ZoneListViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//Mark: - Helper Method
extension HomeListViewController {

    // *** Show up the Login Screen on-top of Home List View Controller *** //
    func getLoginViewController() -> LoginViewController {
        let vc = ControllerUtils.fromStoryboard(reference: "Main", vc: "LoginViewController") as! LoginViewController
        return vc
    }

    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 130
        tableView.backgroundColor = .white

        HomeListCell.register(with: tableView)
    }
}




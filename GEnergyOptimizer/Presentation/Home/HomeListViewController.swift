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

        tableView.dataSource = self
        tableView.delegate = self
        //tableView.tableFooterView = UIView()

        HomeListCell.register(with: tableView)

        // *** Showing the Login View *** //
        self.present(getLoginViewController(), animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter = HomePresenter()
        presenter.loadData { source in
            Log.message(.info, message: "Fake - Data Loaded Form \(source)")
            self.tableView.reloadData()
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
        let vc = ControllerUtils.fromStoryboard(reference: "PreAuditViewController") as! PreAuditViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    // *** Loading the Login View Controller post Logout *** //
    @IBAction func btnLogout(_ sender: Any) {
        self.present(getLoginViewController(), animated: true)
    }
}


//Mark: - UITableViewDataSource
extension HomeListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return presenter.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let zone = presenter.data[indexPath.row]
         let cell = HomeListCell.dequeue(from: tableView, for: indexPath, with: zone)
         return cell
    }
}


//Mark: - UITableViewDelegate
extension HomeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedZone = presenter.data[indexPath.item]

        Log.message(.info, message: (selectedZone.auditZone?.debugDescription)!)

        let vc = ControllerUtils.fromStoryboard(reference: "ZoneListViewController") as! ZoneListViewController
        vc.activeZone = selectedZone.auditZone!
        vc.delegate = self

        navigationController?.pushViewController(vc, animated: true)
    }
}


//Mark: - Helper Method
extension HomeListViewController {

    // *** Show up the Login Screen on-top of Home List View Controller *** //
    func getLoginViewController() -> LoginViewController {
        let vc = ControllerUtils.fromStoryboard(reference: "Main", vc: "LoginViewController") as! LoginViewController
        vc.delegate = self

        return vc
    }
}




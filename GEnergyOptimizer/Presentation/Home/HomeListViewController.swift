//
//  HomeListViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/30/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import InAppSettingsKit
import SwiftyDropbox

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
    @IBAction func uploadButtonPressed(_ sender: Any) {
        DropBoxUploader().upload(data: "FooBar,sam\r\nOne,smith\r\nTwo,Dony\r\nThree,Brasco".data(using: String.Encoding.utf8)!, finished: {
            Log.message(.warning, message: "Finished Uploading - Call Back")
        })
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
        presenter.calculate()
    }
    
    @IBAction func btnBackupAudit(_ sender: Any) {
        Log.message(.warning, message: "Backing up Audit Data")
        presenter.backup()
    }

    // *** Loading the Settings *** //
    @IBAction func btnSettings(_ sender: Any) {

        let settingsViewController = IASKAppSettingsViewController()
        settingsViewController.delegate = self
        settingsViewController.showCreditsFooter = false
        settingsViewController.neverShowPrivacySettings = true

        let controller = UINavigationController(rootViewController: settingsViewController)
        controller.modalTransitionStyle = .coverVertical

        self.present(controller, animated: true, completion: nil)
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

//Mark: - IASSettingsDelegate
extension HomeListViewController: IASKSettingsDelegate {
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        print("IASK Delegate Active")
        sender.dismiss(animated: true, completion: nil)
    }

    // *** Gets called from the Settings ***
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!) {
        if specifier.key() == "dropbox_link_pref" {

            Log.message(.error, message: UserDefaults.standard.debugDescription)

            if DropboxClientsManager.authorizedClient == nil {
                sender.dismiss(animated: true) { [weak self] in
                    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                            controller: self,
                            openURL: { UIApplication.shared.openURL($0) })
                }
            } else {
                DropboxClientsManager.unlinkClients()
                Settings.dropboxLinkButtonTitle = "Connect to Dropbox"
                Settings.dropboxAccount = ""
            }
        }
    }
}



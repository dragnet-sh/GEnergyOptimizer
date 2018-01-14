//
//  HomeListCell.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 11/30/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit

class HomeListCell: UITableViewCell {

    @IBOutlet weak var zoneLabel: UILabel?
    @IBOutlet weak var counterLabel: UILabel?

    func configureWithData(data: HomeListDTO) {
        self.zoneLabel!.text = data.auditZone
        self.counterLabel!.text = data.count
    }
}

//Mark: - Helper Methods

extension HomeListCell {
    public static var cellId: String {
        return String(describing: self)
    }

    public static var bundle: Bundle {
        return Bundle(for: HomeListCell.self)
    }

    public static var nib: UINib {
        return UINib(nibName: HomeListCell.cellId, bundle: HomeListCell.bundle)
    }

    public static func register(with tableView: UITableView) {
        tableView.register(HomeListCell.nib, forCellReuseIdentifier: HomeListCell.cellId)
    }

    public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with homeListDTO: HomeListDTO) -> HomeListCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCell.cellId, for: indexPath) as! HomeListCell
        cell.configureWithData(data: homeListDTO)

        return cell
    }
}


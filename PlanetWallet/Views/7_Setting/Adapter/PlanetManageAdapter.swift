//
//  PlanetManageAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 28/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class PlanetManageAdapter: AbsTableViewAdapter<Planet>{
    
    private let cellID = "planetcell"
    
    override init(_ tableView: UITableView, _ dataSoruce: Array<Planet>) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: PlanetCell.self, cellId: cellID)
    }
    
    override func createCell(data: Planet, position: Int) -> UITableViewCell? {
        return tableView?.dequeueReusableCell(withIdentifier: cellID)
    }
    
    override func bindData(cell: UITableViewCell, data: Planet, position: Int) {
        setCellHeight(height: 100)
        let planetCell = cell as! PlanetCell
        if let address = data.address {
            planetCell.addressLb.text = Utils.shared.trimAddress(address)
            planetCell.planetView.data = address
        }
    
        if let isHide = data.hide {
            if isHide == "Y" {
                planetCell.containerView.alpha = 0.5
            }
            else if isHide == "N" {
                planetCell.containerView.alpha = 1.0
            }
        }
        
        planetCell.planetNameLb.text = data.name
        planetCell.coinLb.text = data.symbol
    }
    
}

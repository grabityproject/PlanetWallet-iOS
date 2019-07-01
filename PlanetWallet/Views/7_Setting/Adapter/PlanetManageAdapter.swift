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
        planetCell.addressLb.text = data.address
        planetCell.planetNameLb.text = data.name
        planetCell.coinLb.text = data.symbol
        planetCell.planetView.data = data.address!
    }
    
}

//
//  RecentSearchAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RecentSearchAdapter: AbsTableViewAdapter<Planet> {
    
    private let contactCellID = "recentContactCell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<Planet> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: ContactCell.self, cellId: contactCellID)
    }
    
    override func createCell(data: Planet, position: Int) -> UITableViewCell? {
        if let table = tableView{
            return table.dequeueReusableCell(withIdentifier: contactCellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Planet, position: Int) {
        
        setCellHeight(height: 70)
        
        let item = cell as! ContactCell
        if let address = data.address {
            item.planetView.data = address
            item.addressLb.text = Utils.shared.trimAddress(address)
        }
        
        item.isRecentSearch = true
        item.planetName.text = data.name
    }
}


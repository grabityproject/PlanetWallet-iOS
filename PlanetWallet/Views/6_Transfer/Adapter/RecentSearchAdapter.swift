//
//  RecentSearchAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol RecentSearchAdapterDelegate {
    func didTouchedItem(_ planet: Planet)
    func didTouchedDelete(_ planet: Planet)
}

class RecentSearchAdapter: AbsTableViewAdapter<Planet> {
    
    var delegate: RecentSearchAdapterDelegate?
    
    private let contactCellID = "recentContactCell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<Planet> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: ContactCell.self, cellId: contactCellID)
    }
    
    override func createCell(data: Planet, position: Int) -> UITableViewCell? {
        if let table = tableView{
            setCellHeight(height: 70)
            return table.dequeueReusableCell(withIdentifier: contactCellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Planet, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        let item = cell as! ContactCell
        if let address = data.address {
            item.planetView.data = address
            item.addressLb.text = Utils.shared.trimAddress(address)
        }
        item.delegate = self
        item.isRecentSearch = true
        item.planetName.text = data.name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTouchedItem(dataSource[indexPath.row])
    }
}

extension RecentSearchAdapter: ContactCellDelegate {
    func didTouchedDelete(indexPath: IndexPath) {
        delegate?.didTouchedDelete(dataSource[indexPath.row])
    }
}

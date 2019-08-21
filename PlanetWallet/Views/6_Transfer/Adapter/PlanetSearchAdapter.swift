//
//  PlanetSearchAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 25/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol PlanetSearchAdapterDelegate {
    func didTouchedPlanet(_ planet: Planet)
}

class PlanetSearchAdapter: AbsTableViewAdapter<Planet> {

    var delegate: PlanetSearchAdapterDelegate?
    
    private let contactCellID = "contactCell"
    private let contactAddressCellID = "contractAddressCell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<Planet> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: ContactCell.self, cellId: contactCellID)
        registerCell(cellClass: ContactAddrCell.self, cellId: contactAddressCellID)
    }
    
    override func createCell(data: Planet, position: Int) -> UITableViewCell? {
        if let table = tableView{
            if( data.name == nil ){
                return table.dequeueReusableCell(withIdentifier: contactAddressCellID)
            }else{
                return table.dequeueReusableCell(withIdentifier: contactCellID)
            }
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Planet, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        if( data.name == nil ){
            let item = cell as! ContactAddrCell
            item.addressLb.text = data.address
            item.addressLb.setColoredAddress()
            
            if let coinType = data.coinType {
                if coinType == CoinType.BTC.coinType {
                    item.iconImgView.image = ThemeManager.currentTheme().transferBTCImg
                }
                else if coinType == CoinType.ETH.coinType {
                    item.iconImgView.image = ThemeManager.currentTheme().transferETHImg
                }
            }
        }else {
            let item = cell as! ContactCell
            if let address = data.address {
                item.planetView.data = address
                item.addressLb.text = Utils.shared.trimAddress(address)
            }
            item.planetName.text = data.name
            item.isRecentSearch = false
        }
        
        
        setCellHeight(height: 85)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTouchedPlanet(dataSource[indexPath.row])
    }
}

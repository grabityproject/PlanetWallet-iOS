//
//  ETHCoinDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MainETHAdapter: AbsTableViewAdapter<MainItem> {
    
    public let ethCellID = "ETHCoinCell"
    
    override init(_ tableView: UITableView, _ dataSoruce: Array<MainItem>) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: ETHCoinCell.self, cellId: ethCellID)
    }
    
    //MARK: - TableView Datasource
    override func createCell(data: MainItem, position: Int) -> UITableViewCell? {
        guard let table = tableView else { return nil }
        return table.dequeueReusableCell(withIdentifier: ethCellID)
    }
    
    override func bindData(cell: UITableViewCell, data: MainItem, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        setCellHeight(height: 70)
        
        if let cell = cell as? ETHCoinCell {
            
            print("cell Come in this place")
            
            cell.balanceLb.text = CoinNumberFormatter.full.toMaxUnit(balance: data.getBalance(), item: data)
            cell.coinLb.text = data.symbol
            cell.currencyLb.text = "";
            
            if let img_path = data.img_path{
                if data.getCoinType() == CoinType.ETH.coinType {
                    cell.coinIconImgView.image = UIImage(named:img_path )
                } else {
                    cell.coinIconImgView.loadImageWithPath(Route.URL(img_path))
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
    }
}

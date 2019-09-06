//
//  ETHCoinDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MainETHAdapter: AbsTableViewAdapter<MainItem> {
    
    public let ethCellID = "ethereumCoinCell"
    
    override init(_ tableView: UITableView, _ dataSoruce: Array<MainItem>) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: ETHCoinCell.self, cellId: ethCellID)
    }
    
    //MARK: - TableView Datasource
    override func createCell(data: MainItem, position: Int) -> UITableViewCell? {
        guard let table = tableView else { return nil }
        setCellHeight(height: 70)
        
        if data.getCoinType() == CoinType.ERC20.coinType ||
            data.getCoinType() == CoinType.ETH.coinType
        {
            return table.dequeueReusableCell(withIdentifier: ethCellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: MainItem, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        if data.getCoinType() == CoinType.ERC20.coinType {
            let erc20Cell = cell as? ETHCoinCell
            erc20Cell?.erc20 = data as? ERC20
        }
        else if data.getCoinType() == CoinType.ETH.coinType {
            let ethCell = cell as? ETHCoinCell
            ethCell?.eth = data as? ETH
        }
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
//        findAllViews(view: cell, theme: ThemeManager.currentTheme())
//        print("willDisplay : \(indexPath.row)")
//
//        let data = dataSource[indexPath.row]
//
//        if data.getCoinType() == CoinType.ERC20.coinType {
//            let erc20Cell = cell as? ETHCoinCell
//            erc20Cell?.erc20 = data as? ERC20
//        }
//        else if data.getCoinType() == CoinType.ETH.coinType {
//            let ethCell = cell as? ETHCoinCell
//            ethCell?.eth = data as? ETH
//        }
//    }
}

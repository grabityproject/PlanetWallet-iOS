//
//  ETHCoinDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class mainTableDataSource: NSObject, UITableViewDataSource {
    
    public let ethCellID = "ethereumCoinCell"
    public let btcCellID = "btcTransactionHistoryCell"

    var coinList: [MainItem]?
    
    override init() {
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = coinList else { return 0}
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let list = coinList else { return UITableViewCell() }
        let coin = list[indexPath.row]
        
        if type(of: coin) == ERC20.self {
            let cell = tableView.dequeueReusableCell(withIdentifier: ethCellID, for: indexPath) as! ETHCoinCell
            cell.erc20 = coin as! ERC20
            return cell
        }
        else if type(of: coin) == BTC.self {
            let cell = tableView.dequeueReusableCell(withIdentifier: btcCellID, for: indexPath) as! BTCTransactionCell
            //TODO: - Binding
            return cell
        }
        else {
            return UITableViewCell()
        }
        
    }
}

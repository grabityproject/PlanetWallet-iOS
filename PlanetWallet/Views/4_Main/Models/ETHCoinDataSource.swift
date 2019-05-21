//
//  ETHCoinDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

struct Coin {
    
}

class ETHCoinDataSource: NSObject, UITableViewDataSource {
    
    public let cellID = "ethereumCoinCell"
    var coinList: [Coin] = []
    var delegate: ETHCoinCellDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ETHCoinCell
        cell.delegate = self.delegate
        
        return cell
    }
}

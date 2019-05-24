//
//  BTCHistoryDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

struct BTCTransaction {
    
}

class BTCTransactionDataSource: NSObject, UITableViewDataSource {
    let cellID = "btcTransactionHistoryCell"
    
    var transactionList: [BTCTransaction] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BTCTransactionCell
        cell.backgroundColor = .clear
        
        return cell
    }
    
}

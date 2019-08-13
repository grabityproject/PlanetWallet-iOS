//
//  TxAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 13/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TxAdapter: AbsTableViewAdapter<Tx> {
    
    let cellID:String = "txcell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<Tx> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: BTCTransactionCell.self, cellId: cellID)
    }
    
    override func createCell(data: Tx, position: Int) -> UITableViewCell? {
        if let table = tableView{
            return table.dequeueReusableCell(withIdentifier: cellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Tx, position: Int) {
        super.bindData(cell: cell, data: data, position: position)

        if let txCell = cell as? BTCTransactionCell {
            txCell.amountLb.text = data.amount
            txCell.planetNameLb.text = data.status
        }
    }

}

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
        registerCell(cellClass: TransactionCell.self, cellId: cellID)
    }
    
    override func createCell(data: Tx, position: Int) -> UITableViewCell? {
        if let table = tableView{
            setCellHeight(height: 70)
            
            return table.dequeueReusableCell(withIdentifier: cellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Tx, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        cell.backgroundColor = .clear
        
        guard let txCell = cell as? TransactionCell,
            let amount = data.amount,
            let symbol = data.symbol,
            let decimalStr = data.decimals,
            let decimals = Int(decimalStr) else { return }

        txCell.symbolLb.text = symbol
        
        var formattedAmount = ""
        
        if let maxUnitBalance = CoinNumberFormatter.short.convertUnit(balance: amount, from: 0, to: decimals) {
            formattedAmount = maxUnitBalance
        }
        
        guard let txStatus = data.status, let txDirection = data.type else { return }
        
        if txStatus == "pending" {
            txCell.statusLb.text = "Pending"
            txCell.directionImgView.image = ThemeManager.currentTheme().pendingImg
            if txDirection == "received" {
//                txCell.amountLb.textColor = UIColor(red: 0, green: 226, blue: 145)
                txCell.amountLb.text = formattedAmount
            }
            else {
                txCell.amountLb.text = "-" + formattedAmount
            }
        }
        else if txStatus == "confirmed" {
            txCell.amountLb.text = formattedAmount
            txCell.statusLb.text = "Receive"
            if txDirection == "received" {
                txCell.directionImgView.image = UIImage(named: "imageBtcDiscrease")
                txCell.amountLb.textColor = UIColor(red: 0, green: 226, blue: 145)
                txCell.statusLb.text = "Received"
                txCell.amountLb.text = formattedAmount
            }
            else {
                txCell.directionImgView.image = UIImage(named: "imgeaBtcIncrease")
                txCell.statusLb.text = "Sent"
                txCell.amountLb.text = "-" + formattedAmount
            }
        }
    }
}

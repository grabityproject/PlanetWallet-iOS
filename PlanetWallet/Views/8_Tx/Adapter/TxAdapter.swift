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
    
    var selectedPlanet: Planet?
//    var txStatus: TxStatus = .PENDING(direction: .RECEIVED)
    var txStatus: TxStatus?

    override init(_ tableView:UITableView,_ dataSoruce:Array<Tx> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: TransactionCell.self, cellId: cellID)
    }
    
    override func createCell(data: Tx, position: Int) -> UITableViewCell? {
        if let table = tableView{
            return table.dequeueReusableCell(withIdentifier: cellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: Tx, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        setCellHeight(height: 70)
        cell.backgroundColor = .clear
        
        guard let selectedPlanet = selectedPlanet,
            let txCell = cell as? TransactionCell,
            let amount = data.amount,
            let symbol = data.symbol,
            let decimalStr = data.decimals,
            let decimals = Int(decimalStr) else { return }

        txCell.symbolLb.text = symbol
        
        self.txStatus = TxStatus(currentPlanet: selectedPlanet, tx: data)

        var formattedAmount = ""
        
        if let maxUnitBalance = CoinNumberFormatter.short.convertUnit(balance: amount, from: 0, to: decimals) {
            formattedAmount = maxUnitBalance
        }
        
        guard let results = txStatus?.status, let direction = txStatus?.direction else { return }
        
        if results == TxResults.PENDING {
            txCell.statusLb.text = "Pending"
            txCell.directionImgView.image = ThemeManager.currentTheme().pendingImg
            if direction == .RECEIVED {
                txCell.amountLb.textColor = .green
                txCell.amountLb.text = formattedAmount
            }
            else {
                txCell.amountLb.text = "-" + formattedAmount
            }
        }
        else if results == TxResults.CONFIRMED {
            txCell.amountLb.text = formattedAmount
            txCell.statusLb.text = "Receive"
            if direction == .RECEIVED {
                txCell.directionImgView.image = UIImage(named: "imageBtcDiscrease")
                txCell.amountLb.textColor = .green
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

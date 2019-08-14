//
//  TxAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 13/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

enum TxStatus {
    case PENDING(direction: TxDirection)
    case CONFIRMED(direction: TxDirection)
}

enum TxDirection {
    case RECEIVED
    case SENT
}

class TxAdapter: AbsTableViewAdapter<Tx> {
    
    let cellID:String = "txcell"
    
    var selectedPlanet: Planet?
    
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

        setCellHeight(height: 70)
        cell.backgroundColor = .clear
        
        guard let selectedPlanet = selectedPlanet,
            let coinType = selectedPlanet.coinType,
            let txCell = cell as? TransactionCell,
            let amount = data.amount,
            let symbol = data.symbol else { return }
        
        var formattedAmount = ""
        var txStatus: TxStatus = .PENDING(direction: .RECEIVED)
        
        if coinType == CoinType.BTC.coinType {
            if let shortBitStr = CoinNumberFormatter.short.toBitString(satoshi: amount) {
                formattedAmount = shortBitStr
            }
        }
        else if coinType == CoinType.ETH.coinType {
            if let shortEtherStr = CoinNumberFormatter.short.toEthString(wei: amount) {
                formattedAmount = shortEtherStr
            }
        }
        
        txCell.symbolLb.text = symbol
        
        if let selectedPlanetAddr = selectedPlanet.address, let toAddress = data.to, let fromAddress = data.from, let status = data.status {
            if selectedPlanetAddr == toAddress {
                if status == "pending" {
                    txStatus = .PENDING(direction: .RECEIVED)
                }
                else {
                    txStatus = .CONFIRMED(direction: .RECEIVED)
                }
            }
            else if selectedPlanetAddr == fromAddress {
                if status == "pending" {
                    txStatus = .PENDING(direction: .SENT)
                }
                else {
                    txStatus = .CONFIRMED(direction: .SENT)
                }
            }
        }
        
        switch txStatus {
        case .PENDING(let direction):
            txCell.statusLb.text = "Pending"
            txCell.directionImgView.image = ThemeManager.currentTheme().pendingImg//UIImage(named: "imageTxListPendingGray")
            if direction == .RECEIVED {
                txCell.amountLb.textColor = .green
                txCell.amountLb.text = formattedAmount
            }
            else {
//                txCell.amountLb.textColor = .black
                txCell.amountLb.text = "-" + formattedAmount
            }
        case .CONFIRMED(let direction):
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
//                txCell.amountLb.textColor = .black
                txCell.statusLb.text = "Sent"
                txCell.amountLb.text = "-" + formattedAmount
            }
        }
        
    }

}

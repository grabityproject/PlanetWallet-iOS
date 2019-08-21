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

        setCellHeight(height: 70)
        cell.backgroundColor = .clear
        
        guard let selectedPlanet = selectedPlanet,
            let txCell = cell as? TransactionCell,
            let symbol = data.symbol else { return }

        txCell.symbolLb.text = symbol
        
        self.txStatus = TxStatus(currentPlanet: selectedPlanet, tx: data)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        guard let selectedPlanet = selectedPlanet,
            let coinType = selectedPlanet.coinType,
            let txCell = cell as? TransactionCell,
            let amount = dataSource[indexPath.row].amount else { return }//txList[indexPath.row]
        
        var formattedAmount = ""
        
        //TODO: - ERC20 format
        if coinType == CoinType.BTC.coinType {
            if let shortBitStr = CoinNumberFormatter.short.toMaxUnit(balance: amount, coinType: CoinType.BTC) {
                formattedAmount = shortBitStr
            }
        }
        else if coinType == CoinType.ETH.coinType {
            if let shortEtherStr = CoinNumberFormatter.short.toMaxUnit(balance: amount, coinType: CoinType.ETH) {
                formattedAmount = shortEtherStr
            }
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

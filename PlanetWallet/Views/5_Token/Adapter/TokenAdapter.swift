//
//  TokenAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 25/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TokenAdapter: AbsTableViewAdapter<ERC20>, TokenCellDelegate {
    
    let cellID:String = "tokencell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<ERC20> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: TokenCell.self, cellId: cellID)
    }
    
    override func createCell(data: ERC20, position: Int) -> UITableViewCell? {
        if let table = tableView{
            return table.dequeueReusableCell(withIdentifier: cellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: ERC20, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        
        setCellHeight(height: 70)
        
        let tokenCell = cell as! TokenCell
        tokenCell.delegate = self
        
        tokenCell.nameLb.text = data.name
        tokenCell.iconImgView.downloaded(from: Route.URL( data.img_path! ))
        if dataSource[position].hide == "N" {
            tokenCell.checkedImgView.isHidden = false
        }
        else {
            tokenCell.checkedImgView.isHidden = true
        }
    }

    func didSelected(indexPath: IndexPath) {
        dataSource[indexPath.row].hide = dataSource[indexPath.row].hide == "Y" ? "N" : "Y"
        tableView(self.tableView!, didSelectRowAt: indexPath)
    }
}

class ERC20Cell: UITableViewCell{
    
    
    
}

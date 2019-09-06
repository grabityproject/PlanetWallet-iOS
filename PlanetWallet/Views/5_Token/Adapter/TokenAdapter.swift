//
//  TokenAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 25/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TokenAdapter: AbsTableViewAdapter<MainItem>, TokenCellDelegate {
    
    let cellID:String = "tokencell"
    
    override init(_ tableView:UITableView,_ dataSoruce:Array<MainItem> ) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: TokenCell.self, cellId: cellID)
    }
    
    override func createCell(data: MainItem, position: Int) -> UITableViewCell? {
        if let table = tableView{
            setCellHeight(height: 70)
            return table.dequeueReusableCell(withIdentifier: cellID)
        }
        return nil
    }
    
    override func bindData(cell: UITableViewCell, data: MainItem, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        let tokenCell = cell as! TokenCell
        tokenCell.delegate = self
        
        tokenCell.symbolLb.text = data.symbol
        tokenCell.fullNameLb.text = data.name
        tokenCell.iconImgView.loadImageWithPath(Route.URL( data.img_path! ))
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


//
//  BoardAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 18/09/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BoardAdapter: AbsTableViewAdapter<Board>{
    
    private let cellID = "noticecell"
    public var boardCategory = BoardController.Category.ANNOUNCEMENTS
    
    override init(_ tableView: UITableView, _ dataSoruce: Array<Board>) {
        super.init(tableView, dataSoruce)
        registerCell(cellClass: NoticeCell.self, cellId: cellID)
    }
    
    override func createCell(data: Board, position: Int) -> UITableViewCell? {
        
        setCellHeight(height: boardCategory.cellHeight())
        return tableView?.dequeueReusableCell(withIdentifier: cellID)
    }
    
    override func bindData(cell: UITableViewCell, data: Board, position: Int) {
        super.bindData(cell: cell, data: data, position: position)
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
        
        let boardCell = cell as! NoticeCell
        
        boardCell.titleLb.text = data.subject
        
        if let date = data.created_at {
            boardCell.dateLb.text = Utils.shared.changeDateFormat(date: date,
                                                             beforFormat: .BASIC,
                                                             afterFormat: .yyyyMMdd)
        }
        
        if boardCategory == .WALLET {
            boardCell.dateLb.isHidden = true
        }
    }
    
}

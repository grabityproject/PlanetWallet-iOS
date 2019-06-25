//
//  AbsTableViewAdapter.swift
//  PlanetWallet
//
//  Created by grabity on 25/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class AbsTableViewAdapter<T> : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource:Array<T> = [T]()
    var tableView: UITableView?
    var cellHeight: CGFloat = 10
    
    var delegates:Array<UITableViewDelegate> = [UITableViewDelegate]()
    
    init(_ tableView:UITableView,_ dataSoruce:Array<T> ) {
        super.init()
        self.tableView = tableView
        self.dataSource = dataSoruce
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        dataSetNotify(dataSoruce)
    }
    
    func registerCell( cellClass:AnyClass ,cellId:String ){
        if let table = tableView{
            table.register(cellClass, forCellReuseIdentifier: cellId)
        }
    }
    
    func setCellHeight( height:CGFloat ){
        cellHeight = height
    }
    
    func bindData( cell:UITableViewCell, data:T, position:Int ){
    }

    func createCell( data:T, position:Int )->UITableViewCell?{
        return nil
    }

    func dataSetNotify(_ dataSoruce:Array<T> ){
        self.dataSource = dataSoruce
        tableView?.reloadData()
    }
    
    private func onCreateCell( cell:UITableViewCell, indexPath:IndexPath ){
        bindData(cell: cell, data: dataSource[indexPath.row], position: indexPath.row )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = createCell( data: dataSource[indexPath.row], position: indexPath.row ){
            onCreateCell(cell:cell, indexPath: indexPath)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegates.forEach { (delegate) in
            delegate.tableView!(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        delegates.forEach { (delegate) in
            delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        delegates.forEach { (delegate) in
            delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegates.forEach { (delegate) in
            delegate.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
}

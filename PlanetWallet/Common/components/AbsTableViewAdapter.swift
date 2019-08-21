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
    
    func findAllViews( view:UIView, theme:Theme ){
        
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in
                
                findAllViews(view: v, theme: theme)
            }
        }
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
            print(delegate)
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
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegates.forEach { (delegate) in
            delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidZoom?(scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidScroll?(scrollView)
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidScrollToTop?(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewWillBeginDragging?(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }

    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewWillBeginDecelerating?(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidEndScrollingAnimation?(scrollView)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        delegates.forEach { (delegate) in
             _ = delegate.scrollViewShouldScrollToTop?(scrollView)
        }
        return false
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegates.forEach { (delegate) in
            delegate.scrollViewWillBeginZooming?(scrollView, with: view)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegates.forEach { (delegate) in
            delegate.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegates.forEach { (delegate) in
            delegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
}

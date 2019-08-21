//
//  FooterViewComponent.swift
//  PlanetWallet
//
//  Created by 박상은 on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

protocol RefreshDelegate {
    func onRefresh()
}

class RefreshAnimationComponent: ViewComponent {

    var delegate:RefreshDelegate?
    
    var statusHeight: CGFloat { return Utils.shared.statusBarHeight() }
    var refreshHeight:CGFloat{
        if refreshControl == nil { return 0 }
        return refreshControl.isRefreshing ? 60 : 0
    }
    
    var loadingViewWrapper:UIView!
    var tableView:UITableView!
    var refreshControl: UIRefreshControl!
    var animationView : AnimationView!
    
    override func viewMapping() {
        tableView = findViewById("table_main") as? UITableView
        loadingViewWrapper = findViewById("group_main_loading")
    }
    
    override func controller(_ controller: PlanetWalletViewController) {
        super.controller(controller)
        self.viewMapping()
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = UIColor.clear
        
        tableView.addSubview(refreshControl!)
        self.loadCustomRefreshContents()
        
        delegate = controller as? RefreshDelegate
    }
    
    private func refresh(){
        self.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in }
        delegate?.onRefresh()
    }
    
    public func refreshed(){
       self.hideRefreshContents()
    }
    
    private func loadCustomRefreshContents() {
        animationView = AnimationView()
        animationView.frame = loadingViewWrapper.bounds
        loadingViewWrapper.addSubview(animationView)
        animationView.animation = Animation.named("refreshLoading")
        animationView.contentMode = .scaleAspectFit
    }
    
    private func hideRefreshContents() {
        if refreshControl.isRefreshing && tableView.isDragging == false {
            self.animationView.stop()
            self.refreshControl.endRefreshing()
            self.loadingViewWrapper.alpha = 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            let offsetY = ( scrollView.contentOffset.y + self.statusHeight + scrollView.contentInset.top )
            if( offsetY < -60 ){
                refresh()
            }else{
                hideRefreshContents()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        let offsetY = ( scrollView.contentOffset.y + self.statusHeight + scrollView.contentInset.top )
        
        if( offsetY > 0){
            hideRefreshContents()
        } else {
            let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
            let pullRatio = max(pullDistance, 0.0) / 60.0

            if( pullRatio < 1.0 ){
                loadingViewWrapper.alpha = pullRatio
            } else {
                loadingViewWrapper.alpha = 1
            }
            
            if( !self.animationView.isAnimationPlaying )
            {
                animationView.currentProgress = pullRatio - floor(pullRatio)
            }
        }
    }
    
}

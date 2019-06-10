//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class MainController: PlanetWalletViewController {

    var statusHeight: CGFloat { return Utils.shared.statusBarHeight() }
    
    var universe: Universe = Universe(type: .ETH, name: "defaults", coinList: [ERCToken()], transactions: nil) {
        didSet {
            self.updateUniverse()
        }
    }
    
    @IBOutlet var bgPlanetContainer: UIView!
    @IBOutlet var bgPlanetContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet var bgPlanetView: PlanetView!
    @IBOutlet var darkDimGradientView: GradientView!
    @IBOutlet var lightDimGradientView: GradientView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var footerView: MainTableFooter!
    
    @IBOutlet weak var labelError: UIButton!
    
    @IBOutlet var naviBar: NavigationBar!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var loadingViewWrapper: UIView!
    
    var dataSources: [UITableViewDataSource] = []
    let ethDataSource = ETHCoinDataSource()
    let btcDataSource = BTCTransactionDataSource()
    
    var topMenuLauncher: TopMenuLauncher?
    var bottomMenuLauncher: BottomMenuLauncher?
    
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var btnBottomLauncher: PWImageView!
    @IBOutlet var bottomBlurView: UIView!
    
    let rippleAnimationView = RippleAnimationView()
    
    override func viewDidLayoutSubviews() {
        if( bottomMenuLauncher == nil ){
            bottomMenuLauncher = BottomMenuLauncher(controller: self, trigger: bottomMenu, clickTrigger: btnBottomLauncher)
            bottomMenuLauncher?.labelError = labelError;
        }
        
        bgPlanetContainer.frame = CGRect(x: ( SCREEN_WIDTH - SCREEN_WIDTH * 410.0 / 375.0 ) / 2.0,
                                         y: planetView.frame.height * 1.0 / 4.0 - SCREEN_WIDTH * 170.0 / 375.0 ,
                                         width: SCREEN_WIDTH * 410.0 / 375.0,
                                         height: SCREEN_WIDTH * 410.0 / 375.0)
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rippleAnimationView.dismiss()
        
        self.topMenuLauncher = TopMenuLauncher(triggerView: naviBar.rightImageView)
        topMenuLauncher?.delegate = self
        
        if( ThemeManager.currentTheme() == .DARK ){
            darkDimGradientView.isHidden = false
            lightDimGradientView.isHidden = true
        }else{
            darkDimGradientView.isHidden = true
            lightDimGradientView.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        configureTableView()
        createRippleView()

        naviBar.backgroundView.alpha = 0
    }
    
    override func setData() {
        super.setData()
        
        self.fetchData { (_) in }
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        topMenuLauncher?.setTheme(theme)
        bottomMenuLauncher?.setTheme(theme)
        footerView.setTheme(theme)
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedCopyAddr(_ sender: UIButton) {
        
    }
    
    @IBAction func didTouchedError(_ sender: UIButton) {
        //go to back up Mnemonic or Private key
        //TODO : - navigate page
        let segue = Keys.Segue.MAIN_TO_PINCODECERTIFICATION
        sendAction(segue: segue, userInfo: ["segue": segue])
    }
    
    //MARK: - Private
    private func fetchData(completion: @escaping (Bool) -> Void) {
        //do something
        completion(true)
    }
    
    private func configureTableView() {
        //Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl!)
        self.loadCustomRefreshContents()
        
        //TableView
        tableView.register(ETHCoinCell.self, forCellReuseIdentifier: ethDataSource.cellID)
        tableView.register(BTCTransactionCell.self, forCellReuseIdentifier: btcDataSource.cellID)

        dataSources = [ethDataSource, btcDataSource]
        tableView.dataSource = dataSources[0]
        tableView.contentInset = UIEdgeInsets(top: naviBar.frame.height - Utils.shared.statusBarHeight(),
                                              left: 0, bottom: 130, right: 0)
        
        //Header, Footer
        planetView.frame = CGRect(x: ( SCREEN_WIDTH - (SCREEN_WIDTH*170.0/375.0) ) / 2.0, y: planetView.frame.origin.y, width: (SCREEN_WIDTH*170.0/375.0), height: (SCREEN_WIDTH*170.0/375.0))
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 330.0/375.0)
        footerView.delegate = self
    }
    
    private func createRippleView() {

        self.rippleAnimationView.frame = CGRect(x: 31,
                                                y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0,
                                                width: 0,
                                                height: 0)
        self.view.addSubview(rippleAnimationView)
    }
    
    var animationView : AnimationView!
    var isAnimation : Bool {
        return animationView.isAnimationPlaying
    }
    
    private func loadCustomRefreshContents() {
        loadingViewWrapper.frame = CGRect(x: loadingViewWrapper.frame.origin.x, y: naviBar.frame.height + Utils.shared.statusBarHeight(), width: loadingViewWrapper.frame.width, height: loadingViewWrapper.frame.height)
        animationView = AnimationView()
        animationView.frame = CGRect(x: 0, y: 0, width: loadingViewWrapper.frame.width, height: loadingViewWrapper.frame.height)
        loadingViewWrapper.addSubview(animationView)
        animationView.animation = Animation.named("refreshLoading")
        animationView.contentMode = .scaleAspectFit
    }
    
    private func updateUniverse() {
        let type = universe.type
        switch type {
        case .ETH:
            ethDataSource.coinList = universe.coinList
            tableView.dataSource = dataSources[0]
            naviBar.title = "ETH"
            footerView.isEthUniverse = true
            footerView.isHidden = false
        case .BTC:
            btcDataSource.transactionList = universe.transactionList
            tableView.dataSource = dataSources[1]
            naviBar.title = "BTC"
            footerView.isEthUniverse = false
            footerView.isHidden = !btcDataSource.transactionList!.isEmpty
        }
        
        tableView.reloadData()
    }
}

extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        switch sender {
        case .LEFT:
            rippleAnimationView.show { (isSuccess) in
                if isSuccess {
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: nil)
                }
            }
        case .RIGHT:
            print("touched navibar right item")
        }
    }
}


extension MainController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let refreshControl = refreshControl else { return }
        if ( refreshControl.isRefreshing && self.isAnimation == false ) {
            //refresh control animation
            
            self.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in }
            
            self.fetchData { (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.animationView.stop()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = ( tableView.contentOffset.y + self.statusHeight + scrollView.contentInset.top )
        
        if( tableView.contentOffset.y  >  planetView.frame.origin.y + planetView.frame.height/3.0 - naviBar.frame.height  ){
            let startPosition = (  planetView.frame.origin.y + planetView.frame.height/3.0 + self.statusHeight + scrollView.contentInset.top - naviBar.frame.height)
            let moveRange = planetView.frame.height*2.0/3.0
            let movePosition = offsetY - startPosition
            naviBar.backgroundView.alpha = movePosition / moveRange
        }else{
            naviBar.backgroundView.alpha = 0
        }
        print("offset Y : \(offsetY), \(scrollView.contentInset.top)")
        if( offsetY > 0){
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            bgPlanetContainer.frame.origin = CGPoint(x: bgPlanetContainer.frame.origin.x,
                                                     y: bgPlanetContainerTopConstraint.constant - offsetY)
            
            if ( refreshControl.isRefreshing && self.isAnimation == true ) {
                let pullRatio = offsetY / loadingViewWrapper.frame.height
                if pullRatio < 1.0 {
                    loadingViewWrapper.alpha = 1 - pullRatio
                }
                else {
                    loadingViewWrapper.alpha = 0
                    self.animationView.stop()
                    self.refreshControl.endRefreshing()
                }
            }
            
        } else {
            
            print("-----------------offset Y : \(offsetY), \(scrollView.contentInset.top)")
            let scale = 1.0 - offsetY/(self.view.frame.width/2.0)*0.5
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            
            let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
            let pullRatio = max(pullDistance, 0.0) / 60.0
            
            if( pullRatio < 1.0 ){
                if isAnimation == false {
                    loadingViewWrapper.alpha = 0
                }
                else {
                    loadingViewWrapper.alpha = pullRatio
                }
            } else {
                loadingViewWrapper.alpha = 1
            }
            
            if( refreshControl.isRefreshing ){
                self.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in }
            }else{
                animationView.currentProgress = pullRatio - floor(pullRatio)
            }
            
        }
    }

}

extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

extension MainController: TopMenuLauncherDelegate {
    func didSelectedUniverse(_ universe: Universe) {
        self.universe = universe
        
    }
}

extension MainController: MainTableFooterDelegate {
    func didTouchedManageToken() {
        performSegue(withIdentifier: Keys.Segue.MAIN_TO_TOKEN_ADD, sender: nil)
    }
}

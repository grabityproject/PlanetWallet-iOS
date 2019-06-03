//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

enum UniverseType {
    case ETH
    case BTC
    
    func description() -> String {
        switch self {
        case .ETH:      return "ETH Universe"
        case .BTC:      return "BTC Universe"
        }
    }
}

class MainController: PlanetWalletViewController {

    var universe: Universe = Universe(type: .ETH, name: "defaults", coinList: [Coin()], transactions: nil) {
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
    
    @IBOutlet weak var labelError: UILabel!
    
    @IBOutlet var naviBar: NavigationBar!
    var rippleView: UIView!
    var refreshControl: UIRefreshControl!
    let refreshContents = RefreshContents()
    
    var dataSources: [UITableViewDataSource] = []
    let ethDataSource = ETHCoinDataSource()
    let btcDataSource = BTCTransactionDataSource()
    
    var topMenuLauncher: TopMenuLauncher?
    var bottomMenuLauncher: BottomMenuLauncher?
    
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var btnBottomLauncher: PWImageView!
    @IBOutlet var bottomBlurView: UIView!
    
    
    override func viewDidLayoutSubviews() {
        if( bottomMenuLauncher == nil ){
            bottomMenuLauncher = BottomMenuLauncher(controller: self, trigger: bottomMenu, clickTrigger: btnBottomLauncher)
            bottomMenuLauncher?.labelError = labelError;
        }
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Ripple animation transition
        UIView.animate(withDuration: 0.4, animations: {
            self.rippleView.backgroundColor = self.settingTheme.backgroundColor
            self.rippleView.alpha = 0
            self.rippleView.layer.cornerRadius = 0
            self.rippleView.bounds = CGRect(x: 25, y: 25, width: 0, height: 0)
        })
        
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
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.5)
        footerView.delegate = self
    }
    
    private func createRippleView() {

        self.rippleView = UIView(frame: CGRect(x: 31,
                                               y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0,
                                               width: 0,
                                               height: 0))
        rippleView.alpha = 0
        rippleView.backgroundColor = settingTheme.backgroundColor
        rippleView.layer.cornerRadius = 0
        rippleView.layer.masksToBounds = true
        self.view.addSubview(rippleView)
    }
    
    private func loadCustomRefreshContents() {
        refreshContents.frame = refreshControl.bounds
        refreshContents.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        refreshControl.addSubview(refreshContents)
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
            //Ripple animation transition
            UIView.animate(withDuration: 0.4, animations: {
                self.rippleView.alpha = 1
                let rippleViewMaxRadius = self.view.bounds.height * 2.0 * 1.4
                self.rippleView.layer.cornerRadius = rippleViewMaxRadius / 2
                self.rippleView.bounds = CGRect(x: 31,
                                                y: self.naviBar.leftImageView.frame.origin.y + self.naviBar.leftImageView.frame.height/2.0,
                                                width: rippleViewMaxRadius,
                                                height: rippleViewMaxRadius)
            }) { (isSuccess) in
                if isSuccess {
                    //perform segue
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
        if ( refreshControl.isRefreshing && refreshContents.isAnimating == false ) {
            //refresh control animation
            refreshContents.playAnimation()
            self.fetchData { (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.refreshContents.stopAnimation()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = tableView.contentOffset.y
        
        if offsetY < 0 {
            // update background planet view scale
            naviBar.backgroundView.alpha = 0
            let scale = 1 + ( ( -offsetY ) * 5 / bgPlanetContainer.frame.height)
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            
            
            // update refresh control
            let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
            let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0
            refreshContents.playAnimation(with: pullRatio)
        }
        else {
            bgPlanetContainer.frame.origin = CGPoint(x: bgPlanetContainer.frame.origin.x,
                                                     y: bgPlanetContainerTopConstraint.constant - offsetY)
            
            let start = planetView.frame.origin.y + planetView.height/3.0 - naviBar.HEIGHT
            let end =  planetView.frame.origin.y + planetView.height - naviBar.HEIGHT
            let moveRange = end - start
            let current = ( offsetY - start ) > 0 ? offsetY - start : 0
            let alpha = current/moveRange
            
            
            if( current > moveRange ){
                naviBar.backgroundView.alpha = 1.0
            }else{
                naviBar.backgroundView.alpha = alpha
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

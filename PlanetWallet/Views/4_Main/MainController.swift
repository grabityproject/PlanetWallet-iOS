//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class MainController: PlanetWalletViewController{

    var statusHeight: CGFloat { return Utils.shared.statusBarHeight() }
    
    var planet: Planet?
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelError: PWButton!
    
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var footerView: FooterView!
    @IBOutlet var bottomPanelComponent: BottomPanelComponent!
    
    var refreshComponent:RefreshAnimationComponent!
    var topMenuLauncher: TopMenuLauncher!
    var bottomMenuLauncher: BottomMenuLauncher!
    let rippleAnimationView = RippleAnimationView()
    
    private var mainAdapter: MainETHAdapter?
    private var txAdapter: TxAdapter?
    
    override func viewDidLayoutSubviews() {
        
        if topMenuLauncher == nil {
            self.topMenuLauncher = TopMenuLauncher(triggerView: naviBar.rightImageView)
            topMenuLauncher?.delegate = self
            topMenuLauncher?.planetList = PlanetStore.shared.list("", false)
        }
        
        if bottomMenuLauncher == nil {
            bottomMenuLauncher = BottomMenuLauncher(controller: self,
                                                    trigger: bottomPanelComponent,
                                                    clickTrigger: bottomPanelComponent.btnNext)
            bottomMenuLauncher?.labelError = labelError
            bottomMenuLauncher?.planet = planet
            bottomMenuLauncher?.bottomPanelComponent = bottomPanelComponent
        }
        
    }
    
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData { (_) in }
        
        self.initBackupAlertView()
        rippleAnimationView.dismiss()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        NodeService.shared.delegate = self
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        topMenuLauncher?.setTheme(theme)
        bottomMenuLauncher?.setTheme(theme)
        footerView.setTheme(theme)
        headerView.setTheme(theme)
    }

    //MARK: - IBAction
    @IBAction func didTouchedError(_ sender: UIButton) {
        if let planet = planet//, let type = planet.coinType
        {
            let segue = Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            sendAction(segue: segue, userInfo: [Keys.UserInfo.fromSegue: segue,
                                                Keys.UserInfo.planet: planet])
        }
        
    }
    
    @IBAction func unwindToMainController(segue:UIStoryboardSegue) { }
    
    //MARK: - Private
    private func fetchData(completion: @escaping (Bool) -> Void) {
        let planetList = PlanetStore.shared.list("", false)
        topMenuLauncher?.planetList = planetList
        
        // set selected planet
        if let keyId:String = Utils.shared.getDefaults(for: Keys.Userdefaults.SELECTED_PLANET){
            if let planet = PlanetStore.shared.get(keyId){
                self.planet = planet
            }else{
                self.planet = planetList.first
            }
        }else {
            self.planet = planetList.first
        }
        
        updatePlanet()
    }
    
    
    private func initBackupAlertView() {
        if let planet = planet, let type = planet.coinType, let pathIdx = planet.pathIndex
        {
            if pathIdx >= 0 {//Generate Planet
                labelError.isHidden = false
                
                if CoinType.BTC.coinType == type && UserDefaults.standard.bool(forKey: Keys.Userdefaults.BACKUP_MNEMONIC_BTC) {
                    labelError.isHidden = true
                }
                else if CoinType.ETH.coinType == type && UserDefaults.standard.bool(forKey: Keys.Userdefaults.BACKUP_MNEMONIC_ETH) {
                    labelError.isHidden = true
                }
            }
            else { //Import Planet
                labelError.isHidden = true
            }
        }
    }
    
    private func configureTableView() {
        
        tableView.contentInset = UIEdgeInsets(top: naviBar.frame.height - Utils.shared.statusBarHeight(),
                                              left: 0, bottom: 130, right: 0)
        
        refreshComponent = RefreshAnimationComponent()
        refreshComponent.controller(self)
        
        headerView.controller(self)
        headerView.refreshComponent = refreshComponent
        
        footerView.controller(self)

    }
    
    private func createRippleView() {
        self.rippleAnimationView.frame = CGRect(x: 31,
                                                y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0,
                                                width: 0,
                                                height: 0)
        self.view.addSubview(rippleAnimationView)
    }
  
    
    private func updatePlanet() {
        
        if let planet = planet, let coinType = planet.coinType {
            
            
            Utils.shared.setDefaults(for: Keys.Userdefaults.SELECTED_PLANET, value: planet.keyId ?? "" )
            
            if CoinType.of(coinType).coinType == CoinType.BTC.coinType {
                
                txAdapter = TxAdapter(tableView, [Tx]())
                txAdapter?.delegates.append(self)
                
            }else if CoinType.of(coinType).coinType == CoinType.ETH.coinType {
                
                if let keyId = planet.keyId, let ethAddr = planet.address{
                    planet.items = ERC20Store.shared.list(keyId, false)
                    planet.items?.insert(
                        ETH(keyId, balance: planet.balance ?? "0", address: ethAddr),
                        at: 0)
                }

                mainAdapter = MainETHAdapter(tableView, planet.items ?? [MainItem]() )
                mainAdapter?.delegates.append(self)
                
            }
            
            headerView.planet = planet
            footerView.planet = planet
            bottomMenuLauncher?.planet = planet
            bottomPanelComponent.setPlanet(planet)
            
            self.initBackupAlertView()

            NodeService.shared.getBalance(planet)
            NodeService.shared.getMainList(planet)
        }
    }

}

extension MainController: RefreshDelegate{
    func onRefresh() {
        SyncManager.shared.syncPlanet(self)
        if let planet = planet{
            NodeService.shared.getBalance(planet)
            NodeService.shared.getMainList(planet)
        }
    }
}


//MARK: - SyncDelegate
extension MainController: SyncDelegate {
    func sync(_ syncType: SyncType, didSyncComplete complete: Bool, isUpdate: Bool) {
        
    }
}

//MARK: - NavigationBarDelegate
extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            rippleAnimationView.show { (isSuccess) in
                if isSuccess {
                    guard let planet = self.planet else { return }
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: [Keys.UserInfo.planet: planet])
                }
            }
        }
    }
}


//MARK: - UITableViewDelegate
extension MainController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedPlanet = planet, let coinType = selectedPlanet.coinType {
            
            if coinType == CoinType.BTC.coinType {
                
                if let tx = txAdapter?.dataSource[indexPath.row]{
                    sendAction(segue: Keys.Segue.MAIN_To_DETAIL_TX, userInfo: [Keys.UserInfo.planet : selectedPlanet,
                                                                               Keys.UserInfo.transaction : tx])
                }
                
            }
            else if coinType == CoinType.ETH.coinType || coinType == CoinType.ERC20.coinType {

                if let item = mainAdapter?.dataSource[indexPath.row] {
                    sendAction(segue: Keys.Segue.MAIN_TO_TX_LIST,
                               userInfo: [Keys.UserInfo.mainItem: ( ( item is ERC20 )  ? item : nil ) as Any,
                                          Keys.UserInfo.planet : selectedPlanet])
                }
              
            }
        }
        
    }
}

//MARK: - UIScrollViewDelegate
extension MainController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.scrollViewDidScroll(scrollView)
        if let refreshComponent = refreshComponent{
            refreshComponent.scrollViewDidScroll(scrollView)
        }
    }
}

//MARK: - TopMenuLauncherDelegate
extension MainController: TopMenuLauncherDelegate {
    func didSelected(planet: Planet) {
        self.planet = planet
        updatePlanet()
    }
    
    func didSelectedFooter() {
        topMenuLauncher?.handleDismiss {
            let segueID = Keys.Segue.MAIN_TO_WALLET_ADD
            self.sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
        }
    }
}

extension MainController:NodeServiceDelegate{
    
    func onBalance(_ planet: Planet, _ balance: String) {
        if let planet = self.planet{
            planet.balance = balance
            bottomMenuLauncher?.planet = planet
            bottomPanelComponent.setPlanet(planet)
        }
    }
    
    func onTokenBalance(_ planet: Planet, _ tokenList: [MainItem]) {
        print("onTokenBalance")

        mainAdapter = MainETHAdapter(tableView, tokenList)
        mainAdapter?.delegates.append(self)
        footerView.updateUI()
        
        refreshComponent.refreshed()
    }
    
    func onTxList(_ planet: Planet, _ txList: [Tx]) {
        print("onTxList")
        
        txAdapter = TxAdapter(tableView, txList)
        txAdapter?.selectedPlanet = planet
        txAdapter?.delegates.append(self)
        footerView.updateUI()
        
        refreshComponent.refreshed()
    }
    
}

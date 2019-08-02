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
    
    var planet: Planet?
    
    @IBOutlet var bgPlanetContainer: UIView!
    @IBOutlet var bgPlanetView: PlanetView!
    @IBOutlet var darkDimGradientView: GradientView!
    @IBOutlet var lightDimGradientView: GradientView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var footerView: MainTableFooter!
    @IBOutlet var addressLb: PWLabel!
    @IBOutlet var planetNameLb: PWLabel!
    private var mainAdapter: MainAdapter?
    
    @IBOutlet weak var labelError: PWButton!
    
    @IBOutlet var naviBar: NavigationBar!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var loadingViewWrapper: UIView!
    
//    let dataSource = mainTableDataSource()
    
    var topMenuLauncher: TopMenuLauncher?
    var bottomMenuLauncher: BottomMenuLauncher?
    var bottomMenuTokenView: BottomMenuTokenView?
    
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var btnBottomLauncher: PWImageView!
    @IBOutlet var bottomMenuBalanceLb: PWLabel!
    @IBOutlet var bottomMenuCoinTypeLb: PWLabel!
    @IBOutlet var bottomMenuPlanetView: PlanetView!
    @IBOutlet var bottomMenuNameLb: PWLabel!
    @IBOutlet var bottomMenuBlurView: PWBlurView!
    
    let rippleAnimationView = RippleAnimationView()
    var animationView : AnimationView!
    var isAnimation : Bool {
        return animationView.isAnimationPlaying
    }

    private var isScrollingOnSyncing = false
    private var isSyncing = false
    
    override func viewDidLayoutSubviews() {
        
        if topMenuLauncher == nil {
            self.topMenuLauncher = TopMenuLauncher(triggerView: naviBar.rightImageView)
            topMenuLauncher?.delegate = self
            topMenuLauncher?.planetList = PlanetStore.shared.list("", false)
        }
        
        if bottomMenuLauncher == nil {
            bottomMenuLauncher = BottomMenuLauncher(controller: self,
                                                    trigger: bottomMenu,
                                                    clickTrigger: btnBottomLauncher,
                                                    delegate: self)
            bottomMenuLauncher?.labelError = labelError
            bottomMenuLauncher?.planet = planet
            
            bottomMenuTokenView = BottomMenuTokenView()
            bottomMenuTokenView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            bottomMenuTokenView?.delegate = self
            self.view.addSubview(bottomMenuTokenView!)
        }
    }
    
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData { (_) in }
        
        self.initBackupAlertView()
        
        
        rippleAnimationView.dismiss()
        
        if( ThemeManager.currentTheme() == .DARK ){
            darkDimGradientView.isHidden = false
            lightDimGradientView.isHidden = true
            bottomMenuBlurView.setTheme(.DARK)
        }else{
            darkDimGradientView.isHidden = true
            lightDimGradientView.isHidden = false
            bottomMenuBlurView.setTheme(.LIGHT)
        }

        if let items = planet?.items {
            mainAdapter?.dataSetNotify(items)
        }
//        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideRefreshContents()
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
        mainAdapter = MainAdapter(tableView, [MainItem]())
        mainAdapter?.delegates.append(self)
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        topMenuLauncher?.setTheme(theme)
        bottomMenuLauncher?.setTheme(theme)
        footerView.setTheme(theme)
    }

    //MARK: - IBAction
    @IBAction func didTouchedCopyAddr(_ sender: UIButton) {
        if let addr = self.planet?.address {
            Utils.shared.copyToClipboard(addr)
            showCopyToast()
        }
    }
    
    @IBAction func didTouchedError(_ sender: UIButton) {
        if let planet = planet, let type = planet.coinType
        {
            if CoinType.BTC.coinType == type {
                Utils.shared.setDefaults(for: Keys.Userdefaults.BACKUP_MNEMONIC_BTC, value: true)
            }
            else if CoinType.ETH.coinType == type {
                Utils.shared.setDefaults(for: Keys.Userdefaults.BACKUP_MNEMONIC_ETH, value: true)
            }
            
            let segue = Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            sendAction(segue: segue, userInfo: [Keys.UserInfo.fromSegue: segue,
                                                Keys.UserInfo.planet: planet])
        }
    }
    
    @objc func refreshed() {
        isSyncing = true
        getBalance()
        SyncManager.shared.syncPlanet(self)
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
        getBalance()
    }
    
    
    var countDown = 0
    
    private func getBalance() {
        guard let selectPlanet = planet else { return }
        
        if let coinTypeInt = self.planet?.coinType {
            let cointype = CoinType.of(coinTypeInt).name
            
            var idx = 0
            if coinTypeInt == CoinType.ETH.coinType {
                countDown = selectPlanet.items!.count;
                selectPlanet.items?.forEach({ (item) in
                    if item.getCoinType() == CoinType.ETH.coinType {
                        Get(self).action(Route.URL("balance", cointype, planet!.name!), requestCode: 1, resultCode: idx, data: nil, extraHeaders: ["device-key": DEVICE_KEY])
                    }
                    else { //ERC20
                        let erc20 = item as? ERC20
                        Get( self ).action(Route.URL("balance", erc20!.symbol!, planet!.name!), requestCode: 1, resultCode: idx, data: nil, extraHeaders: ["device-key": DEVICE_KEY])
                    }
                    
                    idx += 1
                })
            }
            else if coinTypeInt == CoinType.BTC.coinType {
                Get(self).action(Route.URL("balance", cointype, planet!.name!), requestCode: 0, resultCode: 0, data: nil, extraHeaders: ["device-key": DEVICE_KEY])
            }
        }
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
        //Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = UIColor.clear
        
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        self.loadCustomRefreshContents()
        
        tableView.contentInset = UIEdgeInsets(top: naviBar.frame.height - Utils.shared.statusBarHeight(),
                                              left: 0, bottom: 130, right: 0)
        
        //Header, Footer
        planetView.frame = CGRect(x: ( SCREEN_WIDTH - (SCREEN_WIDTH*170.0/375.0) ) / 2.0,
                                  y: planetView.frame.origin.y,
                                  width: (SCREEN_WIDTH*170.0/375.0),
                                  height: (SCREEN_WIDTH*170.0/375.0))
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
    
    private func loadCustomRefreshContents() {
        animationView = AnimationView()
        animationView.frame = loadingViewWrapper.bounds
        loadingViewWrapper.addSubview(animationView)
        animationView.animation = Animation.named("refreshLoading")
        animationView.contentMode = .scaleAspectFit
    }
    
    private func updatePlanet() {
        
        if let selectPlanet = planet {
            
            if let type = selectPlanet.coinType{
                let coinType = CoinType.of(type).coinType
                
                if( coinType == CoinType.BTC.coinType ){
                    
                    // Get tx/list/BTC/{planetOrAddress}
                    selectPlanet.items = [BTC()]
                    
                }else if( coinType == CoinType.ETH.coinType ){
                    if let keyId = selectPlanet.keyId, let ethAddr = selectPlanet.address{
                        selectPlanet.items = ERC20Store.shared.list(keyId, false)
                        selectPlanet.items?.insert(ETH(keyId,
                                                       balance: selectPlanet.balance ?? "0",
                                                       address: ethAddr),
                                                   at: 0)
                        
                    }
                }
            }
            
            if mainAdapter == nil {
                mainAdapter = MainAdapter(tableView, [MainItem]())
            }
            
            if let adapter = mainAdapter, let items = selectPlanet.items{
                adapter.dataSetNotify(items)
            }
        }
        
        self.initBackupAlertView()
        
        if let selectPlanet = planet,
            let type = planet?.coinType,
            let planetKeyId = planet?.keyId
        {
            Utils.shared.setDefaults(for: Keys.Userdefaults.SELECTED_PLANET, value: planetKeyId)
            
            if type == CoinType.ETH.coinType { //ETH
                footerView.isEthUniverse = true
                footerView.isHidden = false
                
                tableView.allowsSelection = true
            }
            else if type == CoinType.BTC.coinType { //BTC
                tableView.allowsSelection = false
                
                footerView.isEthUniverse = false
                footerView.isHidden = !selectPlanet.items!.isEmpty
            }
            //binding naviBar
            naviBar.title = CoinType.of( selectPlanet.coinType! ).name
            
            
            if let planetNameStr = selectPlanet.name, let planetAddr = selectPlanet.address {
                
                //binding headerView
                addressLb.text = Utils.shared.trimAddress(planetAddr)
                planetNameLb.text = planetNameStr
                planetView.data = planetAddr
                bgPlanetView.data = planetAddr
                
                //binding bottomLauncher
                bottomMenuLauncher?.planet = selectPlanet
                if selectPlanet.balance == "" {
                    bottomMenuBalanceLb.text = "0"
                }
                else {
                    bottomMenuBalanceLb.text = selectPlanet.balance ?? "0"
                }
                bottomMenuCoinTypeLb.text = selectPlanet.symbol
                if let planetName = selectPlanet.name {
                    bottomMenuNameLb.text = "\(planetName) Balance"
                    bottomMenuPlanetView.data = planetAddr
                }
            }
        }
        
        if let items = planet?.items {
            mainAdapter?.dataSetNotify(items)
        }
    }
    
    private func hideRefreshContents() {
        if refreshControl.isRefreshing && tableView.isDragging == false {
            self.animationView.stop()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showCopyToast() {
        Toast(text: "main_copy_to_clipboard".localized).show()
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        if requestCode == 1 {
            countDown -= 1
        }
        
        guard let selectedPlanet = planet else { return }
        
        if success {
            if let dict = dictionary, let resultObj = dict["result"] as? [String:Any] {
                
                if requestCode == 0 {
                    
                    let planet = Planet(JSON: resultObj)
                    selectedPlanet.balance = planet?.balance
                    bottomMenuBalanceLb.text = planet?.balance
                    
                    //TODO: - BTC
                    if let type = self.planet?.coinType {
                        if type == CoinType.BTC.coinType {
                            isSyncing = false
                            if tableView.isDragging {
                                isScrollingOnSyncing = true
                            }
                            else {
                                hideRefreshContents()
                            }
                        }
                    }
                }
                else if requestCode == 1 {
                    
                    if let items = selectedPlanet.items, let planet = Planet(JSON: resultObj) {
                        if let eth = items[resultCode] as? ETH, let balance = planet.balance {
                            eth.balance = balance
                            selectedPlanet.balance = balance
                            bottomMenuBalanceLb.text = balance
                        }
                        else if let erc20 = items[resultCode] as? ERC20 {
                            erc20.balance = planet.balance
                        }
                        
                        if( countDown == 0 ) {
                            isSyncing = false
                            if tableView.isDragging {
                                isScrollingOnSyncing = true
                            }
                            else {
                                hideRefreshContents()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.mainAdapter?.dataSetNotify(items)
                                }
                            }
                        }
                        
                    }
                }
            }
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

//MARK: - UIScrollViewDelegate
extension MainController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let refreshControl = refreshControl else { return }
        
        if ( refreshControl.isRefreshing && self.isAnimation ) {
            self.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing && isSyncing == false {
            refreshed()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = ( tableView.contentOffset.y + self.statusHeight + scrollView.contentInset.top )
        
        if( tableView.contentOffset.y > planetView.frame.origin.y + planetView.frame.height/3.0 - naviBar.frame.height ){
            let startPosition = (  planetView.frame.origin.y + planetView.frame.height/3.0 + self.statusHeight + scrollView.contentInset.top - naviBar.frame.height)
            let moveRange = planetView.frame.height*2.0/3.0
            let movePosition = offsetY - startPosition
            naviBar.backgroundView.alpha = movePosition / moveRange
        }else{
            naviBar.backgroundView.alpha = 0
        }
        
        //handling multiple Pull to refresh
        if scrollView.isDecelerating && offsetY == 0 && isScrollingOnSyncing {
            isScrollingOnSyncing = false
            hideRefreshContents()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let items = self.planet?.items {
                    self.mainAdapter?.dataSetNotify(items)
                }
            }
        }
        
        if( offsetY > 0){
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)

            hideRefreshContents()
        } else {
            if refreshControl.isRefreshing {
                let scale = 1.0 - (offsetY - 60)/(self.view.frame.width/2.0)*0.5
                bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            }
            else {
                let scale = 1.0 - (offsetY)/(self.view.frame.width/2.0)*0.5
                bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            }
            
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

//MARK: - UITableViewDelegate
extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedPlanet = planet else { return }
        
        if let mainItemList = selectedPlanet.items {
            if let erc20 = mainItemList[indexPath.row] as? ERC20 {
                bottomMenuTokenView?.show(erc: erc20, planet: selectedPlanet)
            }
            else if let _ = mainItemList[indexPath.row] as? ETH {
                bottomMenuLauncher?.planet = selectedPlanet
                bottomMenuLauncher?.show()
            }
        }
    }
}

//MARK: - TopMenuLauncherDelegate
extension MainController: TopMenuLauncherDelegate {
    func didSelected(planet: Planet) {
        self.planet = planet
        updatePlanet()
        getBalance()
    }
    
    func didSelectedFooter() {
        topMenuLauncher?.handleDismiss {
            let segueID = Keys.Segue.MAIN_TO_WALLET_ADD
            self.sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
        }
    }
}

//MARK: - BottomMenuDelegate
extension MainController: BottomMenuDelegate {
    func didTouchedSend() {
        bottomMenuLauncher?.hide()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let selectedPlanet = self.planet else { return }
            self.sendAction(segue: Keys.Segue.MAIN_TO_TRANSFER,
                            userInfo: [Keys.UserInfo.planet: selectedPlanet])
        }
    }
    
    func didTouchedCopy(_ addr: String) {
        showCopyToast()
        Utils.shared.copyToClipboard(addr)
    }
}

//MARK: - BottomMenuTokenDelegate
extension MainController: BottomMenuTokenDelegate {
    func didTouchedTokenSend() {
        guard let selectedERC20 = bottomMenuTokenView?.erc20 else { return }
        
//        guard let selectedPlanet = self.planet else { return }
//
//        let tx = Transaction( selectedERC20 )
//            .deviceKey(DEVICE_KEY)
//            .from(selectedPlanet.address!)
//            .to("0x0e37Ec5eFFEAB3836D761765656509A7Cf8077F0")
//            .value("1000000000000000000")
//            .gasPrice("9000000000")
//            .gasLimit("100000")
//
//        tx.getRawTransaction(privateKey: selectedPlanet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE), {
//            (success, rawTx) in
//            print(rawTx)
//            //            Post(self).action(Route.URL("transfer", selectedERC20.symbol),
//            //                              requestCode: 100,
//            //                              resultCode: 100,
//            //                              data: ["serializeTx":rawTx],
//            //                              extraHeaders: ["device-key":DEVICE_KEY] );
//        });
        
        bottomMenuTokenView?.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let selectedPlanet = self.planet else { return }
            self.sendAction(segue: Keys.Segue.MAIN_TO_TRANSFER,
                            userInfo: [Keys.UserInfo.planet: selectedPlanet,
                                       Keys.UserInfo.erc20 : selectedERC20])
        }
    }
    
    func didTouchedTokenCopy(_ addr: String) {
        Utils.shared.copyToClipboard(addr)
        showCopyToast()
    }
}

//MARK: - MainTableFooterDelegate
extension MainController: MainTableFooterDelegate {
    func didTouchedManageToken() {
        guard let selectedPlanet = self.planet else { return }
        sendAction(segue: Keys.Segue.MAIN_TO_TOKEN_ADD,
                   userInfo: [Keys.UserInfo.planet:selectedPlanet])
    }
}


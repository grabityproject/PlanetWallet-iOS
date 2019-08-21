//
//  TransferController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import AVFoundation

extension TransferController {
    enum TableState {
        case SEARCH
        case RECENT_SEARCH
    }
}

class TransferController: PlanetWalletViewController {
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notFoundLb: PWLabel!
    @IBOutlet var magnifyingImgView: PWImageView!
    @IBOutlet var recentLb: PWLabel!
    
    @IBOutlet var pasteBtnContainer: UIView!
    
    @IBOutlet var tableTopConstraint: NSLayoutConstraint!
    
    var planet:Planet?
    var erc20: ERC20?
    
    var planetSearchAdapter: PlanetSearchAdapter?
    var searchingDatasource = [Planet]()
    var recentSearchAdapter: RecentSearchAdapter?
    var recentDatasource = [Planet]()
    
    var selectedSymbol = ""
    var search:String = ""
    
    var qrCaptureController: QRCaptureController?
    
    var tableState: TableState = TableState.RECENT_SEARCH {
        didSet {
            switch self.tableState {
            case .RECENT_SEARCH:
                recentLb.isHidden = false
                tableTopConstraint.constant = 37
                recentSearchAdapter = RecentSearchAdapter(tableView, recentDatasource)
                recentSearchAdapter?.delegate = self
            case .SEARCH:
                recentLb.isHidden = true
                tableTopConstraint.constant = 15
                planetSearchAdapter = PlanetSearchAdapter(tableView, searchingDatasource)
                planetSearchAdapter?.delegate = self
                planetSearchAdapter?.dataSetNotify(searchingDatasource)
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        naviBar.title = "transfer_toolbar_title".localized
        
        
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "transfer_search_title".localized,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
    }
    
    override func setData() {
        
        guard let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let keyId = planet.keyId,
            let coinType = planet.coinType else { return }
        
        if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let symbol = erc20.symbol {
            self.erc20 = erc20
            selectedSymbol = symbol
        }
        else {
            if coinType == CoinType.BTC.coinType {
                selectedSymbol = "BTC"
            }
            else if coinType == CoinType.ETH.coinType {
                selectedSymbol = "ETH"
            }
        }
        
        self.planet = planet
        
//        planetSearchAdapter = PlanetSearchAdapter(tableView, [])
        self.recentDatasource = SearchStore.shared.list(keyId: keyId, symbol: selectedSymbol, descending: true)
        self.tableState = .RECENT_SEARCH
        
//        updateUI()
        
        showPasteBtn()
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "transfer_search_title".localized,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? QRCaptureController {
            qrCaptureController = destination
            qrCaptureController?.delegate = self
        }
    }
    
    //MARK: - Private
    private func updateUI() {
        guard let adapter = planetSearchAdapter else { return }
        
        if( adapter.dataSource.count == 0 && search.count == 0 ){
//            recentSearchAdapter = RecentSearchAdapter(tableView, recentDatasource)
//            recentSearchAdapter?.delegate = self
            self.tableState = .RECENT_SEARCH
            
            self.tableView.isHidden = false
            self.notFoundLb.isHidden = true

        }else if( adapter.dataSource.count == 0 && search.count != 0 ){
            
            self.tableView.isHidden = true
            self.notFoundLb.isHidden = false
            self.pasteBtnContainer.isHidden = true
        }else{
            
            self.tableView.isHidden = false
            self.notFoundLb.isHidden = true
            self.pasteBtnContainer.isHidden = true
        }
    }
    
    private func isValidAddr(_ address: String) -> Bool {
        guard let planet = self.planet else { return false }
        
        if let erc20 = erc20 {
            if ( erc20.getCoinType() == CoinType.ERC20.coinType ) && EthereumManager.shared.validateAddress(address) {
                return true
            }
        }
        
        if ( planet.coinType == CoinType.BTC.coinType && BitCoinManager.shared.validAddress(address) ) ||
            ( planet.coinType == CoinType.ETH.coinType && EthereumManager.shared.validateAddress(address) )
        {
            return true
        }
        else {
            return false
        }
    }
    
    private func showPasteBtn() {
        guard let planet = planet,
            let pastedStr = Utils.shared.getClipboard(),
            let address = planet.address else { return }
        
        if isValidAddr(pastedStr) && address != pastedStr {
            self.pasteBtnContainer.isHidden = false
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedPaste(_ sender: UIButton) {
        guard let copiedStr = Utils.shared.getClipboard(),
            let planet = self.planet,
            let coinType = planet.coinType else { return }
        
        textField.text = copiedStr
        search = copiedStr
        Get(self).action(Route.URL("planet", "search", CoinType.of(coinType).name ),requestCode: 0, resultCode: 0, data:["q":copiedStr] )
    }
    
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary, let returnVo = ReturnVO(JSON: dict), let success = returnVo.success else { return }
        
        if( success ){
            searchingDatasource.removeAll()
            let items = returnVo.result as! Array<Dictionary<String, Any>>

            if( items.count == 0 ){
                //Valid address
                if isValidAddr(search) {
                    let addressPlanet = Planet()
                    addressPlanet.address = self.search
                    addressPlanet.coinType = self.planet?.coinType
                    searchingDatasource.append(addressPlanet)
                }
            }else{
                // DataSource update
                items.forEach { (item) in
                    //except self item
                    if let itemName = item["name"] as? String, let selfName = self.planet?.name {
                        if itemName != selfName {
                            searchingDatasource.append(Planet(JSON: item)!)
                        }
                    }
                }
            }
            
//            planetSearchAdapter = PlanetSearchAdapter(tableView, searchingDatasource)
//            planetSearchAdapter?.delegate = self
//            planetSearchAdapter?.dataSetNotify(searchingDatasource)
            self.tableState = .SEARCH
            updateUI()
        }
        
    }
}

extension TransferController: RecentSearchAdapterDelegate {
    func didTouchedDelete(_ planet: Planet) {
        SearchStore.shared.delete(planet)
        if let keyId = self.planet?.keyId {
            recentSearchAdapter?.dataSetNotify(SearchStore.shared.list(keyId: keyId, symbol: selectedSymbol, descending: true))
        }
    }
    
    func didTouchedItem(_ planet: Planet) {
        sendAction(segue: Keys.Segue.TRANSFER_TO_TRANSFER_AMOUNT,
                   userInfo: [Keys.UserInfo.toPlanet: planet,
                              Keys.UserInfo.planet: self.planet as Any,
                              Keys.UserInfo.erc20: self.erc20 as Any])
    }
}

extension TransferController: PlanetSearchAdapterDelegate {
    func didTouchedPlanet(_ planet: Planet) {
        sendAction(segue: Keys.Segue.TRANSFER_TO_TRANSFER_AMOUNT,
                   userInfo: [Keys.UserInfo.toPlanet: planet,
                              Keys.UserInfo.planet: self.planet as Any,
                              Keys.UserInfo.erc20: self.erc20 as Any])
    }
}

extension TransferController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            sendAction(segue: Keys.Segue.TRANSFER_TO_QRCAPTURE, userInfo: nil)
        }
    }
}


extension TransferController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.search = ""
        planetSearchAdapter?.dataSetNotify([])
        updateUI()
        showPasteBtn()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { //backspace
            search = String(search.dropLast())
            if search.count == 0 {
                showPasteBtn()
            }
        }
        else {
            search = textField.text! + string
        }
        
        if let planet = self.planet, let coinType = planet.coinType{
            Get(self).action(Route.URL("planet", "search", CoinType.of(coinType).name ),requestCode: 0, resultCode: 0, data:["q":search] )
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        magnifyingImgView.image = currentTheme.magnifyingPointImg
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        magnifyingImgView.image = currentTheme.magnifyingImg
    }
}

extension TransferController: QRCaptureDelegate {
    func didCapturedQRCode(_ address: String) {
        textField.text = address
        
        if isValidAddr(address) {
            let addressPlanet = Planet()
            addressPlanet.address = address
            addressPlanet.coinType = self.planet?.coinType
            planetSearchAdapter?.dataSetNotify([addressPlanet])
            updateUI()
        }
    }
}

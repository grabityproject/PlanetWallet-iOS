//
//  TxListController.swift
//  PlanetWallet
//
//  Created by grabity on 07/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TxListController: PlanetWalletViewController {
    
    private var planet:Planet = Planet()
    private var mainItem:MainItem = MainItem()
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var balanceLb: PWLabel!
    @IBOutlet var iconImgView: PWImageView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    
    var txList = [Tx]()
    var txAdapter: TxAdapter?
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        guard
            let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem else { self.navigationController?.popViewController(animated: false); return }
        
        self.planet = planet
        self.mainItem = mainItem
        
        
        // naviBar
        if let coinName = mainItem.name{
            naviBar.title = coinName
        }
        
        // balance
        if let symbol = mainItem.symbol{
            balanceLb.text = "\(CoinNumberFormatter.short.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)) \(symbol)"
        }
        
        // imageIcon
        if mainItem.getCoinType() == CoinType.BTC.coinType {
            
            iconImgView.image = UIImage(named: "imageTransferConfirmationBtc02")
            
        }else if mainItem.getCoinType() == CoinType.ETH.coinType {
            
            iconImgView.image = UIImage(named: "eth")
            
        }else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            
            if let img_path = mainItem.img_path {
                iconImgView.loadImageWithPath(Route.URL(img_path))
            }
            
        }
        
        // Adapt tableview
        txList = getTxFromLocal()
        txAdapter = TxAdapter(tableView, txList)
        txAdapter?.delegates.append(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTxList()
        getBalance()
    }
    
    //MARK: - Private
    private func getBalance() {
       
        if let address = planet.address, let symbol = mainItem.symbol {
            Get(self).action(Route.URL("balance", symbol, address),
                             requestCode: 0,
                             resultCode: 0,
                             data: nil,
                             extraHeaders: ["device-key": DEVICE_KEY])
        }
    }
    
    private func getTxList() {

        if let address = planet.address, let symbol = mainItem.symbol {
            Get(self).action(Route.URL("tx", "list", symbol, address),
                             requestCode: 1,
                             resultCode: 0,
                             data: nil,
                             extraHeaders: ["device-key": DEVICE_KEY])
        }
        
    }
    
    private func getTxFromLocal() -> [Tx] {
        var transactionList = [Tx]()
        
        if let coinItem = planet.getMainItem(), let coinSymbol = coinItem.symbol, let symbol = mainItem.symbol, let keyId = planet.keyId {
            
            let key = getKey( [ coinSymbol, symbol, keyId ] )
            if let jsonArr = UserDefaults.standard.array(forKey:key) as? Array<[String: Any]> {
                jsonArr.forEach { (json) in
                    if let tx = Tx(JSON: json) {
                        transactionList.append(tx)
                    }
                }
            }
            
        }
        
        return transactionList
    }
    
    private func getKey(_ elements:[String] )->String{
        return elements.joined(separator:"_")
    }
    
    private func saveTx(_ list: [Tx]) {
        
        if let coinItem = planet.getMainItem(), let coinSymbol = coinItem.symbol, let symbol = mainItem.symbol, let keyId = planet.keyId {
            
            let key = getKey( [ coinSymbol, symbol, keyId ] )
            var dictArr = Array<[String : Any]>()
            list.forEach { (tx) in
                dictArr.append(tx.toJSON())
            }
            
            UserDefaults.standard.set(dictArr, forKey: key)
        }
        
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedReceive(_ sender: UIButton) {
       
        self.sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_ADDRESS,
                        userInfo: [Keys.UserInfo.planet: planet,
                                   Keys.UserInfo.mainItem : mainItem])
        
    }
    
    @IBAction func didTouchedTransfer(_ sender: UIButton) {
        
        self.sendAction(segue: Keys.Segue.TX_LIST_TO_TRANSFER,
                        userInfo: [Keys.UserInfo.planet: planet,
                                   Keys.UserInfo.mainItem : mainItem])
   
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard success,
            let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if isSuccess {
            if requestCode == 0 {
                //Handle balance response
                guard let json = dict["result"] as? [String:Any] else { return }
                
                if let item = MainItem(JSON:json) {
                    
                    mainItem.balance = item.getBalance()
                    if let symbol = mainItem.symbol{
                        balanceLb.text = "\(CoinNumberFormatter.short.toMaxUnit(balance:  item.getBalance(), item: mainItem)) \(symbol)"
                    }
                    
                }
                
            }else if requestCode == 1 {
                //Handle transacion list response
                self.txList.removeAll()
                
                guard let txItems = returnVo.result as? Array<Dictionary<String, Any>> else { return }
                for i in 0..<txItems.count {
                    if let transaction = Tx(JSON: txItems[i]) {
                        txList.append(transaction)
                    }
                }
                
                if txList.count == 0 {
                    footerView.isHidden = false
                }
                
                saveTx(txList)
                txAdapter?.dataSetNotify(txList)
            }
        }
        else {
            if let errDict = returnVo.result as? [String: Any],
                let errorMsg = errDict["errorMsg"] as? String
            {
                Toast(text: errorMsg).show()
            }
        }
    }
}

extension TxListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_TX,
                   userInfo: [Keys.UserInfo.planet: planet,
                              Keys.UserInfo.mainItem: mainItem,
                              Keys.UserInfo.tx: txList[indexPath.row]])
        
    }
}

extension TxListController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

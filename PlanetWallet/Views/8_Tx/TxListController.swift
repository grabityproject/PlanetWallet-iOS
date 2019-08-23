//
//  TxListController.swift
//  PlanetWallet
//
//  Created by grabity on 07/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 트랜잭션 리스트 페이지 ( ETH, ERC20 )
 
 -툴바 ( 뒤로가기 )
 밸런스 정보
 플래닛 뷰 1개 ( Optianl )
 현재 누른 토큰 또는 코인 정보 ( Symbol, Icon )
 QR Code 버튼
 전송하기 버튼
 리스트 [ 행성, 주소, 밸런스, 데이트, 받았다 보냈다 아이콘 ]
 */

struct TransactionSample {
    let fromPlanet: Planet
    let toPlanet: Planet
    let amount: String
    let isIncomming: Bool
    let txID: String
    let fee: String
    let date: String
    
    func description() -> String {
        return "from : \(fromPlanet.address!) , to : \(toPlanet.address!), amount: \(amount)"
    }
}

enum TokenType {
    case ETH
    case ERC20(_ erc20: ERC20)
}

class TxListController: PlanetWalletViewController {
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var balanceLb: PWLabel!
    @IBOutlet var iconImgView: PWImageView!
    
    @IBOutlet var tableView: UITableView!
    
    let cellID = "TxCellID"
    var txList = [Tx]()
    
    private var planet: Planet?
    private var tokenType: TokenType = .ETH
    
    var txAdapter: TxAdapter?
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        guard let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet else { return }
        
        self.planet = planet
        
        if let erc20 = userInfo[Keys.UserInfo.mainItem] as? ERC20
        {//ERC20
            
            self.tokenType = .ERC20(erc20)
            
            naviBar.title = erc20.name
            iconImgView.downloaded(from: Route.URL( erc20.img_path ?? "" ))
        }
        else {//ETH
            guard let symbol = planet.symbol, let balance = planet.balance else { return }
            
            self.tokenType = .ETH

            if let shortEtherStr = CoinNumberFormatter.short.toMaxUnit(balance: balance, coinType: CoinType.ETH) {
                balanceLb.text = "\(shortEtherStr) \(symbol)"
            }
            
            naviBar.title = "Ethereum"
        }
        
        txAdapter = TxAdapter(tableView, txList)
        txAdapter?.selectedPlanet = self.planet
        txAdapter?.delegates.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch tokenType {
        case .ETH:
            break
        case .ERC20(let token):
            iconImgView.downloaded(from: Route.URL( token.img_path ?? "" ))
        }
        
        getTxList()
        getBalance()
    }
    
    //MARK: - Private
    private func getBalance() {
        guard let planet = planet, let planetName = planet.name else { return }
        var symbol = ""
        switch tokenType {
        case .ETH:
            symbol = "ETH"
        case .ERC20(let token):
            guard let tokenSymbol = token.symbol else { return }
            symbol = tokenSymbol
        }
        
        Get(self).action(Route.URL("balance", symbol, planetName),
                         requestCode: 1,
                         resultCode: 1,
                         data: nil,
                         extraHeaders: ["device-key": DEVICE_KEY])
    }
    
    private func getTxList() {
        
        guard let symbol = planet?.symbol, let name = planet?.name else { return }
        
        var selectedTokenSymbol = symbol
        
        switch tokenType {
        case .ETH:
            break
        case .ERC20(let erc20):
            guard let erc20Symbol = erc20.symbol else { return }
            selectedTokenSymbol = erc20Symbol
        }
        
        txAdapter?.dataSetNotify(getTxFromLocal())
        
        Get(self).action(Route.URL("tx", "list", selectedTokenSymbol, name),
                         requestCode: 0,
                         resultCode: 0,
                         data: nil,
                         extraHeaders: ["device-key": DEVICE_KEY])
    }
    
    private func getTxFromLocal() -> [Tx] {
        var transactionList = [Tx]()
        
        guard let planet = planet, let keyId = planet.keyId else { return transactionList }
        var symbol = "ETH"
        
        switch tokenType {
        case .ETH:
            symbol = "ETH"
        case .ERC20(let token):
            if let _symbol = token.symbol {
                symbol = _symbol
            }
        }
        
        if let jsonArr = UserDefaults.standard.array(forKey: "ETH_\(symbol)_\(keyId)") as? Array<[String: Any]> {
            jsonArr.forEach { (json) in
                if let tx = Tx(JSON: json) {
                    transactionList.append(tx)
                }
            }
        }
        
        return transactionList
    }
    
    private func saveTx(_ list: [Tx]) {
        
        guard let planet = planet, let keyId = planet.keyId else { return }
        
        var dictArr = Array<[String : Any]>()
        list.forEach { (tx) in
            print(tx.toJSON())
            dictArr.append(tx.toJSON())
        }
        
        var symbol = "ETH"
        
        switch tokenType {
        case .ETH:
            symbol = "ETH"
        case .ERC20(let token):
            if let _symbol = token.symbol {
                symbol = _symbol
            }
        }
        
        UserDefaults.standard.set(dictArr, forKey: "ETH_\(symbol)_\(keyId)")
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedReceive(_ sender: UIButton) {
        if let selectedPlanet = planet {
            switch tokenType {
            case .ETH:
                self.sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_ADDRESS,
                                userInfo: [Keys.UserInfo.planet: selectedPlanet])
            case .ERC20(let selectedERC20):
                self.sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_ADDRESS,
                                userInfo: [Keys.UserInfo.planet: selectedPlanet,
                                           Keys.UserInfo.erc20 : selectedERC20])
            }
        }
    }
    
    @IBAction func didTouchedTransfer(_ sender: UIButton) {
        guard let selectedPlanet = self.planet else { return }
        
        switch tokenType {
        case .ETH:
            self.sendAction(segue: Keys.Segue.TX_LIST_TO_TRANSFER,
                            userInfo: [Keys.UserInfo.planet: selectedPlanet])
        case .ERC20(let selectedERC20):
            self.sendAction(segue: Keys.Segue.TX_LIST_TO_TRANSFER,
                            userInfo: [Keys.UserInfo.planet: selectedPlanet,
                                       Keys.UserInfo.erc20 : selectedERC20])
        }
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if requestCode == 1 {
            //Handle balance response
            guard let json = dict["result"] as? [String:Any],
                let planet = Planet(JSON: json),
                let balance = planet.balance else { return }
            
            switch tokenType {
            case .ETH:
                if let shortEtherStr = CoinNumberFormatter.short.toMaxUnit(balance: balance, coinType: CoinType.ETH),
                    let symbol = self.planet?.symbol
                {
                    balanceLb.text = "\(shortEtherStr) \(symbol)"
                }
            case .ERC20(let token):
                if let shortTokenStr = CoinNumberFormatter.short.toMaxUnit(balance: balance, item: token),
                    let symbol = token.symbol
                {
                    balanceLb.text = "\(shortTokenStr) \(symbol)"
                }
            }
        }
        else {
            //Handle transacion list response
            guard let txItems = returnVo.result as? Array<Dictionary<String, Any>> else { return }
            self.txList.removeAll()
            
            if isSuccess {
                
                for i in 0..<txItems.count {
                    if let transaction = Tx(JSON: txItems[i]) {
                        txList.append(transaction)
                    }
                }
            }
            else {
                print("Failed to response txList")
            }
            saveTx(txList)
            txAdapter?.dataSetNotify(txList)
        }
    }
}

extension TxListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let planet = planet else { return }
        
        sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_TX,
                   userInfo: [Keys.UserInfo.planet: planet,
                              Keys.UserInfo.transaction: txList[indexPath.row]])
    }
}

extension TxListController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

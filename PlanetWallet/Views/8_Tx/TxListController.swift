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
        
        if let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet
        {
            self.planet = planet
            
            
            if let erc20 = userInfo[Keys.UserInfo.mainItem] as? ERC20
            {//ERC20
                guard let symbol = erc20.symbol,
                    let balance = erc20.balance,
                    let iconImgPath = erc20.img_path else { return }
                
                self.tokenType = .ERC20(erc20)
                if let shortEtherStr = CoinNumberFormatter.short.toEthString(wei: balance) {
                    balanceLb.text = "Balance : \(shortEtherStr) \(symbol)"
                }
                
                iconImgView.downloaded(from: Route.URL( iconImgPath ))
            }
            else {//ETH
                guard let symbol = planet.symbol, let balance = planet.balance else { return }
                
                self.tokenType = .ETH
                if let shortEtherStr = CoinNumberFormatter.short.toEthString(wei: balance) {
                    balanceLb.text = "Balance : \(shortEtherStr) \(symbol)"
                }
            }
            
            txAdapter = TxAdapter(tableView, txList)
            txAdapter?.selectedPlanet = self.planet
            txAdapter?.delegates.append(self)
        }
        
        getTxList()
    }
    
    //MARK: - Private
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
        
        
        Get(self).action(Route.URL("tx", "list", selectedTokenSymbol, name),
                         requestCode: 0,
                         resultCode: 0,
                         data: nil,
                         extraHeaders: ["device-key": DEVICE_KEY])
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedReceive(_ sender: UIButton) {
        
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
            let isSuccess = returnVo.success,
            let txItems = returnVo.result as? Array<Dictionary<String, Any>> else { return }
        
        self.txList.removeAll()
        
        if isSuccess {
            for i in 0..<txItems.count {
                print("-------\(i) Transaction-------")
                if let transaction = Tx(JSON: txItems[i]) {
                    print("TxHash: \(transaction.tx_id!)")
                    print("from: \(transaction.from!)")
                    print("to: \(transaction.to!)")
                    txList.append(transaction)
                }
            }
        }
        else {
            print("Failed to response txList")
        }
        
        txAdapter?.dataSetNotify(txList)
    }
}

extension TxListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_TX,
                   userInfo: [Keys.UserInfo.transaction: txList[indexPath.row]])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
}

extension TxListController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

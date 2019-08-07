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
    let fromAddress: String
    let toAddress: String
    let amount: String
    let isIncomming: Bool
    
    func description() -> String {
        return "from : \(fromAddress) , to : \(toAddress), amount: \(amount)"
    }
}

class TxListController: PlanetWalletViewController {
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var balanceLb: PWLabel!
    @IBOutlet var addressLb: PWLabel!
    @IBOutlet var symbolLb: PWLabel!
    @IBOutlet var iconImgView: PWImageView!
    
    @IBOutlet var tableView: UITableView!
    
    let cellID = "TxCellID"
    let dataSource: [TransactionSample] = [TransactionSample(fromAddress: "0x00", toAddress: "0x01", amount: "0.87", isIncomming: true),
                                           TransactionSample(fromAddress: "0x00", toAddress: "0x02", amount: "4.322211", isIncomming: true),
                                           TransactionSample(fromAddress: "0x40", toAddress: "0x232", amount: "0.11", isIncomming: false),
                                           TransactionSample(fromAddress: "0x02", toAddress: "0x442", amount: "1", isIncomming: false),
                                           TransactionSample(fromAddress: "0x00", toAddress: "0x01", amount: "32.1", isIncomming: true)]
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet
        {
            //ERC20 or Coin
            if let erc20 = userInfo[Keys.UserInfo.mainItem] as? ERC20
            {
                guard let symbol = erc20.symbol,
                    let balance = erc20.balance,
                    let iconImgPath = erc20.img_path else { return }
                
                symbolLb.text = "Symbol : \(symbol)"
                balanceLb.text = "Balance : \(balance)"
                iconImgView.downloaded(from: Route.URL( iconImgPath ))
            }
            else {
                guard let symbol = planet.symbol, let balance = planet.balance else { return }
                symbolLb.text = "Symbol : \(symbol)"
                balanceLb.text = "Balance : \(balance)"
            }
            
            if let address = planet.address {
                addressLb.text = "Address : \(address)"
            }
            
        }
    }
}

extension TxListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        let tx = dataSource[indexPath.row]
        cell?.textLabel?.text = tx.description()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath.row)")
        let tx = dataSource[indexPath.row]
        
        sendAction(segue: Keys.Segue.TX_LIST_TO_DETAIL_TX, userInfo: [Keys.UserInfo.transaction: tx])
    }
}

extension TxListController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

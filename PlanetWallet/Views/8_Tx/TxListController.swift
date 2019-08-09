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
    @IBOutlet var addressLb: PWLabel!
    @IBOutlet var symbolLb: PWLabel!
    @IBOutlet var iconImgView: PWImageView!
    
    @IBOutlet var tableView: UITableView!
    
    let cellID = "TxCellID"
    var dataSource: [TransactionSample] = [TransactionSample]()
    
    private var planet: Planet?
    private var tokenType: TokenType = .ETH
    
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
            self.planet = planet
            
            
            if let erc20 = userInfo[Keys.UserInfo.mainItem] as? ERC20
            {//ERC20
                guard let symbol = erc20.symbol,
                    let balance = erc20.balance,
                    let iconImgPath = erc20.img_path else { return }
                
                self.tokenType = .ERC20(erc20)
                symbolLb.text = "Symbol : \(symbol)"
                balanceLb.text = "Balance : \(balance)"
                iconImgView.downloaded(from: Route.URL( iconImgPath ))
            }
            else {//ETH
                guard let symbol = planet.symbol, let balance = planet.balance else { return }
                
                self.tokenType = .ETH
                symbolLb.text = "Symbol : \(symbol)"
                balanceLb.text = "Balance : \(balance)"
            }
            
            if let address = planet.address {
                addressLb.text = "Address : \(address)"
            }
            
            let samplePlanet1 = Planet()
            samplePlanet1.address = "0x12931289127498124"
            samplePlanet1.coinType = planet.coinType
            samplePlanet1.name = "sample"
            
            let samplePlanet2 = Planet()
            samplePlanet2.address = "0x12931289127498124"
            samplePlanet2.coinType = planet.coinType
            
            let samplePlanet3 = Planet()
            samplePlanet3.address = "0x12931289127498124"
            samplePlanet3.coinType = planet.coinType
            
            dataSource.append(TransactionSample(fromPlanet: planet, toPlanet: samplePlanet1, amount: "0.214", isIncomming: false, txID: "testTxID", fee: "0.123", date: "08.08 12:00"))
            dataSource.append(TransactionSample(fromPlanet: samplePlanet1, toPlanet: samplePlanet2, amount: "414", isIncomming: false, txID: "testTxID1", fee: "0.03", date: "01.02 01:00"))
            dataSource.append(TransactionSample(fromPlanet: samplePlanet2, toPlanet: samplePlanet3, amount: "0.001", isIncomming: false, txID: "testTxID2", fee: "0.01", date: "08.01 00:00"))
            dataSource.append(TransactionSample(fromPlanet: planet, toPlanet: samplePlanet2, amount: "13", isIncomming: false, txID: "testTxID3", fee: "0.002", date: "08.01 00:00"))
            dataSource.append(TransactionSample(fromPlanet: samplePlanet3, toPlanet: samplePlanet3, amount: "9.91", isIncomming: false, txID: "testTxID4", fee: "0.34", date: "08.01 00:00"))
            tableView.reloadData()
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedQR(_ sender: UIButton) {
        
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

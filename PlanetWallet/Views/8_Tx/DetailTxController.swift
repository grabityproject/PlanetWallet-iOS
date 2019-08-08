//
//  DetailTxController.swift
//  PlanetWallet
//
//  Created by grabity on 07/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 트랜잭션 상세 보기 페이지 ( ETH, ERC20, BTC )
 
 to ( 플래닛 표현 가능/불가능 둘다 )
 from ( 플래닛 표현 가능/불가능 둘다 )
 amount
 fee
 date
 txId
 Button( Explorer로 이동 )
 */
class DetailTxController: PlanetWalletViewController {
    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var fromPlanetView: PlanetView!
    @IBOutlet var fromLb: UILabel!
    
    @IBOutlet var toPlanetView: PlanetView!
    @IBOutlet var toLb: UILabel!
    @IBOutlet var amountLb: UILabel!
    @IBOutlet var feeLb: UILabel!
    @IBOutlet var dateLb: UILabel!
    @IBOutlet var txIdLb: UILabel!
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let transaction = userInfo[Keys.UserInfo.transaction] as? TransactionSample,
            let fromAddr = transaction.fromPlanet.address,
            let toAddr = transaction.toPlanet.address
        {
            if let fromPlanetName = transaction.fromPlanet.name {
                //Planet Name
                fromPlanetView.isHidden = false
                fromPlanetView.data = fromAddr
                fromLb.text = "From: \(fromPlanetName)"
            }
            else {
                //Address
                fromPlanetView.isHidden = true
                fromLb.text = "From: \(fromAddr)"
            }
            
            if let toPlanetName = transaction.toPlanet.name {
                //Planet Name
                toPlanetView.isHidden = false
                toPlanetView.data = toAddr
                toLb.text = "To : \(toPlanetName)"
            }
            else {
                //Address
                toPlanetView.isHidden = true
                toLb.text = "To : \(toAddr)"
            }
            
            amountLb.text = "Amount : \(transaction.amount)"
            feeLb.text = "Fee : \(transaction.fee)"
            dateLb.text = "Date : \(transaction.date)"
            txIdLb.text = "TxID : \(transaction.txID)"
        }
    }
    
    @IBAction func didTouchedScan(_ sender: UIButton) {
        //tx/{txid}
        guard let url = URL(string: "https://etherscan.io/tx/0xf684692d9531ff9d5deb906ae5564c156279c10314b0964f6f4e9fdd21f06027"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension DetailTxController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

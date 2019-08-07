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
    
    @IBOutlet var descriptionLb: UILabel!
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo, let transaction = userInfo[Keys.UserInfo.transaction] as? TransactionSample {
            descriptionLb.text = transaction.description()
        }
    }
}

extension DetailTxController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

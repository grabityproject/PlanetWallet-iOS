//
//  ETH.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class ETH: MainItem {
    
    let keyId: String
    let name: String = CoinType.ETH.coinName
    let symbol: String = CoinType.ETH.defaultUnit ?? "ETH"
    var balance: String = "0"
    let address: String
    
    let iconImg = UIImage(named: "tokenIconETH")
    
    init(_ keyId: String, balance: String, address: String) {
        self.keyId = keyId
        self.balance = balance
        self.address = address
    }
    
    func getCoinType() -> Int {
        return CoinType.ETH.coinType
    }
}

//
//  BTC.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class BTC: MainItem {
    
    var balance: String = "0"
    
    func getCoinType() -> Int {
        return CoinType.BTC.coinType
    }
    
    
}

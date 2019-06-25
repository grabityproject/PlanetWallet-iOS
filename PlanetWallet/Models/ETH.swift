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
    /*
    let keyId: String
    let name: String
    let symbol: String
    let balance: String
    let address: String
    
    let iconImg = UIImage(named: "tokenIconETH")
    */
    func getCoinType() -> Int {
        return CoinType.ETH.coinType
    }
}

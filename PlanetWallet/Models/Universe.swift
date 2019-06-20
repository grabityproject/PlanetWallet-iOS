//
//  Universe.swift
//  PlanetWallet
//
//  Created by grabity on 20/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct Universe {
    var type: UniverseType = .ETH
    let name: String
    let coinList: [ERCToken]?
    let transactionList: [BTCTransaction]?
    
    init(type: UniverseType, name: String, coinList: [ERCToken]?, transactions: [BTCTransaction]?) {
        self.type = type
        self.name = name
        self.coinList = coinList
        self.transactionList = transactions
    }
}

//
//  Coin.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class ERC20: Mappable, MainItem {
    
    var _id: String?
    var keyId: String?
    var contract: String?
    var name: String?
    var symbol: String?
    var balance: String?
    var address: String?
    var decimals: String?
    
    var price: String?
    var hide: String?
    
    var img_path: String?
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        _id <- map["_id"]
        keyId <- map["keyId"]
        contract <- map["contract"]
        name <- map["name"]
        symbol <- map["symbol"]
        balance <- map["balance"]
        address <- map["address"]
        decimals <- map["decimals"]
        
        price <- map["price"]
        hide <- map["hide"]
        
        img_path <- map["img_path"]
    }
    
    func getCoinType() -> Int {
        return CoinType.ERC20.coinType
    }
}

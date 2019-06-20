//
//  Coin.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class ERC20: Mappable {
    
    var _id : String?
    var keyId : String?
    var balance : String?
    var name : String?
    var symbol : String?
    var decimals : String?
    var contract : String?
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        self._id     <- map["_id"]
        self.keyId             <- map["keyId"]
        self.balance             <- map["balance"]
        self.name                <- map["name"]
        self.symbol              <- map["symbol"]
        self.decimals                <- map["decimals"]
        self.contract              <- map["contract"]
    }
}

class ERCToken: Mappable {
    var contractAddress: String?
    var decimal: Int?
    var imgPath: String?
    var name: String?
    var symbol: String?
    
    required init?(map: Map) {
    }
    
    init(name: String, symbol: String, decimal: String, contractAdd: String, imgPath: String?) {
        self.name = name
        self.symbol = symbol
        self.decimal = Int(decimal)
        self.contractAddress = contractAdd
        self.imgPath = imgPath
    }
    
    func mapping(map: Map) {
        self.contractAddress     <- map["contract_address"]
        self.decimal             <- map["decimal"]
        self.imgPath             <- map["img_path"]
        self.name                <- map["name"]
        self.symbol              <- map["symbol"]
    }
}


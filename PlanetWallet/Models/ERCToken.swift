//
//  Coin.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

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


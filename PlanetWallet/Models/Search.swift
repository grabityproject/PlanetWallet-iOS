//
//  Search.swift
//  PlanetWallet
//
//  Created by grabity on 09/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper


class Search: Mappable {
    
    var _id: Int?
    var keyId: String!
    var name: String?
    var address: String!
    var symbol: String!
    
    
    init(keyId: String, name: String?, address: String, symbol: String) {
        self.keyId = keyId
        self.name = name
        self.address = address
        self.symbol = symbol
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        _id         <- map["_id"]
        keyId       <- map["keyId"]
        name        <- map["name"]
        address     <- map["address"]
        symbol      <- map ["symbol"]
    }
}


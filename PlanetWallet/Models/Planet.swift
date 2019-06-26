//
//  Planet.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class Planet: Mappable {
    //db
    var _id: Int?
    var keyId: String?
    var pathIndex: Int?
    var coinType: Int?
    var symbol: String?
    var decimals: String?
    var hide: String? //Y,N
    var address: String?
    var name: String?
    var balance: String?
    
    //network
    var signature: String?
    var planet: String? //register planet name
    
    var items: [MainItem]?
    
    init() {
        
    }
//    init(_id: Int?, keyId: String?, pathIdex: Int?, coinType: Int?, symbol: String?, decimals: String?, hide: String?, address: String?, name: String?, balance: String?, signature: String?, planet: String?, items: [MainItem]?) {
//
//    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        _id         <- map["_id"]
        keyId       <- map["keyId"]
        pathIndex    <- map["pathIdex"]
        coinType    <- map["coinType"]
        symbol      <- map["symbol"]
        decimals    <- map["decimals"]
        hide        <- map["hide"] //Y,N
        address     <- map["address"]
        name        <- map["name"]
        balance     <- map["balance"]
        
        signature   <- map["signature"]
        planet      <- map["planet"]
        
        
    }
}


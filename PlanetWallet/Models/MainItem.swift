//
//  MainItem.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class MainItem: Mappable {
    
    var _id:Int?
    var keyId:String?
    var coinType:Int?
    var hide:String?
    var balance:String?
    var name:String?
    var symbol:String?
    var decimals:String?
    var img_path:String?
    var contract:String?
    
    var check:Bool?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    
    func getCoinType() -> Int{
        return coinType ?? -1
    }
    
    func getBalance()->String{
        return balance ?? "0"
    }
    
    func mapping(map: Map) {
        _id         <- map["_id"]
        keyId       <- map["keyId"]
        coinType    <- map["coinType"]
        hide        <- map["hide"]
        balance     <- map["balance"]
        name        <- map["name"]
        symbol      <- map["symbol"]
        decimals    <- map["decimals"]
        img_path    <- map["img_path"]
        contract    <- map["contract"]
    }
    
}

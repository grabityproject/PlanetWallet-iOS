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
    
    //network
    var signature: String?
    var planet: String? //register planet name
    
    var items: [MainItem]?
    var date: String?//Search date
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func getPrivateKey( keyPairStore:KeyPairStore, pinCode:[String] )->String{
        if let keyId = self.keyId{
            do {
                let hdKeyPair = try keyPairStore.getKeyPair(keyId: keyId, pin: pinCode)
                if let privateKey = hdKeyPair.privateKey{
                    return privateKey.hexString
                }
            } catch {
                print(error)
            }
        }
        return ""
    }
    
    func getMnemonic( keyPairStore:KeyPairStore, pinCode:[String] )->String{
        if let keyId = self.keyId, let pathIndex = pathIndex, let coinType = coinType{
            if pathIndex == -2{
                return KeyPairStore.shared.getPhrase(keyId: keyId, pinCode: pinCode)
            }else if pathIndex >= 0{
                return KeyPairStore.shared.getPhrase(coreCoinType: coinType, pinCode: pinCode)
            }else{
                return ""
            }
        }
        return ""
    }
    
    func getMainItem()->MainItem?{
        if let items = items, let item = items.first{
            return item
        }
        return nil
    }
    
    func mapping(map: Map) {
        _id         <- map["_id"]
        keyId       <- map["keyId"]
        pathIndex    <- map["pathIndex"]
        coinType    <- map["coinType"]
        symbol      <- map["symbol"]
        decimals    <- map["decimals"]
        hide        <- map["hide"] //Y,N
        address     <- map["address"]
        name        <- map["name"]
        
        signature   <- map["signature"]
        planet      <- map["planet"]
        
        date        <- map["date"]
        
    }
}


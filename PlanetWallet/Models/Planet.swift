//
//  Planet.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

enum Coin: Int {
    case BTC = 0
    case ETH = 60
}

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
    var date: String?//Search date
    
//    var type: Coin? {
//        guard let coinTypeInt = coinType else { return nil }
//
//        if coinTypeInt == CoinType.BTC.coinType {
//            return .BTC
//        }
//        else if coinTypeInt == CoinType.ETH.coinType || coinTypeInt == CoinType.ERC20.coinType {
//            return Coin(rawValue: coinTypeInt)
//        }
//
//        return nil
//    }
    
    init() {
        
    }
//    init(_id: Int?, keyId: String?, pathIdex: Int?, coinType: Int?, symbol: String?, decimals: String?, hide: String?, address: String?, name: String?, balance: String?, signature: String?, planet: String?, items: [MainItem]?) {
//
//    }
    
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
        balance     <- map["balance"]
        
        signature   <- map["signature"]
        planet      <- map["planet"]
        
        
    }
}


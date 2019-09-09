//
//  Tx.swift
//  PlanetWallet
//
//  Created by grabity on 12/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class Tx: Mappable {

    var type: String?
    var tx_id: String?
    var contract: String?
    var to: String?//address
    var to_planet: String?//name
    var from: String?
    var from_planet: String?
    var nonce: String?
    var amount: String?
    var gasPrice: String?
    var gasLimit: String?
    var fee: String?
    var coin: String?
    var symbol: String?
    var rawTransaction: String?
    var status: String?
    var created_at: String?
    var updated_at: String?
    
    var decimals: String?
    
    var url:String?
    
    var utxos: [UTXO]?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {

        type           <- map["type"]
        tx_id          <- map["tx_id"]
        contract       <- map["contract"]
        
        to             <- map["to"]
        to_planet      <- map["to_planet"]
        from           <- map["from"]
        from_planet    <- map["from_planet"]
        
        nonce          <- map["nonce"]
        amount         <- map["amount"]
        
        gasPrice       <- map["gasPrice"]
        gasLimit       <- map["gasLimit"]
        
        fee            <- map["fee"]
        
        coin           <- map["coin"]
        symbol         <- map["symbol"]
        
        rawTransaction <- map["rawTransaction"]
        status         <- map["status"]

        created_at     <- map["created_at"]
        updated_at     <- map["updated_at"]
        
        decimals       <- map["decimals"]
        
        utxos          <- map["utxos"]
        
        url            <- map["url"]
    }
    
    func formattedDate() -> String? {
        if let _createdAt = self.created_at, let createdAt = Int64(_createdAt) {
            
            return Utils.shared.changeDateFormat(date: Date(millis: createdAt),
                                                 afterFormat: .yyyyMMddHHmmss)
        }
        else {
            return nil
        }
    }
}


//
//  Tx.swift
//  PlanetWallet
//
//  Created by grabity on 12/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper
/*
{
    "tx_id": "72d94861f51d2fa618e38974ec314c947e976df3d3524b8b51ac21d7576ceb01",
    "contract": null,
    "to": "n1XYu73xiYzzPeeXNRighWHVRHsNrCXPAF",
    "from": "mqFWxipJXgovvC6jXqzACoiGNPA8EmJK7J",
    "nonce": null,
    "amount": "900000",
    "gasPrice": null,
    "gasLimit": null,
    "fee": 243,
    "coin": "BTC",
    "symbol": "BTC",
    "rawTransaction": "",
    "utxos": {
        "inputs": {
            "mqFWxipJXgovvC6jXqzACoiGNPA8EmJK7J": "3617161"
        },
        "outputs": {
            "n1XYu73xiYzzPeeXNRighWHVRHsNrCXPAF": "900000",
            "mqFWxipJXgovvC6jXqzACoiGNPA8EmJK7J": "2716918"
        }
    },
    "created_at": 1564390476,
    "updated_at": ""
}
 */
class Tx: Mappable {
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
//    var utxos: String?
    var created_at: String?
    var updated_at: String?
    
    /*
    //ETH init
    init(
        tx_id: String,
        contract: String,
        to: String, to_planet: String?,
        from: String, from_planet: String?,
        nonce: String,
        amount: String,
        gasPrice: String, gasLimit: String,
        coin: String, symbol: String,
        rawTransaction: String,
        created_at: Int64,
        updated_at: Int64
        ) {
        self.tx_id = tx_id
        self.contract = contract
        
        self.to = to
        self.to_planet = to_planet
        self.from = from
        self.from_planet = from_planet
        
        self.nonce = nonce
        self.amount = amount
        
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        
        self.fee = nil
        
        self.coin = coin
        self.symbol = symbol
        
        self.rawTransaction = rawTransaction
        self.utxos = nil
        self.created_at = created_at
        self.updated_at = updated_at
    }
    */
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
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
//        utxos          <- map["utxos"]
        created_at     <- map["created_at"]
        updated_at     <- map["updated_at"]
    }
}

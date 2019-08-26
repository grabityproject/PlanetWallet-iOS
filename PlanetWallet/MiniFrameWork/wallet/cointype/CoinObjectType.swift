//
//  CoinType.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct StructCoinType{
    
    let coinType:Int
    let name:String
    let coinName:String
    let defaultUnit:String?
    let minimumUnit:String?
    let precision: Int?
    
    init( coinType:Int, name:String, coinName:String, defaultUnit:String?, minimumUnit:String?, precision:Int? ) {
        self.coinType = coinType
        self.name = name
        self.coinName = coinName
        self.defaultUnit = defaultUnit
        self.minimumUnit = minimumUnit
        self.precision = precision
    }
    
    func description() -> String {
        
        if self.coinType == CoinType.BTC.coinType {
            return "BTC Universe"
        }
        else if self.coinType == CoinType.ETH.coinType {
            return "ETH Universe"
        }
        else {
            return ""
        }
    }
}

struct CoinType {
    static let NULL = StructCoinType(coinType: -1, name: "NULL", coinName: "Bitcoin", defaultUnit: "BTC", minimumUnit: "satoshi", precision: 1)
    static let BTC = StructCoinType(coinType: 0, name: "BTC", coinName: "Bitcoin", defaultUnit: "BTC", minimumUnit: "satoshi", precision: 8)
    static let ETH = StructCoinType(coinType: 60, name: "ETH", coinName: "Ethereum", defaultUnit: "ETH", minimumUnit: "wei", precision: 18)
    static let ERC20 = StructCoinType(coinType: -60, name: "ERC20", coinName: "ERC20", defaultUnit: nil, minimumUnit: nil, precision: nil)
    
    static func of(_ coinType:Int ) -> StructCoinType {
        switch coinType {
        case CoinType.BTC.coinType:
            return CoinType.BTC
        case CoinType.ETH.coinType:
            return CoinType.ETH
        case CoinType.ERC20.coinType:
            return CoinType.ERC20
        default:
            return CoinType.NULL
        }
    }
}

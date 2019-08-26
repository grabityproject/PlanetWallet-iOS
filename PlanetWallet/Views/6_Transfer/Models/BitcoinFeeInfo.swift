//
//  BitcoinFeeInfo.swift
//  PlanetWallet
//
//  Created by grabity on 26/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
/*
 "fastestFee": "36",
 "halfHourFee": "36",
 "hourFee": "4"
 */
struct BitcoinFeeInfo {
    enum step: Int {
        case FASTEST
        case HALF_HOUR
        case HOUR
    }
    
    public var fastest: Decimal = 0
    public var halfHour: Decimal = 0
    public var hour: Decimal = 0
    
    public func getTransactionFee(step: BitcoinFeeInfo.step) -> String? {
        switch step {
        case .FASTEST:      return CoinNumberFormatter.full.convertUnit(balance: fastest.toString(), from: .SATOSHI, to: .BIT)
        case .HALF_HOUR:    return CoinNumberFormatter.full.convertUnit(balance: halfHour.toString(), from: .SATOSHI, to: .BIT)
        case .HOUR:         return CoinNumberFormatter.full.convertUnit(balance: hour.toString(), from: .SATOSHI, to: .BIT)
        }
        
    }
}

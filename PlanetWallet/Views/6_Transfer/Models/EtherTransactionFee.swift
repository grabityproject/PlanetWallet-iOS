//
//  TransactionFee.swift
//  PlanetWallet
//
//  Created by grabity on 05/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct EtherTransactionFee {
    var gasPrice:Decimal = 0//GWEI
    var gasLimit:Decimal = 0
    
    public func getGasPriceWEI() -> String? {
        return CoinNumberFormatter.full.convertUnit(balance: gasPrice.toString(), from: .GWEI, to: .WEI)
    }
    
    public func getFeeGwei() -> String {
        return (gasPrice * gasLimit).toString()
    }
    
    public func getFeeETH() -> Decimal? {
        if let etherStr = CoinNumberFormatter.full.convertUnit(balance: getFeeGwei(), from: .GWEI, to: .ETHER) {
            return Decimal(string: etherStr)
        }
        
        return nil
    }
    
    public func getFeeWEI() -> String? {
        if let feeETH = getFeeETH() {
            return CoinNumberFormatter.full.convertUnit(balance: feeETH.toString(), from: .ETHER, to: .WEI)
        }
        return nil
    }
}

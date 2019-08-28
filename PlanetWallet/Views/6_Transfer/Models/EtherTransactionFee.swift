//
//  TransactionFee.swift
//  PlanetWallet
//
//  Created by grabity on 05/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct EtherTransactionFee {
    var gasPrice:Decimal = 0//WEI
    var gasLimit:Decimal = 0
    
    public func getGasPriceWEI() -> String {
        return gasPrice.toString()
    }
    
    public func getFeeWEI() -> String {
        return (gasPrice * gasLimit).toString()
    }
    
    public func getFeeETH() -> Decimal? {
        if let etherStr = CoinNumberFormatter.full.convertUnit(balance: getFeeWEI(), from: .WEI, to: .ETHER) {
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

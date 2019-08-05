//
//  TransactionFee.swift
//  PlanetWallet
//
//  Created by grabity on 05/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct TransactionFee {
    var gasPrice:Double = 0//GWEI
    var gasLimit:Int = 0
    
    public func getGasPriceWEI() -> Int {
        return Int(gasPrice * pow(10, 9))
    }
    
    public func getFeeGwei() -> Int {
        return Int(gasPrice * Double(gasLimit))
    }
    
    public func getFeeETH() -> Double? {
        return Utils.shared.gweiToETH(getFeeGwei())
    }
    
    public func getFeeWEI() -> String? {
        if let feeETH = getFeeETH() {
            return Utils.shared.ethToWEI(feeETH)
        }
        return nil
    }
}

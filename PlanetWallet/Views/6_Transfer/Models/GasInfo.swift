//
//  GasInfo.swift
//  PlanetWallet
//
//  Created by grabity on 05/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct GasInfo {
    enum Step: Int {
        case SAFE_LOW = 0
        case AVERAGE = 4
        case FAST = 8
        case FASTEST = 12
        case ADVANCED = 20
    }
    
    //Network를 통해 Transaction fee를 가져오지 못했을 경우 default value
    static let DEFAULT_GAS_PRICE: Decimal = 20
    static let DEFAULT_GAS_LIMIT: Decimal = 21000
    static let DEFAULT_GAS_LIMIT_ERC20: Decimal = 100000
    
    public var isToken = false
    
    public var safeLow: Decimal = 0
    public var average: Decimal = 0
    public var fast: Decimal = 0
    public var fastest: Decimal = 0
    
    public var advancedGasPrice: Decimal = 0
    public var advancedGasLimit: Decimal = 100000
    
    public func getTransactionFee(step: GasInfo.Step) -> TransactionFee {
        switch step {
        case .SAFE_LOW:     return TransactionFee(gasPrice: safeLow, gasLimit: getGasLimit())
        case .AVERAGE:      return TransactionFee(gasPrice: average, gasLimit: getGasLimit())
        case .FAST:         return TransactionFee(gasPrice: fast, gasLimit: getGasLimit())
        case .FASTEST:      return TransactionFee(gasPrice: fastest, gasLimit: getGasLimit())
        case .ADVANCED:     return TransactionFee(gasPrice: advancedGasPrice, gasLimit: advancedGasLimit)
        }
    }
    
    private func getGasLimit() -> Decimal {
        if isToken {
            return GasInfo.DEFAULT_GAS_LIMIT_ERC20
        }
        else {
            return GasInfo.DEFAULT_GAS_LIMIT
        }
    }
}








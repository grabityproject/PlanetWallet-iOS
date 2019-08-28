//
//  GasInfo.swift
//  PlanetWallet
//
//  Created by grabity on 05/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct EthereumFeeInfo {
    enum Step: Int {
        case SAFE_LOW = 0
        case AVERAGE
        case FAST
        case FASTEST
        case ADVANCED
        
        static let count: Int = {
            return 4
        }()
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
    
    public func getTransactionFee(step: EthereumFeeInfo.Step) -> EtherTransactionFee {
        switch step {
        case .SAFE_LOW:     return EtherTransactionFee(gasPrice: safeLow, gasLimit: getGasLimit())
        case .AVERAGE:      return EtherTransactionFee(gasPrice: average, gasLimit: getGasLimit())
        case .FAST:         return EtherTransactionFee(gasPrice: fast, gasLimit: getGasLimit())
        case .FASTEST:      return EtherTransactionFee(gasPrice: fastest, gasLimit: getGasLimit())
        case .ADVANCED:     return EtherTransactionFee(gasPrice: advancedGasPrice, gasLimit: advancedGasLimit)
        }
    }
    
    private func getGasLimit() -> Decimal {
        if isToken {
            return EthereumFeeInfo.DEFAULT_GAS_LIMIT_ERC20
        }
        else {
            return EthereumFeeInfo.DEFAULT_GAS_LIMIT
        }
    }
}








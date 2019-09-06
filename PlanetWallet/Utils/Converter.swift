//
//  Converter.swift
//  PlanetWallet
//
//  Created by grabity on 14/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import BigInt

public final class CoinNumberFormatter {
    
    static let short = CoinNumberFormatter(maximumDigit: 8)
    static let full = CoinNumberFormatter(maximumDigit: Int.max - 1)
    
    private init(maximumDigit : Int) {
        self.maximumFractionDigit = maximumDigit
    }
    
    private var maximumFractionDigit = Int.max - 1
    
    //MARK: - Interface
    func toMaxUnit(balance: String, precision: Int) -> String{
        guard let max = convertUnit(balance: balance, from: 0, to: precision) else { return balance }
        return max
    }
    // Only used for Coin
    func toMaxUnit(balance: String, coinType: StructCoinType) -> String{
        if let precision = coinType.precision{
            return toMaxUnit(balance: balance, precision:precision )
        }
        return balance
    }
    
    // include token
    func toMaxUnit(balance: String, item: MainItem) -> String{
        
        let coinType = item.getCoinType()
        
        if coinType == CoinType.BTC.coinType {
            return toMaxUnit(balance: balance, precision: CoinType.BTC.precision!)
        }
        else if coinType == CoinType.ETH.coinType {
            return toMaxUnit(balance: balance, precision: CoinType.ETH.precision!)
        }
        else if coinType == CoinType.ERC20.coinType {
            if let decimals = item.decimals, let decInt = Int(decimals){
                return toMaxUnit(balance: balance, precision:decInt)
            }
        }
        return balance
    }
    
    //MARK: - Interface
    func toMinUnit(balance: String, precision: Int) -> String{
        guard let max = convertUnit(balance: balance, from: precision, to: 0) else { return balance }
        return max
    }
    // Only used for Coin
    func toMinUnit(balance: String, coinType: StructCoinType) -> String{
        if let precision = coinType.precision{
            return toMinUnit(balance: balance, precision:precision )
        }
        return balance
    }
    
    // include token
    func toMinUnit(balance: String, item: MainItem) -> String{
        
        let coinType = item.getCoinType()
        
        if coinType == CoinType.BTC.coinType {
            return toMinUnit(balance: balance, precision: CoinType.BTC.precision!)
        }
        else if coinType == CoinType.ETH.coinType {
            return toMinUnit(balance: balance, precision: CoinType.ETH.precision!)
        }
        else if coinType == CoinType.ERC20.coinType {
            if let decimals = item.decimals, let decInt = Int(decimals){
                return toMinUnit(balance: balance, precision:decInt)
            }
        }
        return balance
    }
    
    func convertUnit(balance: String, from: Int, to: Int) -> String? {
        let exponent = from - to
        var balanceStr: String?
        
        if let balanceDecimal = Decimal(string: balance) {

            if exponent > 0 {
                balanceStr = (balanceDecimal * pow(10, exponent)).toString()
            }
            else {
                balanceStr = (balanceDecimal / pow(10, -exponent)).toString()
            }
        }
        
        if let str = balanceStr {
            if str.count > (maximumFractionDigit + 1) {
                let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
                balanceStr = String(str[..<index])
            }
        }
        
        return balanceStr
    }
        
}


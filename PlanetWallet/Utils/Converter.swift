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
    // Only used for Coin
    func toMaxUnit(balance: String, coinType: StructCoinType) -> String? {
        
        if coinType.coinType == CoinType.BTC.coinType {
            return toMaxUnit(balance: balance, item: BTC())
        }
        else if coinType.coinType == CoinType.ETH.coinType {
            return toMaxUnit(balance: balance, item: ETH())
        }
        
        return nil
    }
    
    // include token
    func toMaxUnit(balance: String, item: MainItem) -> String? {
        
        let coinType = item.getCoinType()
        
        if coinType == CoinType.BTC.coinType {
            return toBitString(satoshi: balance)
        }
        else if coinType == CoinType.ETH.coinType {
            return toEthString(wei: balance)
        }
        else if coinType == CoinType.ERC20.coinType {
            if let token = item as? ERC20, let decimalStr = token.decimals, let decimals = Int(decimalStr) {
                return toEthString(wei: balance, precesion: decimals)
            }
        }
        
        return nil
    }
    
    func convertUnit(balance: String, from: Int, to: Int) -> String? {
        let exponent = from - to
        if let balanceDecimal = Decimal(string: balance) {
            
            if exponent > 0 {
                return (balanceDecimal * pow(10, exponent)).toString()
            }
            else {
                return (balanceDecimal / pow(10, -exponent)).toString()
            }
            
        }
        
        return nil
    }
    
    func convertUnit(balance: String, from: EthereumUnit, to: EthereumUnit) -> String? {
        return self.convertUnit(balance: balance, from: from.value, to: to.value)
    }
    
    func convertUnit(balance: String, from: BitcoinUnit, to: BitcoinUnit) -> String? {
        return self.convertUnit(balance: balance, from: from.value, to: to.value)
    }
    
    //MARK: - Bitcoin
    private func toBitcoin(satoshi: String) -> Decimal? {
        guard let decimalSatoshi = Decimal(string: satoshi) else { return nil }
        var btcStr = (decimalSatoshi / pow(Decimal(10), CoinType.BTC.precision!)).toString()
        if btcStr.count > (maximumFractionDigit + 1) {
            let index = btcStr.index(btcStr.startIndex, offsetBy: (maximumFractionDigit + 1))
            btcStr = String(btcStr[..<index])
        }
        
        return Decimal(string: btcStr)
    }
    
    private func toBitString(satoshi: String) -> String? {
        let satoshiBInt = BigInt(stringLiteral: satoshi)
        guard let bitcoin = toBitcoin(satoshi: satoshiBInt.description) else { return nil }
        var str = bitcoin.description
        
        if str.count > (maximumFractionDigit + 1) {
            let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
            str = String(str[..<index])
        }
        
        return str
    }
    
    //MARK: - Ethereum
    /// Convert Wei(BInt) unit to Ether(Decimal) unit
    private func toEther(wei: String, precesion: Int = 18) -> Decimal? {
        
        guard let decimalWEI = Decimal(string: wei) else { return nil }
        
        return decimalWEI / pow(Decimal(10), precesion)
    }
    
    private func toEthString(wei: String, precesion: Int = 18) -> String? {
        let weiBInt = BigInt(stringLiteral: wei)
        guard let eth = toEther(wei: weiBInt.description, precesion: precesion) else { return  nil }
        var str = eth.description
        
        if str.count > (maximumFractionDigit + 1) {
            let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
            str = String(str[..<index])
        }
        
        return str
    }
    
    /// Convert Ether(Decimal) unit to Wei(BInt) unit
    private func toWei(ether: Decimal) -> BigInt? {
        guard let wei = BigInt((ether * pow(Decimal(10), CoinType.ETH.precision!)).description) else {
            return nil
        }
        return wei
    }
    
    /// Convert Ether(String) unit to Wei(BInt) unit
    private func toWei(ether: String) -> BigInt? {
        guard let decimalEther = Decimal(string: ether) else {
            return nil
        }
        return toWei(ether: decimalEther)
    }
    
    // Only used for calcurating gas price and gas limit.
    private func toWei(GWei: Int) -> Int {
        return GWei * 1000000000
    }
}

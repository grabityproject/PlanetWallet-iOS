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
    
    var maximumFractionDigit = Int.max - 1
    
    func toMaxUnit(balance: String, item: MainItem) -> String? {
        
        let coinType = item.getCoinType()
        
        if coinType == CoinType.BTC.coinType {
            return toBitString(satoshi: balance)
        }
        else if coinType == CoinType.ETH.coinType {
            return toEthString(wei: balance)
        }
        else if coinType == CoinType.ERC20.coinType {
            if let erc20 = item as? ERC20, let decimalsStr = erc20.decimals, let decimals = Int(decimalsStr) {
                return toEthString(wei: balance, precesion: decimals)
            }
        }
        
        return nil
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
        guard let ethStr = self.toEthString(wei: wei, precesion: precesion) else { return nil }
        
        return Decimal(string: ethStr)
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

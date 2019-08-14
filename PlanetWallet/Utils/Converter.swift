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
    
    //MARK: - Bitcoin
    func toBitcoin(satoshi: BigInt) -> Decimal? {
        guard let decimalSatoshi = Decimal(string: satoshi.description) else { return nil }
        return decimalSatoshi / pow(Decimal(10), 8)
    }
    
    func toBitString(satoshi: String) -> String? {
        let satoshiBInt = BigInt(stringLiteral: satoshi)
        guard let bitcoin = toBitcoin(satoshi: satoshiBInt) else { return nil }
        var str = bitcoin.description
        
        if str.count > (maximumFractionDigit + 1) {
            let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
            str = String(str[..<index])
        }
        
        return str
    }
    
    //MARK: - Ethereum
    /// Convert Wei(BInt) unit to Ether(Decimal) unit
    func toEther(wei: BigInt) -> Decimal? {
        guard let decimalWei = Decimal(string: wei.description) else { return nil }
        return decimalWei / pow(Decimal(10), 18)
    }
    
    func toEthString(wei: BigInt) -> String? {
        guard let eth = toEther(wei: wei) else { return  nil }
        var str = eth.description
        
        if str.count > (maximumFractionDigit + 1) {
            let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
            str = String(str[..<index])
        }
        
        return str
    }
    
    func toEthString(wei: String) -> String? {
        let weiBInt = BigInt(stringLiteral: wei)
        guard let eth = toEther(wei: weiBInt) else { return  nil }
        var str = eth.description
        
        if str.count > (maximumFractionDigit + 1) {
            let index = str.index(str.startIndex, offsetBy: (maximumFractionDigit + 1))
            str = String(str[..<index])
        }
        
        return str
    }
    
    /// Convert Ether(Decimal) unit to Wei(BInt) unit
    func toWei(ether: Decimal) -> BigInt? {
        guard let wei = BigInt((ether * pow(Decimal(10), 18)).description) else {
            return nil
        }
        return wei
    }
    
    /// Convert Ether(String) unit to Wei(BInt) unit
    func toWei(ether: String) -> BigInt? {
        guard let decimalEther = Decimal(string: ether) else {
            return nil
        }
        return toWei(ether: decimalEther)
    }
    
    // Only used for calcurating gas price and gas limit.
    func toWei(GWei: Int) -> Int {
        return GWei * 1000000000
    }
}

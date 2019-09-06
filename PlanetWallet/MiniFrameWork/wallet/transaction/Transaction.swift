//
//  Tx.swift
//  PlanetWallet
//
//  Created by 박상은 on 01/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import EthereumKit
import CryptoEthereumSwift
import BigInt

class Transaction{
    
    public var mainItem:MainItem!
    public var deviceKey:String?
    public var tx:Tx?
    
    init(_ mainItem:MainItem ) {
        self.mainItem = mainItem
    }
    
    public func setDeviceKey(_ deviceKey:String )->Transaction{
        self.deviceKey = deviceKey
        return self
    }
    
    public func setTx(_ tx:Tx )->Transaction{
        self.tx = tx
        return self
    }
    
    func estimateFee()->String {
        if let tx = tx {
            if mainItem.getCoinType() == CoinType.BTC.coinType{
                
                if let deviceKey = deviceKey{
                    return BtcRawTx.estimateFee(tx: tx, deviceKey: deviceKey)
                }
                
            }else if mainItem.getCoinType() == CoinType.ETH.coinType{
                
                print( "EthRawTx.estimateFee()" )
                return EthRawTx.estimateFee(tx: tx)
                
            }else if mainItem.getCoinType() == CoinType.ERC20.coinType{
                
                return Erc20RawTx.estimateFee(tx: tx)
                
            }
        }
        return String()
    }
    
    
    func getRawTransaction( privateKey:String )->String{
        if let tx = tx, let deviceKey = deviceKey {
        
            if mainItem.getCoinType() == CoinType.BTC.coinType {
                
                return BtcRawTx.generateRawTx(tx: tx, deviceKey: deviceKey, privateKey: privateKey)
                
            }else if mainItem.getCoinType() == CoinType.ETH.coinType {
                
                return EthRawTx.generateRawTx(tx: tx, deviceKey: deviceKey, privateKey: privateKey)
                
            }else if mainItem.getCoinType() == CoinType.ERC20.coinType {
                
                return Erc20RawTx.generateRawTx(tx: tx, erc20: mainItem, deviceKey: deviceKey, privateKey: privateKey)
                
            }
        }
        return String()
    }
    
}

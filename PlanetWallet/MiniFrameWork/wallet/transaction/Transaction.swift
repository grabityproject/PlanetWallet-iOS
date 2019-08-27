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

class Transaction : NetworkDelegate{
    
    public var mainItem:MainItem?

    public var deviceKey:String?
    
    public var fromAddress:String?
    public var toAddress:String?
    public var amount:String?
    public var gasPrice:String?
    public var gasLimit:String?
    public var nonce:String?
    public var data:String?
    
    public var utxos:[UTXO]?
    
    private var privateKey:String?
    
    var handler:((Bool,_ rawTx:String )->Void)?
    
    init(_ mainItem:MainItem ) {
        self.mainItem = mainItem
    }
    
    public func deviceKey(_ deviceKey:String )->Transaction{
        self.deviceKey = deviceKey
        return self
    }
    
    public func from(_ address:String )->Transaction{
        self.fromAddress = address
        return self
    }
    
    public func to(_ address:String )->Transaction{
        self.toAddress = address
        return self
    }
    
    public func value(_ value:String )->Transaction{
        self.amount = value
        return self
    }
    
    public func gasPrice(_ gasPrice:String )->Transaction{
        self.gasPrice = gasPrice
        return self
    }
    
    public func gasLimit(_ gasLimit:String )->Transaction{
        self.gasLimit = gasLimit
        return self
    }
    
    public func nonce(_ nonce:String )->Transaction{
        self.nonce = nonce
        return self
    }
    
    func getFee()->String {
        if self.mainItem?.getCoinType() == CoinType.BTC.coinType{
            
            return BtcRawTx.EstimateFee(tx: self)
        
        }else if mainItem?.getCoinType() == CoinType.ETH.coinType || mainItem?.getCoinType() == CoinType.ERC20.coinType{
            
            guard let gasPriceStr = self.gasPrice, let gasLimitStr = self.gasLimit, let gasPrice = Decimal(string: gasPriceStr), let gasLimit = Decimal(string: gasLimitStr) else { return String() }
            
            return (gasPrice * gasLimit).toString()
            
        }else{
            return "0"
        }
    }
    
    
    func getRawTransaction( privateKey:String, _ handler:@escaping (Bool,_ rawTx:String )->Void ){
        self.handler = handler;
        self.privateKey = privateKey;
        
        if let fromAddress = self.fromAddress, let deviceKey = self.deviceKey, let mainItem = mainItem{
            
            if mainItem.getCoinType() == CoinType.BTC.coinType {
              
                if let utxos = self.utxos{
                    
                    self.utxos = BtcRawTx.utxoSort(utxos)
                    handler(true, BtcRawTx.generateRawTx(tx: self, privateKey: privateKey))
                    
                }else{
                    
                    Get(self).action(Route.URL("utxo", "list", CoinType.BTC.name ,fromAddress), requestCode: CoinType.BTC.coinType, resultCode: 0, data: nil, extraHeaders: ["device-key":deviceKey])
                    
                }
                
            }else if mainItem.getCoinType() == CoinType.ETH.coinType || mainItem.getCoinType() == CoinType.ERC20.coinType{
            
                Get(self).action(Route.URL("nonce", "ETH", fromAddress), requestCode: CoinType.ETH.coinType, resultCode: 0, data: nil, extraHeaders: ["device-key":deviceKey])
                
            }
            
        }
        
    }
    
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if let dict = dictionary{
                
            if requestCode == CoinType.BTC.coinType {
                
                if let isSuccess = dict["success"] as? Bool, let resultData = dict["result"] as? [[String:Any]]{
                    if isSuccess{
                        var utxos = [UTXO]();
                        resultData.forEach { (item) in
                            utxos.append(UTXO(JSON: item)!)
                        }
                        self.utxos = BtcRawTx.utxoSort(utxos)
                        
                        if let handler = handler, let privateKey = privateKey{
                            handler(true, BtcRawTx.generateRawTx(tx: self, privateKey: privateKey))
                        }
                        
                    }
                }
                
            }else if requestCode == CoinType.ETH.coinType{
                if let isSuccess = dict["success"] as? Bool, let resultData = dict["result"] as? [String:Any]{
                    if isSuccess, let nonce = resultData["nonce"] as? String{
                        self.nonce = nonce
                        
                        if let handler = handler, let privateKey = privateKey, let mainItem = mainItem{
                            if( CoinType.ETH.coinType == mainItem.getCoinType() ){
                                handler(true, EthRawTx.generateRawTx(tx: self, privateKey: privateKey))
                            }else if( CoinType.ERC20.coinType == mainItem.getCoinType() ){
                                if mainItem is ERC20 {
                                    handler(true, Erc20RawTx.generateRawTx(tx: self, erc20: mainItem as! ERC20, privateKey: privateKey))
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}

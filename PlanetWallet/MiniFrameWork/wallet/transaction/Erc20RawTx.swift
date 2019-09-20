//
//  Erc20RawTx.swift
//  PlanetWallet
//
//  Created by 박상은 on 26/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import EthereumKit
import CryptoEthereumSwift

class Erc20RawTx{
    
    public static func generateRawTx( tx:Tx, erc20:MainItem, deviceKey:String ,privateKey:String )->String{
        
        if let wei = tx.amount, let to = tx.to, let gasPrice = tx.gasPrice, let gasLimit = tx.gasLimit,
            let contract = erc20.contract {
            
            var nonce = String()
            if tx.nonce == nil {
                nonce = getNonce(tx: tx, deviceKey: deviceKey)
            }else{
                nonce = tx.nonce!
            }
            
            if nonce.isEmpty { return String() }
            
            
            let rawTransaction = RawTransaction(
                wei: "0",
                to: contract,
                gasPrice: Int(gasPrice)!,
                gasLimit: Int(gasLimit)!,
                nonce: Int(nonce)!,
                data: Data(hex:generateERC20Data(to: to, value: wei))
            )
            
            let signer = EIP155Signer(chainID: TESTNET ? 3 : 1) // TestNet EIP155
            let signiture = try! CryptoEthereumSwift.Crypto.sign(
                try! signer.hash(rawTransaction: rawTransaction),
                privateKey: Data(hex: privateKey)
            )
            
            
            let (r, s, v) = signer.calculateRSV(signature: signiture)
            
            let data = try! RLP.encode([
                rawTransaction.nonce,
                rawTransaction.gasPrice,
                rawTransaction.gasLimit,
                rawTransaction.to.data,
                rawTransaction.value,
                rawTransaction.data,
                v, r, s
                ])
            
            
            return data.toHexString()
            
        }else{
            return String()
        }
    }
    
    public static func estimateFee( tx:Tx )->String{
        
        var gasPriceString:String = "10000000000"
        var gasLimitString:String = "100000"
        
        if tx.gasPrice != nil {
            gasPriceString = tx.gasPrice!
        }else{
            tx.gasPrice = gasPriceString
        }
        
        if tx.gasLimit != nil {
            gasLimitString = tx.gasLimit!
        }else{
            tx.gasLimit = gasLimitString
        }
        
        if
            let gasPrice = Decimal(string:gasPriceString), let gasLimit = Decimal(string:gasLimitString){
            tx.fee = (gasPrice*gasLimit).toString()
            return (gasPrice*gasLimit).toString()
        }
        return Decimal(10000000000 * 100000).toString()
    }
    
    static func generateERC20Data( to:String, value:String )->String{
        let prefix = "0xa9059cbb"
        let toAddress = to.replace(target: "0x", withString: "").replace(target: "0X", withString: "").leftPadding(toLength: 64, withPad: "0")
        let amount = BInt(value, radix: 10)!.asString(withBase: 16).leftPadding(toLength: 64, withPad: "0")
        return "\(prefix)\(toAddress)\(amount)"
    }
    
    
    private static func getNonce( tx:Tx, deviceKey:String )->String{
        if let fromAddress = tx.from{
            let response = Get(nil).response(Route.URL("nonce", "ETH", fromAddress), requestCode: 0, resultCode: 0, data: nil, extraHeaders: ["device-key":deviceKey])
            
            let success = response["success"] as! Bool
            let dict = response["dictionary"] as! [String:Any]
            
            if success {
                if let isSuccess = dict["success"] as? Bool, let resultData = dict["result"] as? [String:Any]{
                    if isSuccess, let nonce = resultData["nonce"] as? String{
                        return nonce
                    }
                }
            }
        }
        return String()
    }
    
}

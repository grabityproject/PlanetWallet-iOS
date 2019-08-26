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
    
    public static func generateRawTx( tx:Transaction, erc20:ERC20, privateKey:String )->String{
        
        if let wei = tx.amount, let to = tx.toAddress, let gasPrice = tx.gasPrice, let gasLimit = tx.gasLimit, let nonce = tx.nonce,
            let contract = erc20.contract {
            
            let rawTransaction = RawTransaction(
                wei: "0",
                to: contract,
                gasPrice: Int(gasPrice)!,
                gasLimit: Int(gasLimit)!,
                nonce: Int(nonce)!,
                data: Data(hex:generateERC20Data(to: to, value: wei))
            )
            
            let signer = EIP155Signer(chainID: 3) // TestNet EIP155
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
    
    static func generateERC20Data( to:String, value:String )->String{
        let prefix = "0xa9059cbb"
        let toAddress = to.replace(target: "0x", withString: "").replace(target: "0X", withString: "").leftPadding(toLength: 64, withPad: "0")
        let amount = BInt(value, radix: 10)!.asString(withBase: 16).leftPadding(toLength: 64, withPad: "0")
        return "\(prefix)\(toAddress)\(amount)"
    }
    
}

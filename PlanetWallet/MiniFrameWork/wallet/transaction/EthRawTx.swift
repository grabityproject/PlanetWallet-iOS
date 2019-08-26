//
//  EthRawTx.swift
//  
//
//  Created by 박상은 on 26/08/2019.
//

import Foundation
import EthereumKit
import CryptoEthereumSwift

class EthRawTx{
    
    public static func generateRawTx( tx:Transaction, privateKey:String )->String{
        
        if let wei = tx.amount, let to = tx.toAddress, let gasPrice = tx.gasPrice, let gasLimit = tx.gasLimit, let nonce = tx.nonce{
            let rawTransaction = RawTransaction(
                wei: wei,
                to: to,
                gasPrice: Int(gasPrice)!,
                gasLimit: Int(gasLimit)!,
                nonce: Int(nonce)!,
                data: Data()
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
    
}

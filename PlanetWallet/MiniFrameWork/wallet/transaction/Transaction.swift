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

class Transaction : NetworkDelegate{
    
    private var mainItem:MainItem?

    private var deviceKey:String?
    
    private var fromAddress:String?
    private var toAddress:String?
    private var amount:String?
    private var gasPrice:String?
    private var gasLimit:String?
    private var nonce:String?
    private var data:String?
    
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
    
    
    func getRawTransaction( privateKey:String, _ handler:@escaping (Bool,_ rawTx:String )->Void ){
        self.handler = handler;
        self.privateKey = privateKey;
        
        if let fromAddress = self.fromAddress, let deviceKey = self.deviceKey{

            Get(self).action(Route.URL("nonce", "ETH", fromAddress), requestCode: 0, resultCode: 0, data: nil, extraHeaders: ["device-key":deviceKey])
            
        }
        
    }
    
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if let dict = dictionary{
            if let isSuccess = dict["success"] as? Bool, let resultData = dict["result"] as? [String:Any]{
                if isSuccess, let nonce = resultData["nonce"] as? String{
                    
                    if let mainItem = mainItem,
                        let handler = handler,
                        let privateKey = privateKey,
                        let toAddress = toAddress,
                        let amount = amount,
                        let gasPrice = gasPrice, let gasLimit = gasLimit{
                        
                        if( CoinType.BTC.coinType == mainItem.getCoinType() ){
                            
                            handler(false, "0x")
                            
                        }else if( CoinType.ETH.coinType == mainItem.getCoinType() ){
                            
                            handler(true, generateEthRawTx(wei: amount, to: toAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, privateKey: privateKey));
                            
                        }else if( CoinType.ERC20.coinType == mainItem.getCoinType() ){

                            handler(true, generateERC20RawTx(wei: amount, to: toAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, privateKey: privateKey));

                        }
                        
                    }
                }
            }
        }
    }
    
    func generateERC20Data( to:String, value:String )->String{
        let prefix = "0xa9059cbb"
        let toAddress = to.replace(target: "0x", withString: "").replace(target: "0X", withString: "").leftPadding(toLength: 64, withPad: "0")
        let amount = BInt(value, radix: 10)!.asString(withBase: 16).leftPadding(toLength: 64, withPad: "0")
        return "\(prefix)\(toAddress)\(amount)"
    }
    
    func generateERC20RawTx( wei:String, to:String, gasPrice:String, gasLimit:String, nonce:String , privateKey:String )->String{
        
        if let erc20 = mainItem as? ERC20, let contract = erc20.contract{
            
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
            return "0x"
        }
        
    }
    
    func generateEthRawTx( wei:String, to:String, gasPrice:String, gasLimit:String, nonce:String , privateKey:String )->String{

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
    }
    
}

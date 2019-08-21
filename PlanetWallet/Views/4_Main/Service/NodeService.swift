//
//  NodeService.swift
//  PlanetWallet
//
//  Created by 박상은 on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol NodeServiceDelegate {
    func onBalance(_ planet:Planet,_ balance: String )
    func onTokenBalance(_ planet:Planet,_ tokenList:[MainItem] )
    func onTxList(_ planet:Planet,_ txList:[Tx] )
}

class NodeService: NSObject {
    
    public static let shared:NodeService = NodeService()

    private var networkDelegates:[Int:Node] = [Int:Node]()
    
    var planet:Planet?
    var delegate:NodeServiceDelegate?
    
    override init() {
        super.init()
        networkDelegates[CoinType.BTC.coinType] = BtcNetworkDelegate()
        networkDelegates[CoinType.ETH.coinType] = EthNetworkDelegate()
    }
    
    func getBalance(_ planet:Planet ){
        self.planet = planet;
        
        if let coinType = planet.coinType, let id = planet._id{
            
            networkDelegates[coinType]?.planet = planet
            networkDelegates[coinType]?.delegate = delegate
            Get(networkDelegates[coinType]).action(Route.URL("balance", CoinType.of(coinType).name, planet.address!), requestCode: 0, resultCode: id, data: nil, extraHeaders: ["device-key":DEVICE_KEY])
            
        }
        
    }
    
    
    func getMainList(_ planet:Planet ){
        
        if let coinType = planet.coinType, let id = planet._id{
            
            if coinType == CoinType.BTC.coinType {
                
                networkDelegates[coinType]?.planet = planet
                networkDelegates[coinType]?.delegate = delegate
                Get(networkDelegates[coinType]).action(Route.URL("tx", "list" , CoinType.BTC.name, planet.address!), requestCode: 1, resultCode: id, data: nil, extraHeaders: ["device-key":DEVICE_KEY])
                
            }else if coinType == CoinType.ETH.coinType {
                
                guard let items = planet.items else { return }
                
                networkDelegates[coinType]?.parallelTaskCount = items.count
                
                for i in 0..<items.count{
                    
                    let item = items[i]
                 
                    if item.getCoinType() == CoinType.ETH.coinType {
                        
                        Get( networkDelegates[coinType] ).action(Route.URL("balance", "ETH" , planet.address!), requestCode: id, resultCode: i, data: nil, extraHeaders: ["device-key":DEVICE_KEY])
                        
                    } else if item.getCoinType() == CoinType.ERC20.coinType {
                        
                        if let item = item as? ERC20, let symbol = item.symbol {
                            
                            Get( networkDelegates[coinType] ).action(Route.URL("balance", symbol , planet.address!), requestCode: id, resultCode: i, data: nil, extraHeaders: ["device-key":DEVICE_KEY])
                            
                        }
                    }
                    
                }
            }
        }
    }
}

class EthNetworkDelegate:Node{
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {

        if let planet = planet, let id = planet._id {
            if requestCode > 0 && id == requestCode {
                parallelTaskCount = parallelTaskCount - 1
            }
        }
        
        if success {
            
            if let dict = dictionary {
                
                if requestCode == 0 {
                    if let json = dict["result"] as? [String: Any]{
                        let planet = Planet(JSON: json)
                        delegate?.onBalance(self.planet!, planet!.balance! )
                    }
                }else {
                    
                    if let planet = planet, let id = planet._id  {
                        
                        if requestCode > 0 && id == requestCode {
                            
                            if let json = dict["result"] as? [String: Any]{
                                if let p = Planet(JSON: json), let balance = p.balance {
                                    
                                    if planet.items![resultCode].getCoinType() == CoinType.ETH.coinType {
                                        
                                        ( planet.items![resultCode] as! ETH ).balance = balance
                                        
                                    }else if planet.items![resultCode].getCoinType() == CoinType.ERC20.coinType {
                                        
                                        ( planet.items![resultCode] as! ERC20 ).balance = balance
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        if parallelTaskCount == 0 {
                            delegate?.onTokenBalance(planet, planet.items!)
                        }
                    }
                }
                
            }
            
        }
        
    }
}

class BtcNetworkDelegate:Node{
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        if success {
            
            if let dict = dictionary {
                
                if requestCode == 0 {
                    
                    if let json = dict["result"] as? [String: Any]{
                    
                        let planet = Planet(JSON: json)
                        delegate?.onBalance(self.planet!, planet!.balance! )
                        
                    }
                    
                }
                else if requestCode == 1 {
                    
                    if let items = dict["result"] as? [[String: Any]]{
                        
                        var txList = [Tx]();
                        
                        items.forEach { (json) in
                            txList.append(Tx(JSON: json)!)
                        }
                        delegate?.onTxList(self.planet!, txList)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
}


class Node:NetworkDelegate{
    
    var planet:Planet?
    var delegate:NodeServiceDelegate?
    
    var parallelTaskCount:Int = 0
    
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
    }
}

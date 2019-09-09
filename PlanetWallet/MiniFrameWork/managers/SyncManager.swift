//
//  SyncManager.swift
//  PlanetWallet
//
//  Created by 박상은 on 18/07/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

enum SyncType{
    case PLANET
    case ERC20
}

protocol SyncDelegate {
    func sync(_ syncType:SyncType ,didSyncComplete complete:Bool, isUpdate:Bool )
//    optional func sync(_ syncType:SyncType ,didSyncComplete complete:Bool, isUpdate:Bool )
}

class SyncManager: NetworkDelegate{
    
    static let shared = SyncManager()
    
    var planetList = [Planet]()
    
    var delegate:SyncDelegate?
    
    public func syncPlanet(_ delegate:SyncDelegate){
        planetList = PlanetStore.shared.list()
        self.syncPlanet(delegate, list: planetList)
    }
    
    public func syncRecentSearch(_ delegate:SyncDelegate, planet:Planet, symbol:String){
        if let keyId =  planet.keyId {
            planetList = SearchStore.shared.list(keyId: keyId, symbol: symbol)
            self.syncPlanet(delegate, list: planetList, 1)
        }
    }
    
    public func syncPlanet(_ delegate:SyncDelegate, list: [Planet], _ isSyncPlanet:Int = 0)
    {
        self.delegate = delegate
        
        var addresses:[String:String] = [String:String]()
        var ethCount = 0
        var bitCount = 0
        list.forEach { (planet) in
            if let address = planet.address, let coinType = planet.coinType {
                if( coinType == CoinType.ETH.coinType ){
                    addresses["\(CoinType.ETH.name)[\(ethCount)]"] = address
                    ethCount = ethCount + 1
                }else if( coinType == CoinType.BTC.coinType ){
                    addresses["\(CoinType.BTC.name)[\(bitCount)]"] = address
                    bitCount = bitCount + 1
                }
            }
        }
        Post(self).action(Route.URL("sync", "planets"), requestCode: isSyncPlanet, resultCode: 0, data: addresses)
    }
    
    
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        var isUpdated = false
        if( requestCode == 0 ){
            guard let dict = dictionary,
                let success = dict["success"] as? Bool else {
                    delegate?.sync(.PLANET, didSyncComplete: false, isUpdate: false)
                    return
            }
            
            if success {
                //SyncManager에서 success는 true면서 result가 비었을 경우에는 complete를 true으로 변경한다.
                guard let data = dict["result"] as? Dictionary<String, Dictionary<String, Any>> else {
                    delegate?.sync(.PLANET, didSyncComplete: true, isUpdate: false)
                    return
                }
                
                planetList.forEach { (planet) in
                    if let address = planet.address, let syncItem = data[address.lowercased()], let syncItemName = syncItem["name"] as? String {
                        if planet.name != syncItemName {
                            planet.name = syncItemName
                            PlanetStore.shared.update(planet);
                            isUpdated = true
                        }
                    }
                }
                
                delegate?.sync(.PLANET, didSyncComplete: true, isUpdate: isUpdated)
            }
            else {
                delegate?.sync(.PLANET, didSyncComplete: false, isUpdate: false)
            }
        }else if requestCode == 1 {
            
            guard let dict = dictionary, let success = dict["success"] as? Bool else {
                delegate?.sync(.PLANET, didSyncComplete: false, isUpdate: false)
                return
            }
            
            var didSyncCompleted = false
            var isUpdated = false
            
            if success {
                didSyncCompleted = true
                
                if let data = dict["result"] as? Dictionary<String, Dictionary<String, Any>> {
                    
                    planetList.forEach { (planet) in
                        if let address = planet.address, let syncItem = data[address.lowercased()], let syncItemName = syncItem["name"] as? String {
                            if planet.name != syncItemName {
                                planet.name = syncItemName
                                planet.date = NSDate().timeIntervalSince1970.toString()
                                SearchStore.shared.update(planet)
                                isUpdated = true
                            }
                            else {
                                isUpdated = false
                            }
                        }
                        
                        delegate?.sync(.PLANET, didSyncComplete: didSyncCompleted, isUpdate: isUpdated)
                        return
                    }
                    
                }
            }
            
            delegate?.sync(.PLANET, didSyncComplete: didSyncCompleted, isUpdate: isUpdated)
        }
    }
    
}

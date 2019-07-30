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
}

class SyncManager: NetworkDelegate{
    
    static let shared = SyncManager()
    
    var planetList = [Planet]()
    
    var delegate:SyncDelegate?
    
    public func syncPlanet(_ delegate:SyncDelegate){
        
        self.delegate = delegate
        
        planetList = PlanetStore.shared.list()
        var addresses:[String:String] = [String:String]()
        var ethCount = 0
        var bitCount = 0
        planetList.forEach { (planet) in
            if let address = planet.address, let symbol = planet.symbol{
                if( symbol == CoinType.ETH.name ){
                    addresses["\(symbol)[\(ethCount)]"] = address
                    ethCount = ethCount + 1
                }else if( symbol == CoinType.BTC.name ){
                    addresses["\(symbol)[\(bitCount)]"] = address
                    bitCount = bitCount + 1
                }
            }
        }
        Post(self).action(Route.URL("sync", "planets"), requestCode: 0, resultCode: 0, data: addresses)
    }
    
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if( requestCode == 0 ){
            guard let dict = dictionary,
                let success = dict["success"] as? Bool,
                let data = dict["result"] as? Dictionary<String, Dictionary<String, String>> else { return }
            guard success else { return }
            
            var isUpdated = false
            planetList.forEach { (planet) in
                if let address = planet.address, let syncItem = data[address] {
                    if planet.name != syncItem["name"] {
                        planet.name = syncItem["name"]
                        PlanetStore.shared.update(planet);
                        isUpdated = true
                    }
                }
            }
            delegate?.sync(.PLANET, didSyncComplete: true, isUpdate: isUpdated)
        }
    }
    
    
    
}

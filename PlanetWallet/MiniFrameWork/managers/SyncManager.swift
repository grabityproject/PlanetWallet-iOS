//
//  SyncManager.swift
//  PlanetWallet
//
//  Created by 박상은 on 18/07/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

enum syncType{
    case Planet
    case ERC20
}

protocol SyncDelegate {
    func sync(_ syncType:syncType ,didSyncComplete complete:Bool, isUpdate:Bool )
}

class SyncManager: NetworkDelegate{
    
    static let shared = SyncManager()
    
    var planetList = [Planet]()
    
    var delegate:SyncDelegate?
    
    public func syncPlanet(_ delegate:SyncDelegate){
        
        self.delegate = delegate
        
        planetList = PlanetStore.shared.list()
        var addresses:[String:String] = [String:String]()
        var count = 0;
        planetList.forEach { (planet) in
            if let address = planet.address{
                addresses["addresses[\(count)]"] = address
                count = count + 1
            }
        }
        Post(self).action(Route.URL("planet", "sync"), requestCode: 0, resultCode: 0, data: addresses)
    }
 
    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if( requestCode == 0 ){
            if let dict = dictionary{
                if let success:Bool = dict["success"] as? Bool, let data:Dictionary<String, Dictionary<String, String>> = dict["result"] as? Dictionary<String, Dictionary<String, String>>{
                    if success{
                        var isUpdated = false;
                        planetList.forEach { (planet) in
                            if let address = planet.address{
                                if let syncItem  = data[address]{
                                    if planet.name != syncItem["name"]{
                                        planet.name = syncItem["name"]
                                        PlanetStore.shared.update(planet);
                                        isUpdated = true
                                    }
                                }
                            }
                        }
                        if let delegate = delegate{
                            delegate.sync(.Planet, didSyncComplete: true, isUpdate: isUpdated)
                        }
                    }
                }
            }
        }
    }
}

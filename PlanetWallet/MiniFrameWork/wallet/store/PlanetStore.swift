//
//  PlanetStore.swift
//  PCWF-SAMPLE
//
//  Created by 박상은 on 27/06/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import UIKit

class PlanetStore {

    static let shared:PlanetStore = PlanetStore()
    var m:Dictionary<String, Planet> = [String:Planet]()

    init() {
        do {
            let planets = try PWDBManager.shared.select(Planet.self)
            planets.forEach { (planet) in
                if let keyId = planet.keyId{
                    m[keyId] = planet
                }
            }
        } catch {
            print(error)
        }
    }
    
    func get(_ keyId:String)->Planet?{
        return m[keyId]
    }
    
    func list(_ symbol:String = "", _ containsHide:Bool = true )->[Planet]{
        var condition = ""
        
        if symbol != ""{
            condition = "symbol='\(symbol)'"
        }
        
        if !containsHide {
            if condition == "" {
                condition = "hide = 'N'"
            }
            else {
                condition = "\(condition) AND hide = 'N'"
            }
        }
        
        do {
            let planets = try PWDBManager.shared.select( Planet.self, "Planet", condition )
            return planets
        } catch {
            print(error)
            return [Planet]()
        }
    }
    
    func save(_ planet:Planet ){
        if let keyId = planet.keyId{
            if m[keyId] == nil {
                _ = PWDBManager.shared.insert(planet)
                
                let mainItem = MainItem( );
                mainItem.keyId = planet.keyId;
                mainItem.coinType = planet.coinType;
                mainItem.balance = "0";
                mainItem.hide = "N" ;
                mainItem.name = CoinType.of( planet.coinType! ).coinName;
                mainItem.symbol = CoinType.of( planet.coinType! ).name;
                _ = PWDBManager.shared.insert( mainItem );
                
                m[keyId] = planet
            }
        }
    }
    
    func update(_ planet:Planet ){
        if let keyId = planet.keyId{
            if m[keyId] != nil {
                _ = PWDBManager.shared.update(planet, "keyId = '\(keyId)'")
                m[keyId] = planet
            }
        }
    }
    
    func delete(_ planet:Planet ){
        if let keyId = planet.keyId{
            if m[keyId] != nil {
                _ = PWDBManager.shared.delete(planet, "keyId = '\(keyId)'")
                m.removeValue(forKey: keyId)
            }
        }
    }
    
}

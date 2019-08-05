//
//  PlanetStore.swift
//  PCWF-SAMPLE
//
//  Created by 박상은 on 27/06/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import UIKit

class ERC20Store {
    
    static let shared:ERC20Store = ERC20Store()
    
    init() { }
    
    func list(_ keyId:String, _ containsHide:Bool = true )->[ERC20]{
        var condition = "keyId='\(keyId)'"
        
        if !containsHide {
            condition = "\(condition) AND hide='N'"
        }
        
        do {
            let tokens = try PWDBManager.shared.select( ERC20.self, "ERC20", condition )
            return tokens
        } catch {
            print(error)
            return [ERC20]()
        }
    }
    
    func save(_ erc20:ERC20 ){
        if let keyId = erc20.keyId, let contract = erc20.contract{
            let seleted = try! PWDBManager.shared.select(ERC20.self, "ERC20", "keyId = '\(keyId)' AND contract = '\(contract)'")
            
            if seleted.count == 0{
                _ = PWDBManager.shared.insert(erc20)
            }else{
                update(erc20)
            }
        }
    }
    
    func update(_ erc20:ERC20 ){
        if let keyId = erc20.keyId, let contract = erc20.contract{
            _ = PWDBManager.shared.update(erc20, "keyId = '\(keyId)' AND contract = '\(contract)'")
        }
    }
}

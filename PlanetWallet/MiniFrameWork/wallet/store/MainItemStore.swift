//
//  PlanetStore.swift
//  PCWF-SAMPLE
//
//  Created by 박상은 on 27/06/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import UIKit

class MainItemStore {
    
    static let shared:MainItemStore = MainItemStore()
    
    init() { }
    
    func list(_ keyId:String, _ containsHide:Bool = true )->[MainItem]{
        var condition = "keyId='\(keyId)'"
        
        if !containsHide {
            condition = "\(condition) AND hide='N'"
        }
        
        do {
            let tokens = try PWDBManager.shared.select( MainItem.self, "MainItem", condition )
            return tokens
        } catch {
            return [MainItem]()
        }
    }
    
    
    func save(_ mainItem:MainItem ){
        if let _id = mainItem._id {
            let seleted = try! PWDBManager.shared.select(MainItem.self, "MainItem", "_id = '\(_id)'")
            
            if seleted.count == 0{
                _ = PWDBManager.shared.insert(mainItem)
            }else{
                update(mainItem)
            }
            
        }else{
            update(mainItem)
        }
    }
    
    func update(_ mainItem:MainItem ){
        if let _id = mainItem._id{
            _ = PWDBManager.shared.update(mainItem, "_id = '\(_id)'")
        }
    }
    
    
    func tokenSave(_ mainItem:MainItem ){
        if let keyId = mainItem.keyId, let contract = mainItem.contract{
            let seleted = try! PWDBManager.shared.select(MainItem.self,  "MainItem", "keyId = '\(keyId)' AND contract = '\(contract)'")
            
            if seleted.count == 0{
                _ = PWDBManager.shared.insert(mainItem)
            }else{
                tokenUpdate(mainItem)
            }
        }
    }
    func tokenUpdate(_ mainItem:MainItem ){
        if let keyId = mainItem.keyId, let contract = mainItem.contract{
            _ = PWDBManager.shared.update(mainItem, "keyId = '\(keyId)' AND contract = '\(contract)'")
        }
    }
}

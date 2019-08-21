//
//  SearchStore.swift
//  PlanetWallet
//
//  Created by grabity on 09/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class SearchStore {
    static let TABLE_NAME = "Search"
    static let shared = SearchStore()
    
    
    func list(keyId: String, symbol: String, descending: Bool = true) -> [Planet]{
        if descending {
            return try! PWDBManager.shared.select(Planet.self,
                                                  SearchStore.TABLE_NAME,
                                                  "keyId = '\(keyId)' AND symbol='\(symbol)'", "date DESC")
        }
        else {
            return try! PWDBManager.shared.select(Planet.self,
                                                  SearchStore.TABLE_NAME,
                                                  "keyId = '\(keyId)' AND symbol='\(symbol)'")
        }
    }
    
    func insert(keyId: String, symbol: String, toPlanet: Planet) {
        
        //1. 중복 검사 -> update date column
        //2. size 검사 (최대 20개) -> 넘을 경우 가장 오래된 record삭제
        guard let toName = toPlanet.name, let toAddress = toPlanet.address else { return }
        
        var isValid = true
        
        let list = self.list(keyId: keyId, symbol: symbol, descending: false)
        
        let date = NSDate().timeIntervalSince1970.toString()
        
        list.forEach { (recent) in
            if let name = recent.name, let toInsertName = toPlanet.name {
                if name == toInsertName {
                    isValid = false
                    _ = PWDBManager.shared.update(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, date: date),
                                                  SearchStore.TABLE_NAME,
                                                  "_id='\(recent._id!)'")
//                    _ = PWDBManager.shared.delete(recent, SearchStore.TABLE_NAME, "_id='\(recent._id!)'")
//                    _ = PWDBManager.shared.insert(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, date: date),
//                                                  SearchStore.TABLE_NAME)
                }
            }
            else {
                if (recent.address == toPlanet.address) {
                    isValid = false
                    recent.date = date
                    _ = PWDBManager.shared.update(recent, SearchStore.TABLE_NAME, "_id='\(recent._id!)'")
//                    _ = PWDBManager.shared.delete(recent, SearchStore.TABLE_NAME, "_id='\(recent._id!)'")
//                    _ = PWDBManager.shared.insert(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, date: date),
//                                                  SearchStore.TABLE_NAME)
                }
            }
        }
        
        if list.count >= 20 && isValid {
            
            for i in 0..<(list.count-20)+1 {
                if let idToDelete = list[i]._id {
                    _ = PWDBManager.shared.delete(list[i], SearchStore.TABLE_NAME, "_id='\(idToDelete)'")
                }
            }
        }
        
        if isValid {
            _ = PWDBManager.shared.insert(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, date: date), SearchStore.TABLE_NAME)
        }
    }
    
    func delete(_ toDeleteItem: Planet) {
        if let idToDelete = toDeleteItem._id {
            _ = PWDBManager.shared.delete(toDeleteItem, SearchStore.TABLE_NAME, "_id='\(idToDelete)'")
        }
    }
}

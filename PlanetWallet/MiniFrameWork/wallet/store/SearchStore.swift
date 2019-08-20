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
                                                  "keyId = '\(keyId)' AND symbol='\(symbol)'", "_id DESC")
        }
        else {
            return try! PWDBManager.shared.select(Planet.self,
                                                  SearchStore.TABLE_NAME,
                                                  "keyId = '\(keyId)' AND symbol='\(symbol)'")
        }
    }
    
    func insert(_ toInsertItem: Planet) {
        
        //1. 중복 검사
        //2. size 검사 (최대 20개) -> 넘을 경우 가장 오래된 record삭제
        var isValid = true
        guard let keyID = toInsertItem.keyId, let symbol = toInsertItem.symbol else { return }
        
        let list = self.list(keyId: keyID, symbol: symbol, descending: false)
        
        list.forEach { (recent) in
            if let name = recent.name, let toInsertName = toInsertItem.name {
                if name == toInsertName {
                    isValid = false
                }
            }
            else {
                if (recent.address == toInsertItem.address) {
                    isValid = false
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
            _ = PWDBManager.shared.insert(toInsertItem, SearchStore.TABLE_NAME)
        }
    }
    
    func delete(_ toDeleteItem: Planet) {
        _ = PWDBManager.shared.delete(toDeleteItem, SearchStore.TABLE_NAME)
    }
}

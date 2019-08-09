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
    
    func list(keyId: String, symbol: String) -> [Search] {
        return try! PWDBManager.shared.select(Search.self,
                                              SearchStore.TABLE_NAME,
                                              "keyId = '\(keyId)' AND symbol='\(symbol)'")
    }
    
    func insert(_ toInsertItem: Search) {
        
        //1. 중복 검사
        //2. size 검사 (최대 20개) -> 넘을 경우 가장 오래된 record삭제
        var isValid = true
        
        let list = self.list(keyId: toInsertItem.keyId, symbol: toInsertItem.symbol)
        
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
            if let objToDelete = list.first {
                _ = PWDBManager.shared.delete(objToDelete, SearchStore.TABLE_NAME)
            }
        }
        
        if isValid {
            _ = PWDBManager.shared.insert(toInsertItem, SearchStore.TABLE_NAME)
        }
    }
    
    func delete(_ toDeleteItem: Search) {
        _ = PWDBManager.shared.delete(toDeleteItem, SearchStore.TABLE_NAME)
    }
}

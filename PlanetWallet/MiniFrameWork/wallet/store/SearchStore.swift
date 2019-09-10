//
//  SearchStore.swift
//  PlanetWallet
//
//  Created by grabity on 09/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

protocol SearchStoreDelegate {
    func snyc()
}

class SearchStore {
    static let TABLE_NAME = "Search"
    static let shared = SearchStore()
    
    var delegate: SearchStoreDelegate?
    
    func list(keyId: String, symbol: String, descending: Bool = true) -> [Planet]{
        
        var searchList_: [Search]?
        
        if descending {
            searchList_ = try! PWDBManager.shared.select(Search.self,
                                                        SearchStore.TABLE_NAME,
                                                        "keyId = '\(keyId)' AND symbol='\(symbol)'", "date DESC")
        }
        else {
            searchList_ = try! PWDBManager.shared.select(Search.self,
                                                        SearchStore.TABLE_NAME,
                                                        "keyId = '\(keyId)' AND symbol='\(symbol)'")
        }
        
        guard let searchList = searchList_ else { return [Planet]() }
        
        return searchList.map { (search) -> Planet in
            let planet = Planet()
            planet._id = search._id
            planet.keyId = search.keyId
            planet.coinType = search.coinType
            planet.date = search.date
            planet.address = search.address
            planet.name = search.name
            planet.symbol = search.symbol
            return planet
        }
    }
    
    func update(_ recentSearch: Planet) {
        
        guard let keyId = recentSearch.keyId,
            let symbol = recentSearch.symbol,
            let coinType = recentSearch.coinType,
            let toAddress = recentSearch.address,
            let toName = recentSearch.name,
            let date = recentSearch.date else { return }

        _ = PWDBManager.shared.update(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, coinType: Int(coinType), date: date),
                                      SearchStore.TABLE_NAME,
                                      "_id='\(recentSearch._id!)'")
    }
    
    func insert(keyId: String, symbol: String, toPlanet: Planet) {
        
        //1. 중복 검사 -> update date column
        //2. size 검사 (최대 20개) -> 넘을 경우 가장 오래된 record삭제
        guard let toName = toPlanet.name,
            let toAddress = toPlanet.address,
            let coinType = toPlanet.coinType else { return }
        
        var isValid = true
        
        let list = self.list(keyId: keyId, symbol: symbol, descending: false)
        
        let date = Int(NSDate().timeIntervalSince1970)
        
        list.forEach { (recent) in
            if let name = recent.name, let toInsertName = toPlanet.name {
                if name == toInsertName {
                    isValid = false
                    _ = PWDBManager.shared.update(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, coinType: coinType, date: date),
                                                  SearchStore.TABLE_NAME,
                                                  "_id='\(recent._id!)'")
                }
            }
            else {
                if (recent.address == toPlanet.address) {
                    isValid = false
                    recent.date = date
                    _ = PWDBManager.shared.update(recent, SearchStore.TABLE_NAME, "_id='\(recent._id!)'")
                }
            }
        }
        
        if list.count >= 20 && isValid {
            if let oldestItem = list.first, let id = oldestItem._id {
                _ = PWDBManager.shared.delete(oldestItem, SearchStore.TABLE_NAME, "_id='\(id)'")
            }
        }
        
        if isValid {
            _ = PWDBManager.shared.insert(Search(keyId: keyId, name: toName, address: toAddress, symbol: symbol, coinType: coinType, date: date), SearchStore.TABLE_NAME)
        }
    }
    
    func delete(_ toDeleteItem: Planet) {
        if let idToDelete = toDeleteItem._id {
            _ = PWDBManager.shared.delete(toDeleteItem, SearchStore.TABLE_NAME, "_id='\(idToDelete)'")
        }
    }
}

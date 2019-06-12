//
//  PlanetWalletDBManger.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class PlanetWalletDBManger : DBManager {

    static let shared: PlanetWalletDBManger = PlanetWalletDBManger()
    
    private let fieldID = "id"
    private let fieldName = "name"
    
    override func getDatabaseVersion() -> UInt32 {
        return 0
    }
    
    override func getDatabseName() -> String? {
        return "planetWallet.sqlite"
    }

    override func createTables(_ database: FMDatabase) -> Bool {
        let createTableQuery = "create table " + "Test" +
            " (" +
            "\(fieldID) integer primary key autoincrement not null, " +
            "\(fieldName) TEXT" +
            ")"
        
        do {
            try database.executeUpdate(createTableQuery, values: nil)
            return true
        }
        catch {
            return false
        }
    }
    
    override func updateTables(_ database: FMDatabase) -> Bool {
        
        return true
    }
    
    public func insertTest() {
//        openDatabase()
    }
    
}

//
//  PWDBManager.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class PWDBManager : DBManager {

    static let shared: PWDBManager = PWDBManager()
    
        
    override func getDatabaseVersion() -> UInt32 {
        return 1
    }
    
    override func getDatabseName() -> String? {
        return "<DataBase>"
    }

    override func createTables(_ database: FMDatabase) -> Bool {
        do {
            let createPlanetTable = "CREATE TABLE Planet( " +
                "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "keyId TEXT," +
                "pathIndex INTEGER," +
                "name TEXT," +
                "address TEXT," +
                "balance TEXT," +
                "coinType INTEGER," +
                "coinName TEXT," +
                "symbol TEXT," +
                "hide TEXT," +
                "decimals TEXT" +
            ")"
            let createMainItemTable = "CREATE TABLE MainItem( " +
                "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "seq INTEGER," +
                "keyId TEXT," +
                "coinType INTEGER," +
                "hide TEXT," +
                "balance TEXT," +
                "name TEXT," +
                "symbol TEXT," +
                "decimals TEXT," +
                "img_path TEXT," +
                "contract TEXT" +
            ")";
            
            let keyPairTable = "CREATE TABLE KeyPair( " +
                "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "keyId TEXT," +
                "value TEXT," +
                "master TEXT" +
            ")";
            
            let searchTable = "CREATE TABLE Search( " +
                "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "keyId TEXT," +
                "coinType Integer," +
                "name TEXT," +
                "address TEXT," +
                "symbol TEXT," +
                "date INTEGER DEFAULT 0" +
            ")";
            
            try database.executeUpdate(createPlanetTable, values: nil)
            try database.executeUpdate(createMainItemTable, values: nil)
            try database.executeUpdate(keyPairTable, values: nil)
            try database.executeUpdate(searchTable, values: nil)
            
            return true
        }
        catch {
            return false
        }
    }
    
    override func updateTables(_ database: FMDatabase, _ oldVersion: UInt32, _ newVersion: UInt32) -> Bool {
        return true
    }
    
}

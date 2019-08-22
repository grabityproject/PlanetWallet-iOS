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
        return 2
    }
    
    override func getDatabseName() -> String? {
        return "planetWallet.sqlite"
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
            let createERC20Table = "CREATE TABLE ERC20( " +
                "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "keyId TEXT," +
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
                "name TEXT," +
                "address TEXT," +
                "symbol TEXT" +
            ")";
            
            try database.executeUpdate(createPlanetTable, values: nil)
            try database.executeUpdate(createERC20Table, values: nil)
            try database.executeUpdate(keyPairTable, values: nil)
            try database.executeUpdate(searchTable, values: nil)
            
            return true
        }
        catch {
            return false
        }
    }
    
    override func updateTables(_ database: FMDatabase, _ oldVersion: UInt32, _ newVersion: UInt32) -> Bool {
        database.open()
        //Add Column Search table
        let updateTableQuery = "ALTER TABLE " + "Search" + " ADD COLUMN " + "date" + " TEXT";
        let updateTableQuery2 = "ALTER TABLE " + "Search" + " ADD COLUMN " + "coinType" + " INTEGER";
        
        do {
            try database.executeUpdate(updateTableQuery, values: nil)
            try database.executeUpdate(updateTableQuery2, values: nil)
            
            database.close()
            return true
        }
        catch {
            print(error.localizedDescription)
            database.close()
            return false
        }
    }
    
}

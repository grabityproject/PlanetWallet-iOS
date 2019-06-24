//
//  PWDBManager.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//
/*
String createPlanetTable = "CREATE TABLE Planet( " +
    "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
    "keyId TEXT," +
    "pathIndex TEXT," +
    "name TEXT," +
    "address TEXT," +
    "balance TEXT," +
    "coinType TEXT," +
    "coinName TEXT," +
    "symbol TEXT," +
    "hide TEXT," +
    "decimals TEXT" +
")";

String createERC20Table = "CREATE TABLE ERC20( " +
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

String keyPairTable = "CREATE TABLE KeyPair( " +
    "_id INTEGER PRIMARY KEY AUTOINCREMENT," +
    "keyId TEXT," +
    "value TEXT," +
    "master TEXT" +
")";
*/
import Foundation

class PWDBManager : DBManager {

    static let shared: PWDBManager = PWDBManager()
    
        
    override func getDatabaseVersion() -> UInt32 {
        return 0
    }
    
    override func getDatabseName() -> String? {
        return "planetWallet4.sqlite"
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
            
            
            
            let query1 = "INSERT INTO 'Planet' ('_id', 'keyId', 'pathIndex', 'name', 'address', 'balance', 'coinType', 'coinName', 'symbol', 'hide', 'decimals') VALUES ('1', '02c825545ec4e3de49fa28e83b3a1eadc3ecefe50d8b51f63c5db56d8340aac6a8', '0', 'Moon', '0xa7a303cabbd178bf85d0b9bf38fcb0b89b0d671f', '', '60', '', 'ETH', 'N', '18')"
            
            
            let query2 = "INSERT INTO 'Planet' ('_id', 'keyId', 'pathIndex', 'name', 'address', 'balance', 'coinType', 'coinName', 'symbol', 'hide', 'decimals') VALUES ('2', '0356eec5d26ceef55a5c4efdeae349362dbbcf5062b1e942c5615def68b1e99a03', '0', 'BTCMoon', '14BDQxxeaq4XocQqDdWza2sEjTu6kDswyu', '', '0', '', 'BTC', 'N', '9')"
            
            
            let query3 = "INSERT INTO 'Planet' ('_id', 'keyId', 'pathIndex', 'name', 'address', 'balance', 'coinType', 'coinName', 'symbol', 'hide', 'decimals') VALUES ('3', '0347a8e7e4eb0ee3059ad52160e5888af1741009916a3edcbc8efe80335f85350a', '1', 'iOS_Genius_moon', '0xca8c313444a68c723350f5234b229a9b68ed9964', '', '60', '', 'ETH', 'N', '18')"
            
            
            let query4 = "INSERT INTO 'ERC20' ('keyId', 'hide', 'balance', 'name', 'symbol', 'decimals', 'img_path') VALUES ('02c825545ec4e3de49fa28e83b3a1eadc3ecefe50d8b51f63c5db56d8340aac6a8', 'N', '', 'Binance', 'BNB', '', '/images/token/000_bnb_28_2.png');"
            
            let query5 = "INSERT INTO 'ERC20' ('keyId', 'hide', 'balance', 'name', 'symbol', 'decimals', 'img_path') VALUES ('02c825545ec4e3de49fa28e83b3a1eadc3ecefe50d8b51f63c5db56d8340aac6a8', 'N', '', 'Maker', 'MKR', '', '/images/token/001_mkr-etherscan-35.png');"
            
            let query6 = "INSERT INTO 'ERC20' ('keyId', 'hide', 'balance', 'name', 'symbol', 'decimals', 'img_path') VALUES ('02c825545ec4e3de49fa28e83b3a1eadc3ecefe50d8b51f63c5db56d8340aac6a8', 'N', '', 'Crypto', 'CRO', '', '/images/token/002_cryptocom_28.png');"
            
            let query7 = "INSERT INTO 'ERC20' ('keyId', 'hide', 'balance', 'name', 'symbol', 'decimals', 'img_path') VALUES ('0347a8e7e4eb0ee3059ad52160e5888af1741009916a3edcbc8efe80335f85350a', 'N', '', 'VeChain', 'VEN', '', '/images/token/003_bat.png');"
            
            let query8 = "INSERT INTO 'ERC20' ('keyId', 'hide', 'balance', 'name', 'symbol', 'decimals', 'img_path') VALUES ('0347a8e7e4eb0ee3059ad52160e5888af1741009916a3edcbc8efe80335f85350a', 'N', '', 'Crypto', 'CRO', '', '/images/token/002_cryptocom_28.png');"
            
            
            try database.executeUpdate(createPlanetTable, values: nil)
            try database.executeUpdate(createERC20Table, values: nil)
            try database.executeUpdate(keyPairTable, values: nil)
            
            try database.executeUpdate(query1, values: nil)
            try database.executeUpdate(query2, values: nil)
            try database.executeUpdate(query3, values: nil)
            try database.executeUpdate(query4, values: nil)
            try database.executeUpdate(query5, values: nil)
            try database.executeUpdate(query6, values: nil)
            try database.executeUpdate(query7, values: nil)
            try database.executeUpdate(query8, values: nil)
            
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

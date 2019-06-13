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
    
    private let tableName = "Test"
    private let fieldID = "id"
    private let fieldName = "name"
    
    override func getDatabaseVersion() -> UInt32 {
        return 3
    }
    
    override func getDatabseName() -> String? {
        return "planetWallet.sqlite"
    }

    override func createTables(_ database: FMDatabase) -> Bool {
        let createTableQuery = "create table " + tableName +
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
        
        //Test update table
        /*
        if openDatabase() {
            if !(database.columnExists(tableName, columnName: "addedField")) {
                
                let alterTable = "ALTER TABLE \(tableName) ADD COLUMN addedField TEXT"
                if database.executeUpdate(alterTable, withArgumentsIn: []) {
                    print("new column added")
                }
                else {
                    print("issue in operation")
                }
                return true
            }
        }
 
        return false
         */
    }
    
    public func insertTest() throws {
        if openDatabase() {
            let id = Int.random(in: 0..<10000)
            let name = "ansrbthd\(id)"
            let query = "insert into " + tableName +
                " (" +
                    "\(fieldID), " +
                    "\(fieldName)" +
                ")" +
                " values " +
                "('\(id)', '\(name)'" +
                ");"
            
            if database.executeStatements(query) {
                database.close()
            }
            else {
                database.close()
                throw DBError.executeStatementsError
            }
        }
        else {
            throw DBError.unableOpenDBError
        }
    }
    
    public func loadTest() throws {
        if openDatabase() {
            let query = "select * from \(tableName)"
            
            do {
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    if let id = results.string(forColumn: fieldID),
                        let name = results.string(forColumn: fieldName) {
                        print("id : \(id), name : \(name)")
                    }
                }
                
                database.close()
            }
            catch {
                database.close()
                throw DBError.executeStatementsError
            }
        }
        else {
           throw DBError.unableOpenDBError
        }
    }
    
}

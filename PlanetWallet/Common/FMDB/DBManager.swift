//
//  DBManager.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class DBManager: NSObject {
    
    var database: FMDatabase!
    
    enum DBError: Error {
        case unableOpenDBError
        case createDBError
        case updateDBError
        case noNamed
        case executeStatementsError
    }
    
    override init() {
        super.init()
        do{
            try createDatabase()
            try updateDatabase()
            print( "datbase ready for use" )
        }catch let err {
            print(err.localizedDescription)
        }
    }
    
    func getDatabaseVersion() -> UInt32 {
        return 0
    }
    
    func getDatabseName() -> String?{
        return nil
    }
    
    private func getDatabasePath() -> String{
        return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String).appending("/\(getDatabseName()!)")
    }
    
    private func createDatabase() throws {
        if( getDatabseName() == nil ) { throw DBError.noNamed }
        if !FileManager.default.fileExists(atPath: getDatabasePath( )) {
            database = FMDatabase(path: getDatabasePath( ))
            if openDatabase(){
                if !createTables( database ) {
                    throw DBError.createDBError
                }else{
                    database.close()
                }
            }else{
                throw DBError.unableOpenDBError
            }
        }
    }
    
    private func updateDatabase() throws {
        if( getDatabseName() == nil ) { throw DBError.noNamed }
        if openDatabase(){
            if( database.userVersion < getDatabaseVersion() ){
                if !updateTables( database ){
                    throw DBError.updateDBError
                }else{
                    database.userVersion = getDatabaseVersion()
                    database.close()
                }
            }
        }else{
            throw DBError.unableOpenDBError
        }
    }
    
    public func openDatabase() -> Bool {
        if( getDatabseName() == nil ) { return false }
        if database == nil {
            if FileManager.default.fileExists(atPath: getDatabasePath()) {
                database = FMDatabase(path: getDatabasePath())
            }
        }
        
        if database != nil {
            if database.open() {
                
                return true
            }
        }
        
        return false
    }
    
    func createTables(_ database:FMDatabase ) -> Bool {
        return false
    }
    
    func updateTables(_ database:FMDatabase ) -> Bool {
        return false
    }
    
    
}

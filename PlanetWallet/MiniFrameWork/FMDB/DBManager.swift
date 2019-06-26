//
//  DBManager.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

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
                if createTables( database ) {
                    database.close()
                }else{
                    throw DBError.createDBError
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
                if !updateTables( database , getDatabaseVersion() ,database.userVersion){
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
    
    func updateTables(_ database:FMDatabase,_ oldVersion:UInt32,_ newVersion:UInt32 ) -> Bool {
        return false
    }
    
    func select<T: Mappable>(_ type:T.Type, _ table:String = "",_ condition:String = "") throws -> Array<T>{
        var resultArray : Array<T> = Array<T>()
        var tableName = table;
        if tableName == "" {
            tableName = String(describing: type)
        }
        
        var conditionString = condition;
        
        if conditionString != "" {
            conditionString = "WHERE " + conditionString
        }
        
        if openDatabase() {
            let query = "select * from \(tableName) \(conditionString)"
            
            do {
                let results = try database.executeQuery(query, values: nil)

                while results.next() {
                    var row = Dictionary<String, Any>()
                    for i in 0..<results.columnCount{
                        if let k = results.columnName(for: i), let v = results.object(forColumnIndex: i){
                            row.updateValue(v, forKey: k)
                        }
                    }

                    if let obj = T.init(JSON: row) {
                        resultArray.append(obj)
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
        
        return resultArray;
        
    }
    
    func insert<T:Mappable>(_ object:T, _ table:String = "" ) -> Bool {
        var tableName = table
        if tableName == "" {
            tableName = String(describing: type(of: object.self))
        }

        let dict = object.toJSON()
        var columns = ""
        var values = ""
        
        dict.forEach { (arg0) in
            let (key, value) = arg0
            
            columns += key + ","
            if let v = value as? String {
                values += "'" + v + "',"
            }else if let v = value as? Int {
                values += "'" + String(v) + "',"
            }
            
        }
        
        columns = String(columns.dropLast())
        values = String(values.dropLast())
        
        if(columns.count > 0 && values.count > 0 ){
            print("INSERT INTO \(tableName) (\(columns)) VALUES (\(values))")
            
            if openDatabase() {
                let result = database.executeStatements("INSERT INTO \(tableName) (\(columns)) VALUES (\(values))")
                database.close()
                return result
            }
            else {
                print("Failed to open db")
                return false;
            }
            
        }else {
            return false
        }
    }
    
    
    func update<T:Mappable>(_ object:T,_ table:String, _ condition:String = "" ) -> Bool {
        var tableName = table
        if tableName == ""{
            tableName = String(describing: type(of: object.self))
        }
        let dict = object.toJSON()
        var values = ""
        
        dict.forEach { (arg0) in
            let (key, value) = arg0
            if let v = value as? String {
                values += key + "='" + v + "',"
            }
        }
        
        values = String(values.dropLast())
        print( values )
        
        if( values.count > 0 ){
            if openDatabase() {
                let result = database.executeStatements("UPDATE \(tableName) SET \(values) WHERE \(condition)")
                database.close()
                return result
            }
            else {
                return false;
            }
        }else {
            return false
        }
    }
    
    func update<T:Mappable>(_ object:T, _ condition:String = "" ) -> Bool {
        return self.update(object, "", condition)
    }
    
    
    func delete<T:Mappable>(_ object:T,_ table:String, _ condition:String = "" ) -> Bool {
        var tableName = table
        if tableName == ""{
            tableName = String(describing: type(of: object.self))
        }
        
        if( condition.count > 0 ){
            if openDatabase() {
                let result = database.executeStatements("DELETE FROM \(tableName) WHERE \(condition)")
                database.close()
                return result
            }
            else {
                return false;
            }
        }else {
            return false
        }
    }
    
    func delete<T:Mappable>(_ object:T, _ condition:String = "" ) -> Bool {
        return self.delete(object, "", condition)
    }
}

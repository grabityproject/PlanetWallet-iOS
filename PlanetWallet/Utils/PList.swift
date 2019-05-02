//
//  PList.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class PList {
    
    static let shared = PList()
    
    private init() {
        if initPlist(name: DEFAULT_PLIST_NAME) {
            NSLog("success to Plist init")
        }
        else {
            NSLog("fail to Plist init")
        }
    }
    
    func initPlist(name: String) -> Bool {
        
        if checkPlist(name) {
            return true
        }
        else {
            return makePlist(name)
        }
    }
    
    func checkPlist(_ name: String) -> Bool {
        
        let path = getPlistPath(name)
        
        return FileManager.default.fileExists(atPath: path)
    }

    
    public func makePlist(_ name: String) -> Bool {
        
        let path = getPlistPath(name)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) == false
        {
            if let bundle = Bundle.main.path(forResource: name, ofType: "plist") {
                try! fileManager.copyItem(atPath: bundle, toPath: path)
                return true
            }
        }
        
        return false
    }
    
    public func getPlistPath(_ name: String) -> String {
        let documentDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                     .userDomainMask,
                                                                     true)[0] as NSString) as String
        let plistFileName = name.appending(".plist")
        return documentDirectory.appending("/" + plistFileName)
    }
    
    public func readPlist(_ name: String, key: String) -> String? {
        guard checkPlist(name) else { return nil }
        
        let path = getPlistPath(name)
        
        if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any>
        {
            //, let password = dict.object(forKey: "password") as! String?
            return dict[key] as? String
        }
        else{
            print("load failure.")
            return nil
        }
    }
    
    public func writePlist(_ name: String, key: String, value: String) {
        guard checkPlist(name) else { return }
        
        let path = getPlistPath(name)
        
        if var dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any>
        {
            dict[key] = value
        }
        else{
            print("load failure.")
        }
    }
}

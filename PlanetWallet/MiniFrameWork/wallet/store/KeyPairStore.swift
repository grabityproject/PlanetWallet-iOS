//
//  KeyPairStore.swift
//  PCWF-SAMPLE
//
//  Created by 박상은 on 26/06/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import UIKit
import pcwf
import BigInt
import CommonCrypto
import Foundation
import UIKit
import pcwf.ObjcWrapper
import pcwf.Swift
import pcwf.pallet_core_wrapper

class KeyPairStore: HDKeyPairStore {
    
    static let shared:KeyPairStore = KeyPairStore()
    
    var defaultCrypter: DefaultStorageCryper?
    var keyPairMap: Dictionary<String, KeyPair> = [String:KeyPair]()

    init() {
        keyPairMap.removeAll()
        let selectList:[KeyPair] = try! PWDBManager.shared.select(KeyPair.self)
        selectList.forEach { (keyPair) in
            if let keyId = keyPair.keyId{
                keyPairMap[keyId] = keyPair
            }
        }
    }
    
    func changePinCode( before:[String], after:[String] ){
        
        let keyPairs = try! PWDBManager.shared.select(KeyPair.self)
        
        keyPairs.forEach { (keyPair) in
            
            if let value = keyPair.value{
                
                // Encrypt
                let privateKeyPlain = try! defaultCrypter?.doubleDecrypt(encrypted: dataFromBufData(value, index: 0), pin: before)
                let publicKeyPlain = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(value, index: 1))
                let chainCodePlain = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(value, index: 2))
                var mnemonicPlain = dataFromBufData(value, index: 3)
                if mnemonicPlain.count > 0{
                    mnemonicPlain =  try!(defaultCrypter?.doubleDecrypt(encrypted: dataFromBufData(value, index: 3), pin: before))!
                }
                
                // Decrypt
                let privateKeyEnc = try! defaultCrypter?.doubleEncrypt(data: privateKeyPlain!, pin: after)
                let publicKeyEnc = defaultCrypter?.singleEncrypt(data: publicKeyPlain!)
                let chainCodeEnc = defaultCrypter?.singleEncrypt(data: chainCodePlain!)
                var mnemonicEnc:Data?
                if mnemonicPlain.count > 0{
                    mnemonicEnc =  try! ((defaultCrypter?.doubleEncrypt(data: mnemonicPlain, pin: after))!)
                }
                
                
                if let privateKey = privateKeyEnc, let publicKey = publicKeyEnc, let chainCode = chainCodeEnc{
                    if let mnemonic = mnemonicEnc{
                        // with mnemonic
                        keyPair.value = bufData([ privateKey, publicKey, chainCode, mnemonic ])
                        if let keyId = keyPair.keyId{
                            _ = PWDBManager.shared.update(keyPair, "keyId = '\(keyId)'")
                        }
                    }else{
                        // without mnemonic
                        keyPair.value = bufData([ privateKey, publicKey, chainCode ])
                        if let keyId = keyPair.keyId{
                            _ = PWDBManager.shared.update(keyPair, "keyId = '\(keyId)'")
                        }
                    }
                }
                
                
            }
            
        }

        keyPairMap.removeAll()
        let selectList:[KeyPair] = try! PWDBManager.shared.select(KeyPair.self)
        selectList.forEach { (keyPair) in
            if let keyId = keyPair.keyId{
                keyPairMap[keyId] = keyPair
            }
        }
    }
    
    func saveKeyPair(keyPair: HDKeyPair, pin: [String]) throws -> String {
        let privateKey = try! defaultCrypter?.doubleEncrypt(data: keyPair.privateKey ?? Data(), pin: pin)
        let publicKey = defaultCrypter?.singleEncrypt(data: keyPair.publicKey)
        let chainCode = defaultCrypter?.singleEncrypt(data: keyPair.chainCode ?? Data())
        
        if let keyId = keyPair.id{
            if( keyPairMap[keyId] == nil ){
                let insertData = KeyPair()
                insertData.keyId = keyPair.id
                insertData.value = bufData( [privateKey!, publicKey!, chainCode! ] )
                insertData.master = "-1"
                
                _ = PWDBManager.shared.insert(insertData)
                
                keyPairMap[keyId] = insertData
            }
        }
        return keyPair.id!
    }
    
    
    func saveKeyPair(keyPair: HDKeyPair, phrase:String, pin: [String]) throws -> String {
        let privateKey = try! defaultCrypter?.doubleEncrypt(data: keyPair.privateKey ?? Data(), pin: pin)
        let publicKey = defaultCrypter?.singleEncrypt(data: keyPair.publicKey)
        let chainCode = defaultCrypter?.singleEncrypt(data: keyPair.chainCode ?? Data())
        let phrase = try! defaultCrypter?.doubleEncrypt(data: phrase.data(using: .utf8)!, pin: pin)
        
        if let keyId = keyPair.id{
            
            let insertData = KeyPair()
            insertData.keyId = keyPair.id
            insertData.value = bufData( [privateKey!, publicKey!, chainCode!, phrase!] )
            insertData.master = "-2"
            
            if( keyPairMap[keyId] == nil ){
                _ = PWDBManager.shared.insert(insertData)
              keyPairMap[keyId] = insertData
//            }else{
//                if let master = keyPairMap[keyId]?.master{
//                    if Int(master) > 0{
//
//                    }
//                }
//                _ = PWDBManager.shared.update(insertData, "keyId='\(keyId)'")
            }
        }
        return keyPair.id!
    }
    
    
    func saveMasterKeyPair( coreCoinType:Int, phrase:String, keyPair: HDKeyPair, pin: [String]) throws -> String {
        let privateKey = try! defaultCrypter?.doubleEncrypt(data: keyPair.privateKey ?? Data(), pin: pin)
        let publicKey = defaultCrypter?.singleEncrypt(data: keyPair.publicKey)
        let chainCode = defaultCrypter?.singleEncrypt(data: keyPair.chainCode ?? Data())
        let phrase = try! defaultCrypter?.doubleEncrypt(data: phrase.data(using: .utf8)!, pin: pin)
        
        if let keyId = keyPair.id{
            if( keyPairMap[keyId] == nil ){
                let insertData = KeyPair()
                insertData.keyId = keyPair.id
                insertData.value = bufData( [privateKey!, publicKey!, chainCode!, phrase!] )
                insertData.master = String(format: "%d", coreCoinType)
                
                _ = PWDBManager.shared.insert(insertData)
                
                keyPairMap[keyId] = insertData
            }
        }
        return keyPair.id!
    }
    
    func getMasterKeyPair( coreCoinType: Int, pin: [String]) throws -> HDKeyPair? {
        
        let selectList:[KeyPair] = try! PWDBManager.shared.select(KeyPair.self)
        let hdKeyPair = HDKeyPair()

        var find = false
        selectList.forEach { (keyPair) in
            if( keyPair.master == String(coreCoinType) ){
                if( pin.count > 0 ){
                    hdKeyPair.privateKey = try! defaultCrypter?.doubleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 0), pin: pin)
                }
                hdKeyPair.publicKey = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 1))
                hdKeyPair.chainCode = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 2))
                
                find = true
                return
            }
        }
        if( find ){
            return hdKeyPair
        }else{
            return nil
        }
    }

    
    func getKeyPair(keyId: String, pin: [String]) throws -> HDKeyPair {
        if let keyPair:KeyPair = keyPairMap[keyId]{
            let hdKeyPair = HDKeyPair()
            if( pin.count > 0 ){
                do {
                    hdKeyPair.privateKey = try defaultCrypter?.doubleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 0), pin: pin)
                }
                catch {
                    print(error)
                    return HDKeyPair()
                }
            }
            hdKeyPair.publicKey = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 1))
            hdKeyPair.chainCode = defaultCrypter?.singleDecrypt(encrypted: dataFromBufData(keyPair.value!, index: 2))
            return hdKeyPair
        }
        return HDKeyPair()
    }
    
    func getKeyPair(keyId: String) throws -> HDKeyPair {
        return try! getKeyPair(keyId: keyId, pin: [String]())
    }
    
    func deleteKeyPair(keyId: String) throws {
        if let keyPair:KeyPair = keyPairMap[keyId]{
            _ = PWDBManager.shared.delete(keyPair, "keyId = '\(keyId)' AND master < 0")
            keyPairMap.remove(at: keyPairMap.index(forKey: keyId)!)
        }
    }
    
    func getPhrase( coreCoinType:Int , pinCode:[String] )->String{
        
        let selectList:[KeyPair] = try! PWDBManager.shared.select(KeyPair.self)
        var phrase:String = ""
        
        selectList.forEach { (keyPair) in
            if( keyPair.master == String(coreCoinType) ){
                let phraseEncData = dataFromBufData(keyPair.value!, index: 3)
                let phraseDecData = try! (defaultCrypter?.doubleDecrypt(encrypted: phraseEncData, pin: pinCode))
                phrase = String( data: phraseDecData!, encoding: .utf8 )!
                return
            }
        }
        return phrase
    }
    
    func getPhrase( keyId:String , pinCode:[String] )->String {
        var phrase:String = ""
        
        if let keyPair = keyPairMap[keyId]{
            if( keyPair.master == "-2" ){
                let phraseEncData = dataFromBufData(keyPair.value!, index: 3)
                let phraseDecData = try! (defaultCrypter?.doubleDecrypt(encrypted: phraseEncData, pin: pinCode))
                phrase = String( data: phraseDecData!, encoding: .utf8 )!
            }
        }
        return phrase
    }
    
    func bufData(_ datas:[Data] )->String{
        var returnData = String()
        var i = 0
        datas.forEach { (data) in
            let hexString = data.hexString
            i = i + 1
            print("\(i) : \(hexString)")
            returnData.append(contentsOf: String(format:"%02X", hexString.count))
            returnData.append(contentsOf: hexString)
        }
        return returnData
    }
    
    func dataFromBufData(_ bufData:String, index:Int )->Data{
        var before = 0
        var count = 0;
        while true {
            if( bufData.count >= before + 2 ){
                let length =  bufData[ String.Index(utf16Offset: before, in: bufData)...String.Index(utf16Offset: before + 1, in: bufData) ]
                
                if( Int(length, radix:16) == 0 ){
                    return Data()
                }
                
                let data = bufData[ String.Index(utf16Offset: before + length.count, in: bufData)...String.Index(utf16Offset:  before + Int(length, radix:16)! + 1, in: bufData) ]
                before = Int(length, radix:16)! + before + 2
                if( count == index ){
                    return Data(hexString: String(data))!
                }
                
                count = count + 1
            }else{
                return Data()
            }
        }
    }
    
    

}

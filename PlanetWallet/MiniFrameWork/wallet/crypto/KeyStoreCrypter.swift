//
//  HsmKeyCrypterMock.swift
//  PCWF-SAMPLE
//
//  Created by SeHyun Park on 24/05/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import Foundation
import pcwf
import Security
import CryptoSwift

public class KeyStoreCrypter: HsmKeyCrypter {
    
    private let _kSecClass = String(kSecClass)
    private let _kSecAttrAccount = String(kSecAttrAccount)
    private let _kSecValueData = String(kSecValueData)
    private let _kSecClassGenericPassword = String(kSecClassGenericPassword)
    private let _kSecAttrService = String(kSecAttrService)
    private let _kSecMatchLimit = String(kSecMatchLimit)
    private let _kSecReturnData = String(kSecReturnData)
    private let _kSecMatchLimitOne = String(kSecMatchLimitOne)
    private let _kSecAttrAccessible = String(kSecAttrAccessible)
    
    private let secAttrService = "walletSecService"
    private let iv: Array<UInt8> = "PlanetWalletPCWF".bytes

    public func encrypt(alias: String, data: Data) -> Data {
        do {
            let encrypted = try AES(key: secretKey(alias: alias).bytes, blockMode: CBC(iv: iv), padding: .pkcs5).encrypt(data.bytes)
            return Data(encrypted)
        } catch {
            return Data()
        }
    }
    
    public func decrypt(alias: String, encrypted: Data) -> Data {
        do {
            let decrypted = try AES(key: secretKey(alias: alias).bytes, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(encrypted.bytes)
            return Data(decrypted)
        } catch {
            return Data()
        }
    }
    
    public func secretKey(alias:String) -> Data {
        if let secretKey = get(alias: alias){
            return secretKey
        }else{
            put( alias: alias, value: Data(AES.randomIV(32)))
            return self.secretKey(alias: alias)
        }
    }
    
    func put(alias:String, value: Data) {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: secAttrService,
            _kSecAttrAccount: alias,
            _kSecValueData: value,
            ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    func get( alias:String ) -> Data? {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecMatchLimit: kSecMatchLimitOne,
            _kSecAttrAccount: alias,
            _kSecReturnData: kCFBooleanTrue as Any
            ] as CFDictionary
        
        var buffer: AnyObject?
        let status = SecItemCopyMatching(query, &buffer)
        
        if status == errSecSuccess {
            if let data = buffer as? Data {
                return data
            } else {
                return nil            }
        } else {
            return nil
        }
    }
}

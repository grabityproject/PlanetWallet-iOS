//
//  BiometricManager.swift
//  PlanetWallet
//
//  Created by grabity on 23/07/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import LocalAuthentication
import Security
import CryptoSwift

enum BiometricType {
    case none
    case touchID
    case faceID
}

protocol BiometricManagerDelegate {
    func didAuthenticated(success: Bool, key: [String]?, error: Error?)
}

class BiometricManager {
    
    public static let shared:BiometricManager = BiometricManager()
    
    private let iv: Array<UInt8> = "PlanetWalletBIOM".bytes
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
    private let alias = "bio_key"
    
    var loginReason = "Logging in with Biometric ID"
    
    var delegate: BiometricManagerDelegate!
    
    func canEvaluatePolicy(handler: (_ success: Bool, _ error: LAError?)->Void) {
        let context = LAContext()
        var authError: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            handler(false, authError as? LAError)
            return
        }
        
        handler(true, nil)
    }
    
    func authenticateUser() {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            if let delegate = self.delegate{
                delegate.didAuthenticated(success: false, key: nil, error: LAError.biometryNotAvailable as? Error)
            }
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    if self.delegate != nil{
                        self.delegate.didAuthenticated(success: true, key: self.getKey(), error: nil)
                    }
                }
            } else {
                if self.delegate != nil{
                    self.delegate.didAuthenticated(success: false, key: nil, error: evaluateError)
                }
            }
        }
    }
    
    public func generateSecretKey(){
        put( alias: alias, value: Data(AES.randomIV(32)))
    }
    
    public func secretKey() -> Data {
        if let secretKey = get(alias: alias){
            return secretKey
        }else{
            self.generateSecretKey()
            return self.secretKey()
        }
    }
    
    public func saveKey( PINCODE:[String] ){
        let pincode:[UInt8] = Array(PINCODE.joined().utf8)
        do {
            let encrypted = try AES(key: secretKey().bytes, blockMode: CBC(iv: iv), padding: .pkcs5).encrypt(pincode)
            put(alias: "bio_enc", value: Data(encrypted))
        } catch {
            print(error)
        }
    }
    
    public func removeKey(){
        self.remove(alias: "bio_enc")
    }
    
    public func getKey()->[String]{
        do {
            let encrypted = get(alias: "bio_enc")
            let decrypted = try AES(key: secretKey().bytes, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(encrypted!.bytes)
            var rst = [String]()
            decrypted.forEach { (int) in
                rst.append(String(Character(UnicodeScalar(int))))
            }
            return rst
        } catch {
            print(error)
        }
        return [String]()
    }
    
    private func remove(alias:String) {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: secAttrService,
            _kSecAttrAccount: alias,
            ] as CFDictionary
        
        SecItemDelete(query)
    }
    
    private func put(alias:String, value: Data) {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: secAttrService,
            _kSecAttrAccount: alias,
            _kSecValueData: value,
            ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    private func get( alias:String ) -> Data? {
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


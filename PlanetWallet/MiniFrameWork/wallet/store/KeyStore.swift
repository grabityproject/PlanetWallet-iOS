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

class KeyStore {
    
    static let shared:KeyStore = KeyStore()
    
    var defaultCrypter: DefaultStorageCryper?
    var keyPairMap: Dictionary<String, KeyPair> = [String:KeyPair]()
    
    init() {

    }
    
    func setValue( key:String, data:Data , pin: [String]) {
        if let crypter = defaultCrypter{
            do{
                let encData = try crypter.doubleEncrypt(data: data, pin: pin)
                UserDefaults.standard.set(encData.base64EncodedString(), forKey: key)
            }catch{
                print(error)
            }
        }
    }
    
    func getValue( key:String, pin:[String]) -> Data? {
        if let crypter = defaultCrypter{
            do{
                if let encBase64 = UserDefaults.standard.value(forKey: key){
                    if let encBase64Str = encBase64 as? String {
                        let encBase64Data = Data(base64Encoded: encBase64Str)
                        let encData = try crypter.doubleDecrypt(encrypted: encBase64Data!, pin: pin)
                        return encData
                    }
                    else {
                        print("not string")
                        return nil
                    }
                    
                }
            }catch{
                print(error)
            }
        }
        return nil
    }
    
}

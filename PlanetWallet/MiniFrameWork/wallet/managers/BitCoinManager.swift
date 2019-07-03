//
//  BitCoinManager.swift
//  PCWF-SAMPLE
//
//  Created by 박상은 on 26/06/2019.
//  Copyright © 2019 SeHyun Park. All rights reserved.
//

import Foundation
import pcwf
import BigInt
import CommonCrypto
import Foundation
import UIKit
import pcwf.ObjcWrapper
import pcwf.Swift
import pcwf.pallet_core_wrapper

class BitCoinManager{
    
    static let shared: BitCoinManager = BitCoinManager()
    
    lazy var mnemonicService = ObjcMnemonicService()
    let hdKeyPairService: HDKeyPairService = ObjcHDKeyPairService()
    var service:BtcWalletAccountService?
    
    init() {
        self.service = BtcWalletAccountService(keyPairService: hdKeyPairService, keyPairStore: KeyPairStore.shared, btcApiClient: nil)
    }
    
    func importMnemonic( mnemonicPhrase:String, passPhrase:String = "", pinCode:[String]) -> Planet {
        do{
            
            let mnemonic = mnemonicPhrase.components(separatedBy: " ")
            let seed = try ObjcMnemonicService().createSeed(mnemonic: mnemonic, passphrase: passPhrase)
            
            let masterKeyPair = try ObjcHDKeyPairService().deriveHDMasterKey(seed: seed)
            
            let btcCoinAccountPath = PcwfUtils.getHDPath(hdPathString: "44H/0H/0H")
            let btcCoinAccountkey = try ObjcHDKeyPairService().deriveHDKeyPair(parentKeyPair: masterKeyPair, hdPath: btcCoinAccountPath)
            _ = try KeyPairStore.shared.saveKeyPair(keyPair: btcCoinAccountkey, pin: pinCode)
            
            let childKeyPair = try hdKeyPairService.deriveHDKeyPair(parentKeyPair: btcCoinAccountkey, hdPath: [0,0])
            _ = try KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, phrase:mnemonicPhrase , pin: pinCode)
            
            let childKeyId = try KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, pin: pinCode)
            let account = try service?.createHDWalletAccount(keyId: btcCoinAccountkey.id!, currencyType: CoinType.BTC.name, definedCurrency: DefinedCurrency.BTC, hdPathString: "0/0")
            
            let planet:Planet = Planet()
            planet.keyId = childKeyId
            planet.address = account?.address
            planet.coinType = CoinType.BTC.coinType
            if let precision = CoinType.BTC.precision{
                planet.decimals = "\(precision)"
            }
            planet.hide = "N"
            planet.symbol = CoinType.BTC.name
            planet.pathIndex = -2
            
            
            _ = try KeyPairStore.shared.deleteKeyPair(keyId: btcCoinAccountkey.id!)
            
            return planet
            
        }catch{
            print(error)
        }
        return Planet()
    }
    
    func importPrivateKey( privKey:String, pinCode:[String]) -> Planet {
    
        do {
            var privateKeyBuffer:[UInt8] = [UInt8]()
            
            if let privateKeyFromWif = Utils.shared.convertWIFToPrivateKey(privKey){
                //WIF Format
                privateKeyBuffer = PcwfUtils.hexStringToBytes(hexString: privateKeyFromWif)
            }
            else {
                //Hex Format
                guard privKey.count == 64 else { return Planet() }
                privateKeyBuffer = PcwfUtils.hexStringToBytes(hexString: privKey)
            }
            
            if privateKeyBuffer.count == 32{
                
                var publicKeyBuffer:[UInt8] = [UInt8](repeating: 0, count: 200)
                var pub_len:Int32 = 200
                GenPubkeyFromPriKey(privateKeyBuffer, Int32(privateKeyBuffer.count), &publicKeyBuffer, &pub_len)
                publicKeyBuffer.removeSubrange(Range(NSRange(location: Int(pub_len), length: publicKeyBuffer.count - Int(pub_len)))!)
                
                let keyPair:HDKeyPair = HDKeyPair()
                keyPair.id = PcwfUtils.byteArrayToHexString(bytes: publicKeyBuffer)
                keyPair.privateKey = Data(hexString: PcwfUtils.byteArrayToHexString(bytes: privateKeyBuffer))
                keyPair.publicKey = Data(hexString: PcwfUtils.byteArrayToHexString(bytes: publicKeyBuffer))
                keyPair.chainCode = Data()
                
                _ = try KeyPairStore.shared.saveKeyPair(keyPair: keyPair, pin: pinCode)
                
                let account = try service?.createBasicAccount(keyId: keyPair.id!,
                                                               currencyType: CoinType.BTC.name,
                                                               definedCurrency: DefinedCurrency.BTC)
                
                let planet:Planet = Planet()
                planet.keyId = keyPair.id
                planet.address = account?.address
                planet.coinType = CoinType.BTC.coinType
                if let precision = CoinType.BTC.precision{
                    planet.decimals = "\(precision)"
                }
                planet.hide = "N"
                planet.symbol = CoinType.BTC.name
                planet.pathIndex = -1
                
                return planet
                
            }
            
        } catch  {
            print(error)
        }
        return Planet()
    }
    
    
    
    func addPlanet( pinCode:[String] )->Planet{
        
        let planets = PlanetStore.shared.list(CoinType.BTC.name, false)
        var index = -1
        planets.forEach { (planet) in
            if let pathIndex = planet.pathIndex{
                if index <= pathIndex{
                    index = pathIndex
                }
            }
        }
        index = index + 1
        
        let masterKeyPair = try! KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode)
        let childKeyPair = try! hdKeyPairService.deriveHDKeyPair(parentKeyPair: masterKeyPair!, hdPath: [0, index])
        
        let childKeyId = try! KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, pin: pinCode)
        let account = try! service?.createHDWalletAccount(keyId: (masterKeyPair?.publicKey.hexString)!, currencyType:  CoinType.BTC.name, definedCurrency: DefinedCurrency.BTC, hdPathString: "0/\(index)")
        
        
        let planet:Planet = Planet()
        planet.keyId = childKeyId
        planet.address = account?.address
        planet.coinType = CoinType.BTC.coinType
        if let precision = CoinType.BTC.precision{
            planet.decimals = "\(precision)"
        }
        planet.hide = "N"
        planet.symbol = CoinType.BTC.name
        planet.pathIndex = index
        
        return planet
    }
    
    
    func addPlanet( index:Int, pinCode:[String] )->Planet{
        
        let masterKeyPair = try! KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode)
        let childKeyPair = try! hdKeyPairService.deriveHDKeyPair(parentKeyPair: masterKeyPair!, hdPath: [0, index])
        
        let childKeyId = try! KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, pin: pinCode)
        let account = try! service?.createHDWalletAccount(keyId: (masterKeyPair?.publicKey.hexString)!, currencyType:  CoinType.BTC.name, definedCurrency: DefinedCurrency.BTC, hdPathString: "0/\(index)")
        
        
        let planet:Planet = Planet()
        planet.keyId = childKeyId
        planet.address = account?.address
        planet.coinType = CoinType.BTC.coinType
        if let precision = CoinType.BTC.precision{
            planet.decimals = "\(precision)"
        }
        planet.hide = "N"
        planet.symbol = CoinType.BTC.name
        planet.pathIndex = index
        
        return planet
    }
    
    func generateMaster( pinCode:[String]) {
        let mnemonic = try! ObjcMnemonicService().generateMnemonic(entropySize: 128)
        let mnemonicPhrase = mnemonic.joined(separator: " ")
        
        let seed = try! ObjcMnemonicService().createSeed(mnemonic: mnemonic, passphrase: "")
        
        let masterKeyPair = try! ObjcHDKeyPairService().deriveHDMasterKey(seed: seed)
        
        let btcCoinAccountPath = PcwfUtils.getHDPath(hdPathString: "44H/0H/0H")
        let btcCoinAccountkey = try! ObjcHDKeyPairService().deriveHDKeyPair(parentKeyPair: masterKeyPair, hdPath: btcCoinAccountPath)
        
        if let mk:HDKeyPair = try! KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode){
            let childKeyPair = try! hdKeyPairService.deriveHDKeyPair(parentKeyPair: mk, hdPath: [0, 0])
            _ = PWDBManager.shared.delete(KeyPair(), "master='\(CoinType.BTC.coinType)'")
            if let keyId = childKeyPair.id{
                _ = PWDBManager.shared.delete(KeyPair(), "keyId='\(keyId)'")
            }
        }
        _ = try! KeyPairStore.shared.saveMasterKeyPair(coreCoinType: CoinType.BTC.coinType, phrase: mnemonicPhrase, keyPair: btcCoinAccountkey, pin: pinCode)
        
    }
    
    
}

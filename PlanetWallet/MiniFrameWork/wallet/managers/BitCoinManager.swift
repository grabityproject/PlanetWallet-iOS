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
    
//    var hdPath = "44H/0H/0H"
//    var coinType: StructCoinType = CoinType.BTC
    var definedCurrency: DefinedCurrency = DefinedCurrency.BTC
    
    init() {
        self.service = BtcWalletAccountService(keyPairService: hdKeyPairService, keyPairStore: KeyPairStore.shared, btcApiClient: nil)
        
        if TESTNET {
            definedCurrency = DefinedCurrency.BTCT
        }
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
            let account = try service?.createHDWalletAccount(keyId: btcCoinAccountkey.id!, currencyType: CoinType.BTC.name, definedCurrency: self.definedCurrency, hdPathString: "0/0")
            
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
                                                               definedCurrency: self.definedCurrency)
                
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
        
        do {
            let masterKeyPair = try KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode)
            let childKeyPair = try hdKeyPairService.deriveHDKeyPair(parentKeyPair: masterKeyPair!, hdPath: [0, index])
            
            let childKeyId = try KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, pin: pinCode)
            guard let masterKeyID = masterKeyPair?.publicKey.hexString else { return Planet() }
            
            let account = try service?.createHDWalletAccount(keyId: masterKeyID,
                                                             currencyType:  CoinType.BTC.name,
                                                             definedCurrency: self.definedCurrency,
                                                             hdPathString: "0/\(index)")
            
            if PlanetStore.shared.get(childKeyId) == nil {
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
            else {
                return addPlanet(index: index + 1, pinCode: pinCode)
            }
        }
        catch {
            return Planet()
        }
    }
    
    
    func addPlanet( index:Int, pinCode:[String] )->Planet{
        
        do {
            let masterKeyPair = try KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode)
            let childKeyPair = try hdKeyPairService.deriveHDKeyPair(parentKeyPair: masterKeyPair!, hdPath: [0, index])
            
            let childKeyId = try KeyPairStore.shared.saveKeyPair(keyPair: childKeyPair, pin: pinCode)
            guard let masterKeyID = masterKeyPair?.publicKey.hexString else { return Planet() }
            
            let account = try service?.createHDWalletAccount(keyId: masterKeyID,
                                                             currencyType: CoinType.BTC.name,
                                                             definedCurrency: self.definedCurrency,
                                                             hdPathString: "0/\(index)")
            
            if PlanetStore.shared.get(childKeyId) == nil {
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
            else {
                return addPlanet(index: index + 1, pinCode: pinCode)
            }
            
        }
        catch {
            return Planet()
        }
    }
    
    func generateMaster( pinCode:[String]) {
        do {
            let mnemonic = try ObjcMnemonicService().generateMnemonic(entropySize: 128)
            let mnemonicPhrase = mnemonic.joined(separator: " ")
            
            let seed = try ObjcMnemonicService().createSeed(mnemonic: mnemonic, passphrase: "")
            
            let masterKeyPair = try ObjcHDKeyPairService().deriveHDMasterKey(seed: seed)
            
            let btcCoinAccountPath = PcwfUtils.getHDPath(hdPathString: "44H/0H/0H")
            let btcCoinAccountkey = try ObjcHDKeyPairService().deriveHDKeyPair(parentKeyPair: masterKeyPair, hdPath: btcCoinAccountPath)
            
            if let mk:HDKeyPair = try KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: pinCode){
                let childKeyPair = try hdKeyPairService.deriveHDKeyPair(parentKeyPair: mk, hdPath: [0, 0])
                _ = PWDBManager.shared.delete(KeyPair(), "master='\(CoinType.BTC.coinType)'")
                if let keyId = childKeyPair.id{
                    _ = PWDBManager.shared.delete(KeyPair(), "keyId='\(keyId)'")
                }
            }
            
            _ = try KeyPairStore.shared.saveMasterKeyPair(coreCoinType: CoinType.BTC.coinType, phrase: mnemonicPhrase, keyPair: btcCoinAccountkey, pin: pinCode)
        }
        catch {
            print("Generate BTC master error : \(error)")
        }
    }
    
    public func validAddress(_ address: String) -> Bool {
        guard let service = service else { return false }
        do {
            if TESTNET {
                if let _ = matches(for: "^[2mn][1-9A-HJ-NP-Za-km-z]{26,35}", in: address).first {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return try service.validateAddress(address: address)
            }
        }
        catch {
            return false
        }
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch {
            return []
        }
    }
}

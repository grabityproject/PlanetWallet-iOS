//
//  Crypto.swift
//  PlanetWallet
//
//  Created by grabity on 11/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import BigInt
import Foundation
import secp256k1
import CommonCrypto


extension Data {
    
    static func random(length: Int) -> Data {
        var data = Data(repeating: 0, count: length)
        var success = false
        #if !os(Linux)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0)
        }
        success = result == errSecSuccess
        #endif
        guard !success else { return data }
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt32>) in
            for i in 0..<length/4+1 {
                #if canImport(Darwin)
                bytes[i] = arc4random()
                #else
                bytes[i] = UInt32(bitPattern: rand())
                #endif
            }
        }
        return data
    }
    
    func checkSignatureSize() throws {
        try checkSignatureSize(compressed: false)
    }
    
    func checkSignatureSize(compressed: Bool) throws {
        if compressed {
            guard count == 33 else { throw SECP256K1Error.invalidSignatureSize }
        } else {
            guard count == 65 else { throw SECP256K1Error.invalidSignatureSize }
        }
    }
    
    func checkSignatureSize(maybeCompressed: Bool) throws {
        if maybeCompressed {
            guard count == 65 || count == 33 else { throw SECP256K1Error.invalidSignatureSize }
        } else {
            guard count == 65 else { throw SECP256K1Error.invalidSignatureSize }
        }
    }
    
    func checkHashSize() throws {
        guard count == 32 else { throw SECP256K1Error.invalidHashSize }
    }
    
    func checkPrivateKeySize() throws {
        guard count == 32 else { throw SECP256K1Error.invalidPrivateKeySize }
    }
    
    func checkPublicKeySize() throws {
        guard count == 65 else { throw SECP256K1Error.invalidPublicKeySize }
    }
}

/// Errors for secp256k1
public enum SECP256K1Error: Error {
    /// Signature required 1024 rounds and failed
    case signingFailed
    /// Cannot verify private key
    case invalidPrivateKey
    /// Hash size should be 32 bytes long
    case invalidHashSize
    /// Private key size should be 32 bytes long
    case invalidPrivateKeySize
    /// Signature size should be 65 bytes long
    case invalidSignatureSize
    /// Public key size should be 65 bytes long
    case invalidPublicKeySize
    /// Printable / user displayable description
    public var localizedDescription: String {
        switch self {
        case .signingFailed:
            return "Signature required 1024 rounds and failed"
        case .invalidPrivateKey:
            return "Cannot verify private key"
        case .invalidHashSize:
            return "Hash size should be 32 bytes long"
        case .invalidPrivateKeySize:
            return "Private key size should be 32 bytes long"
        case .invalidSignatureSize:
            return "Signature size should be 65 bytes long"
        case .invalidPublicKeySize:
            return "Public key size should be 65 bytes long"
        }
    }
}

/// Errors for secp256k1
public enum SECP256DataError: Error {
    /// Cannot recover public key
    case cannotRecoverPublicKey
    /// Cannot extract public key from private key
    case cannotExtractPublicKeyFromPrivateKey
    /// Cannot make recoverable signature
    case cannotMakeRecoverableSignature
    /// Cannot parse signature
    case cannotParseSignature
    /// Cannot parse public key
    case cannotParsePublicKey
    /// Cannot serialize public key
    case cannotSerializePublicKey
    /// Cannot combine public keys
    case cannotCombinePublicKeys
    /// Cannot serialize signature
    case cannotSerializeSignature
    /// Signature corrupted
    case signatureCorrupted
    /// Invalid marshal signature size
    case invalidMarshalSignatureSize
    /// Printable / user displayable description
    public var localizedDescription: String {
        switch self {
        case .cannotRecoverPublicKey:
            return "Cannot recover public key"
        case .cannotExtractPublicKeyFromPrivateKey:
            return "Cannot extract public key from private key"
        case .cannotMakeRecoverableSignature:
            return "Cannot make recoverable signature"
        case .cannotParseSignature:
            return "Cannot parse signature"
        case .cannotParsePublicKey:
            return "Cannot parse public key"
        case .cannotSerializePublicKey:
            return "Cannot serialize public key"
        case .cannotCombinePublicKeys:
            return "Cannot combine public keys"
        case .cannotSerializeSignature:
            return "Cannot serialize signature"
        case .signatureCorrupted:
            return "Signature corrupted"
        case .invalidMarshalSignatureSize:
            return "Invalid marshal signature size"
        }
    }
}

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

public class Crypto {
    struct UnmarshaledSignature {
        var v: UInt8
        var r = [UInt8](repeating: 0, count: 32)
        var s = [UInt8](repeating: 0, count: 32)
    }
    
    static var secp256k1_N = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
    static var secp256k1_halfN = secp256k1_N >> 2
    
    static var context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
    
    
    // throws SECP256K1Error
    static func signer(hash: Data, privateKey: Data, useExtraEntropy: Bool = false) -> String? {
        do {
            try hash.checkHashSize()
            try Crypto.verifyPrivateKey(privateKey: privateKey)
        }
        catch {
            return nil
        }
        
        for _ in 0 ... 1024 {
            do {
                var recoverableSignature = try Crypto.recoverableSign(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
                let truePublicKey = try Crypto.privateKeyToPublicKey(privateKey: privateKey)
                let recoveredPublicKey = try Crypto.recoverPublicKey(hash: hash, recoverableSignature: &recoverableSignature)
                if Data(toByteArray(truePublicKey.data)) != Data(toByteArray(recoveredPublicKey.data)) {
                    continue
                }
                let serializedSignature = try Crypto.serializeSignature(recoverableSignature: &recoverableSignature)
                return serializedSignature.hex
            } catch {
                continue
            }
        }
        
        return nil
    }
    
    static func privateToPublic(privateKey: Data, compressed: Bool = false) throws -> Data {
        var publicKey = try Crypto.privateKeyToPublicKey(privateKey: privateKey)
        return try serializePublicKey(publicKey: &publicKey, compressed: compressed)
    }
    
    static func combineSerializedPublicKeys(keys: [Data], outputCompressed: Bool = false) throws -> Data {
        assert(!keys.isEmpty, "Combining 0 public keys")
        let numToCombine = keys.count
        var storage = ContiguousArray<secp256k1_pubkey>()
        let arrayOfPointers = UnsafeMutablePointer<UnsafePointer<secp256k1_pubkey>?>.allocate(capacity: numToCombine)
        defer {
            arrayOfPointers.deinitialize(count: numToCombine)
            arrayOfPointers.deallocate()
        }
        for i in 0 ..< numToCombine {
            let key = keys[i]
            let pubkey = try Crypto.parsePublicKey(serializedKey: key)
            storage.append(pubkey)
        }
        for i in 0 ..< numToCombine {
            withUnsafePointer(to: &storage[i]) { (ptr) -> Void in
                arrayOfPointers.advanced(by: i).pointee = ptr
            }
        }
        let immutablePointer = UnsafePointer(arrayOfPointers)
        var publicKey = secp256k1_pubkey()

        let result = withUnsafeMutablePointer(to: &publicKey) { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
            let res = secp256k1_ec_pubkey_combine(context!, pubKeyPtr, immutablePointer, numToCombine)
            return res
        }
        guard result != 0 else { throw SECP256DataError.cannotCombinePublicKeys }
        return try Crypto.serializePublicKey(publicKey: &publicKey, compressed: outputCompressed)
    }
    
    static func recoverPublicKey(hash: Data, recoverableSignature: inout secp256k1_ecdsa_recoverable_signature) throws -> secp256k1_pubkey {
        try hash.checkHashSize()
        var publicKey: secp256k1_pubkey = secp256k1_pubkey()
        let result = hash.withUnsafeBytes { (hashPointer: UnsafePointer<UInt8>) -> Int32 in
            withUnsafePointer(to: &recoverableSignature, { (signaturePointer: UnsafePointer<secp256k1_ecdsa_recoverable_signature>) in
                withUnsafeMutablePointer(to: &publicKey, { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) in
                    secp256k1_ecdsa_recover(context!, pubKeyPtr, signaturePointer, hashPointer)
                })
            })
        }
        guard result != 0 else { throw SECP256DataError.cannotRecoverPublicKey }
        return publicKey
    }
    
    static func privateKeyToPublicKey(privateKey: Data) throws -> secp256k1_pubkey {
        try privateKey.checkPrivateKeySize()
        var publicKey = secp256k1_pubkey()
        let result = privateKey.withUnsafeBytes { (privateKeyPointer: UnsafePointer<UInt8>) in
            secp256k1_ec_pubkey_create(context!, &publicKey, privateKeyPointer)
        }
        guard result != 0 else { throw SECP256DataError.cannotExtractPublicKeyFromPrivateKey }
        return publicKey
    }
    
    static func serializePublicKey(publicKey: inout secp256k1_pubkey, compressed: Bool = false) throws -> Data {
        var keyLength = compressed ? 33 : 65
        var serializedPubkey = Data(repeating: 0x00, count: keyLength)
        let flags = UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED)
        let result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer: UnsafeMutablePointer<UInt8>) -> Int32 in
            withUnsafeMutablePointer(to: &keyLength, { (keyPtr: UnsafeMutablePointer<Int>) in
                withUnsafeMutablePointer(to: &publicKey, { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) in
                    secp256k1_ec_pubkey_serialize(context!, serializedPubkeyPointer, keyPtr, pubKeyPtr, flags)
                })
            })
        }
        guard result != 0 else { throw SECP256DataError.cannotSerializePublicKey }
        return Data(serializedPubkey)
    }
    
    static func parsePublicKey(serializedKey: Data) throws -> secp256k1_pubkey {
        try serializedKey.checkSignatureSize(maybeCompressed: true)
        let keyLen: Int = Int(serializedKey.count)
        var publicKey = secp256k1_pubkey()
        let result = serializedKey.withUnsafeBytes { (serializedKeyPointer: UnsafePointer<UInt8>) in
            secp256k1_ec_pubkey_parse(context!, &publicKey, serializedKeyPointer, keyLen)
        }
        guard result != 0 else { throw SECP256DataError.cannotParsePublicKey }
        return publicKey
    }
    
    static func parseSignature(signature: Data) throws -> secp256k1_ecdsa_recoverable_signature {
        try signature.checkSignatureSize()
        var recoverableSignature = secp256k1_ecdsa_recoverable_signature()
        let serializedSignature = Data(signature[0 ..< 64])
        var v = Int32(signature[64])
        
        /*
         fix for web3.js signs
         eth-lib code: vrs.v < 2 ? vrs.v : 1 - (vrs.v % 2)
         https://github.com/MaiaVictor/eth-lib/blob/d959c54faa1e1ac8d474028ed1568c5dce27cc7a/src/account.js#L60
         */
        v = v < 2 ? v : 1 - (v % 2)
        let result = serializedSignature.withUnsafeBytes { (serPtr: UnsafePointer<UInt8>) -> Int32 in
            withUnsafeMutablePointer(to: &recoverableSignature, { (signaturePointer: UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>) in
                secp256k1_ecdsa_recoverable_signature_parse_compact(context!, signaturePointer, serPtr, v)
            })
        }
        guard result != 0 else { throw SECP256DataError.cannotParseSignature }
        return recoverableSignature
    }
    
    static func serializeSignature(recoverableSignature: inout secp256k1_ecdsa_recoverable_signature) throws -> Data {
        var serializedSignature = Data(repeating: 0x00, count: 64)
        var v: Int32 = 0
        let result = serializedSignature.withUnsafeMutableBytes { (serSignaturePointer: UnsafeMutablePointer<UInt8>) -> Int32 in
            withUnsafePointer(to: &recoverableSignature) { (signaturePointer: UnsafePointer<secp256k1_ecdsa_recoverable_signature>) in
                withUnsafeMutablePointer(to: &v, { (vPtr: UnsafeMutablePointer<Int32>) in
                    secp256k1_ecdsa_recoverable_signature_serialize_compact(context!, serSignaturePointer, vPtr, signaturePointer)
                })
            }
        }
        guard result != 0 else { throw SECP256DataError.cannotSerializeSignature }
        if v == 0 {
            serializedSignature.append(0x00)
        } else if v == 1 {
            serializedSignature.append(0x01)
        } else {
            throw SECP256DataError.cannotSerializeSignature
        }
        return Data(serializedSignature)
    }
    
    static func sha256(_ data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        
        return Data(hash)
    }
    
    static func sha256sha256(_ input: Data) -> Data? {
        return sha256(sha256(input))
    }
    
    static func recoverableSign(hash: Data, privateKey: Data, useExtraEntropy: Bool = true) throws -> secp256k1_ecdsa_recoverable_signature {
        try hash.checkHashSize()
        try Crypto.verifyPrivateKey(privateKey: privateKey)
        var recoverableSignature: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature()
        let extraEntropy = Data.random(length: 32)
        let result = hash.withUnsafeBytes { (hashPointer: UnsafePointer<UInt8>) -> Int32 in
            privateKey.withUnsafeBytes { (privateKeyPointer: UnsafePointer<UInt8>) in
                extraEntropy.withUnsafeBytes { (extraEntropyPointer: UnsafePointer<UInt8>) in
                    withUnsafeMutablePointer(to: &recoverableSignature, { (recSignaturePtr: UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>) in
                        secp256k1_ecdsa_sign_recoverable(context!, recSignaturePtr, hashPointer, privateKeyPointer, nil, useExtraEntropy ? extraEntropyPointer : nil)
                    })
                }
            }
        }
        guard result != 0 else { throw SECP256DataError.cannotMakeRecoverableSignature }
        return recoverableSignature
    }
    
    static func recoverPublicKey(hash: Data, signature: Data, compressed: Bool = false) throws -> Data {
        var recoverableSignature = try parseSignature(signature: signature)
        var publicKey = try Crypto.recoverPublicKey(hash: hash, recoverableSignature: &recoverableSignature)
        return try Crypto.serializePublicKey(publicKey: &publicKey, compressed: compressed)
    }
    
    static func verifyPrivateKey(privateKey: Data) throws {
        try privateKey.checkPrivateKeySize()
        let result = privateKey.withUnsafeBytes { (privateKeyPointer: UnsafePointer<UInt8>) -> Int32 in
            secp256k1_ec_seckey_verify(context!, privateKeyPointer)
        }
        guard result == 1 else { throw SECP256K1Error.invalidPrivateKey }
    }
}

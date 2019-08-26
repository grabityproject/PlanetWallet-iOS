//
//  BtcRawTx.swift
//  PlanetWallet
//
//  Created by 박상은 on 26/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import BigInt

class BtcRawTx{

    public static func generateRawTx( tx:Transaction, privateKey:String )->String{

        
        let publicKey = publicFromPrivateKey(privateKey)
        if publicKey.isEmpty { return String() }

        var feePerByte:Int = 10;
        if let gasPrice = tx.gasPrice{
            feePerByte = Int(gasPrice) ?? feePerByte
        }

        guard let utxos = tx.utxos else { return String() }

        if utxos.count == 0 { return String() }

        guard let value = tx.amount else { return String() }

        let inputs = selection(amount: value, fee: feePerByte, utxos: utxos)

        let amount = BigInt(value)!
        
        print(amount)
        
        var inputTotal = BigInt()
        let estimateFee = BigInt( "\(( feePerByte * ( inputs.count * 148 + 2 * 34 + 10 + 2 ) ))", radix: 10 )
        inputs.forEach { (input) in
            inputTotal = inputTotal + BigInt(input.value!, radix: 10)!
        }
        let change = inputTotal - estimateFee! - amount
        
        if change < 0 { return String() }

        guard let toAddress = tx.toAddress, let fromAddress = tx.fromAddress else { return String() }
        
        var outputs = [UTXO]()

        let outputTo = UTXO()
        outputTo.script = scriptPubKey(toAddress)
        outputTo.value = value
        
        let outputChange = UTXO()
        outputChange.script = scriptPubKey(fromAddress)
        outputChange.value = String(change)
        
        outputs.append(outputTo)
        outputs.append(outputChange)

        for i in 0..<inputs.count{

            let unsignedScript = unsignedScriptSig(inputs, outputs, i)
            let der = signer(unsignedScript, privateKey)
            var signedScript = String()
            
            signedScript.append(contentsOf: decimalToHexString( ( Data(hexString: der)!.count + 1 ) ))
            signedScript.append(contentsOf: der)
            signedScript.append(contentsOf: decimalToHexString(1))
            signedScript.append(contentsOf: decimalToHexString( Data(hexString: publicKey)!.count ))
            signedScript.append(contentsOf: publicKey)
            
            inputs[i].signedScript = signedScript

        }
        
        return signedTx(inputs, outputs)
    }
    
    
    public static func EstimateFee( tx:Transaction )->String{
        
        var feePerByte:Int = 10;
        if let gasPrice = tx.gasPrice{
            feePerByte = Int(gasPrice) ?? feePerByte
        }
        
        guard let utxos = tx.utxos else { return String() }
        
        if utxos.count == 0 { return String() }
        
        guard let value = tx.amount else { return String() }
        
        let inputs = selection(amount: value, fee: feePerByte, utxos: utxos)
        
        let amount = BigInt(value)!
        
        guard let estimateFee = BigInt( "\(( feePerByte * ( inputs.count * 148 + 2 * 34 + 10 + 2 ) ))", radix: 10 ) else { return String() }
        
        return String(estimateFee)
    }
    
    private static func unsignedScriptSig(_ inputs:[UTXO],_ outputs:[UTXO], _ inputIndex:Int )->String{
        var unsignedScript = String()
        
        let version = reverseHexString( paddingZeroLeft( decimalToHexString(1), 8) )
        let inputCount = decimalToHexString(inputs.count)
        let inScript = inputScript(inputs, inputIndex)
        let outputCount = decimalToHexString(outputs.count)
        let outScript = outputScript(outputs)
        let lockTime = paddingZero( 8 )
        let sigHashCode = reverseHexString( paddingZeroLeft( decimalToHexString( 1 ), 8 ) )
        
        unsignedScript.append(contentsOf: version)
        unsignedScript.append(contentsOf: inputCount)
        unsignedScript.append(contentsOf: inScript)
        unsignedScript.append(contentsOf: outputCount)
        unsignedScript.append(contentsOf: outScript)
        unsignedScript.append(contentsOf: lockTime)
        unsignedScript.append(contentsOf: sigHashCode)
        
        
        return Data(hexString: unsignedScript)!.sha256().sha256().toHexString()
    }
    
    private static func signedTx(_ inputs:[UTXO],_ outputs:[UTXO] )->String{
        var rawTx = String()
        
        let version = reverseHexString( paddingZeroLeft( decimalToHexString(1), 8) )
        let inputCount = decimalToHexString(inputs.count)
        let inputScript = inputScriptSig(inputs)
        let outputCount = decimalToHexString(outputs.count)
        let outScript = outputScript(outputs)
        let lockTime = paddingZero( 8 )
        
        rawTx.append(contentsOf: version)
        rawTx.append(contentsOf: inputCount)
        rawTx.append(contentsOf: inputScript)
        rawTx.append(contentsOf: outputCount)
        rawTx.append(contentsOf: outScript)
        rawTx.append(contentsOf: lockTime)
        
        return rawTx
    }
    
    static func selection( amount:String, fee:Int, utxos:[UTXO] )->[UTXO]{
        var inputs:[UTXO] = [UTXO]()
        let value = BigInt(amount, radix: 10)!
        var total = BigInt()

        for i in 0..<utxos.count {
            total = total + BigInt(utxos[i].value!, radix: 10)!;
            inputs.append(utxos[i])
            let totalValue = value + BigInt("\(( fee * ( ( i + 1 ) * 148 + 2 * 34 + 10 + i + 1 ) ))", radix: 10)!;
            if total > totalValue {
                return inputs;
            }
        }
        return inputs;
    }
    
    static func utxoSort(_ utxos:[UTXO] )->[UTXO]{
        return utxos.sorted(by: { (u1, u2) -> Bool in
            
            if let blockHeight1 = u1.block_height, let blockHeight2 = u2.block_height{
                
                if let outputIndex1 = u1.tx_output_n, let outputIndex2 = u2.tx_output_n{
                    
                    if Int(blockHeight1)! < Int(blockHeight2)! {
                        return true;
                    }else if Int(blockHeight1)! > Int(blockHeight2)! {
                        return false;
                        
                    }else{
                        if Int(outputIndex1)! < Int(outputIndex2)! {
                            return true;
                        }else if Int(outputIndex1)! > Int(outputIndex2)! {
                            return false;
                        }else {
                            return Decimal(string: u1.value!)! < Decimal(string: u2.value!)!
                        }
                    }
                }
                
            }else{
                
                if let outputIndex1 = u1.tx_output_n, let outputIndex2 = u2.tx_output_n{
                    
                    if Int(outputIndex1)! < Int(outputIndex2)! {
                        return true;
                    }else if Int(outputIndex1)! > Int(outputIndex2)! {
                        return false;
                    }else {
                        return Decimal(string: u1.value!)! < Decimal(string: u2.value!)!
                    }
                }
                
            }
            
            return false;
        })
    }
    
    private static func outputScript(_ outputs:[UTXO] )->String{
        var outputScript = String()
        
        for i in 0..<outputs.count{
            
            let value = reverseHexString(paddingZeroLeft(decimalToHexString(outputs[i].value!), 16))
            let script = outputs[i].script!
            let scriptLength = decimalToHexString( Data(hexString: script)!.count )
            
            outputScript.append(contentsOf: value)
            outputScript.append(contentsOf: scriptLength)
            outputScript.append(contentsOf: script)
        }
        
        return outputScript
    }
    
    private static func inputScript(_ inputs:[UTXO], _ inputIndex:Int )->String{
        var inputScript = String()
        
        for i in 0..<inputs.count{
            
            let prevHashReverse = reverseHexString(inputs[i].tx_hash!)
            let outputIndex = reverseHexString( paddingZeroLeft( decimalToHexString( inputs[i].tx_output_n! ), 8))
            
            let script = ( i == inputIndex ) ? inputs[i].script! : ""
            let scriptLength = decimalToHexString( Data(hexString: script)!.count)
            let sequence = paddingLeft("", "f", 8)
            
            inputScript.append(contentsOf: prevHashReverse)
            inputScript.append(contentsOf: outputIndex)
            inputScript.append(contentsOf: scriptLength)
            inputScript.append(contentsOf: script)
            inputScript.append(contentsOf: sequence)
        }
        
        return inputScript
    }
    
    private static func inputScriptSig(_ inputs:[UTXO] )->String{
        var inputScript = String()
        
        for i in 0..<inputs.count{
            
            let prevHashReverse = reverseHexString(inputs[i].tx_hash!)
            let outputIndex = reverseHexString( paddingZeroLeft( decimalToHexString( inputs[i].tx_output_n! ), 8))
            
            let script = inputs[i].signedScript!
            let scriptLength = decimalToHexString( Data(hexString: script)!.count )
            let sequence = paddingLeft("", "f", 8)
            
            inputScript.append(contentsOf: prevHashReverse)
            inputScript.append(contentsOf: outputIndex)
            inputScript.append(contentsOf: scriptLength)
            inputScript.append(contentsOf: script)
            inputScript.append(contentsOf: sequence)
        }
        
        return inputScript
    }
    
    public static func scriptPubKey(_ address:String )->String{
        var fromScript = Data(base58Decoding: address)!
        fromScript.removeLast()
        fromScript.removeLast()
        fromScript.removeLast()
        fromScript.removeLast()
        fromScript.removeFirst()
        return "76a914\(fromScript.toHexString())88ac"
    }
    
    private static func paddingZero(_ size:Int )->String{
        return paddingLeft("", "0", size)
    }
    
    private static func paddingZeroLeft(_ str:String, _ size:Int )->String{
        return paddingLeft(str, "0", size)
    }
    
    private static func paddingZeroRight(_ str:String, _ size:Int )->String{
        return paddingRight(str, "0", size)
    }
    
    private static func paddingLeft(_ str:String,_ padding:String,_ size:Int )->String{
        var buffer = String()
        for _ in 0..<size-str.count{
            buffer.append(contentsOf: padding)
        }
        buffer.append(contentsOf: str)
        return buffer
    }
    
    private static func paddingRight(_ str:String,_ padding:String,_ size:Int )->String{
        var buffer = str
        for _ in 0..<size-str.count{
            buffer.append(contentsOf: padding)
        }
        return buffer
    }
    
    private static func decimalToHexString(_ decimal:Int )->String{
        let string = String(decimal, radix: 16)
        return ( string.count % 2 != 0 ? "0" : "" ) + string
    }
    
    private static func decimalToHexString(_ decimalString:String )->String{
        let string = String(BigInt(decimalString, radix: 10)!, radix: 16)
        return ( string.count % 2 != 0 ? "0" : "" ) + string
    }
    
    private static func reverseHexString(_ str:String )->String{
        var data = Data(hexString: str)!
        data.reverse()
        return data.toHexString()
    }
    
    private static func signer(_ hashMessage:String, _ privateKey:String  )->String{
        
        if let hash = Data(hexString: hashMessage), let privKey = Data(hexString:privateKey) {
            if let signature = Crypto.signer(hash: hash, privateKey: privKey){
                return toDer(signature)
            }
        }
        
        return String()
    }

    private static func toDer(_ signature:String  )->String{
        
        if let sigData = Data(hexString: signature) {
            
            let halfIdx = Int((sigData.count - 1) / 2)
            let r = sigData.subdata(in: 0..<halfIdx)
            let s = sigData.subdata(in: halfIdx..<sigData.count - 1)
            let v = sigData.subdata(in: sigData.count-1..<sigData.count)
            
            var ret = "30"
            var rPrefix = "";
            var sPrefix = "";
            
            if(  Int(r.subdata(in: 0..<1).hexString, radix: 16)! > 127 ){
                rPrefix = "00";
            }
            if(  Int(s.subdata(in: 0..<1).hexString, radix: 16)! > 127 ){
                sPrefix = "00";
            }
            
            //length of remaining list of bytes
            ret += "\( 44 + ( rPrefix == "00" ? 1 : 0)  + ( sPrefix == "00" ? 1 : 0 ) )"
            
            //
            ret += "02"
            
            //length of (v + r)
            ret += "\( 20 + ( rPrefix == "00" ? 1 : 0) )"
            
            //r
            ret = ret + rPrefix + r.hex
            
            //
            ret += "02"
            
            //length of (v + s)
            ret += "\( 20 + ( sPrefix == "00" ? 1 : 0) )"
            
            //s
            ret = ret + sPrefix + s.hex
            
            return ret;
        }
        
        return String()
    }
    
    private static func publicFromPrivateKey(_ privateKey:String )->String{
        
        if let privKeyData = Data(hexString: privateKey) {
            do {
                
                let publicKey = try Crypto.privateToPublic(privateKey: privKeyData, compressed: true)
                return publicKey.hexString
                
            } catch {
                
            }
        }
        
        return String()
    }
}

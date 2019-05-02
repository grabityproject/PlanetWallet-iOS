//
//  Extension + Data.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

extension Data {
    /// Initializes `Data` with a hex string representation.
    public init?(hexString: String) {
        let string: String
        if hexString.hasPrefix("0x") {
            string = String(hexString.dropFirst(2))
        } else {
            string = hexString
        }
        
        // Convert the string to bytes for better performance
        guard let stringData = string.data(using: .ascii, allowLossyConversion: true) else {
            return nil
        }
        
        self.init(capacity: string.count / 2)
        let stringBytes = Array(stringData)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            guard let high = Data.value(of: stringBytes[i]) else {
                return nil
            }
            if i < stringBytes.count - 1, let low = Data.value(of: stringBytes[i + 1]) {
                append((high << 4) | low)
            } else {
                append(high)
            }
        }
    }
    
    /// Converts an ASCII byte to a hex value.
    private static func value(of nibble: UInt8) -> UInt8? {
        switch nibble {
        case UInt8(ascii: "0") ... UInt8(ascii: "9"):
            return nibble - UInt8(ascii: "0")
        case UInt8(ascii: "a") ... UInt8(ascii: "f"):
            return 10 + nibble - UInt8(ascii: "a")
        case UInt8(ascii: "A") ... UInt8(ascii: "F"):
            return 10 + nibble - UInt8(ascii: "A")
        default:
            return nil
        }
    }
    
    /// Returns the hex string representation of the data.
    public var hexString: String {
        var string = ""
        for byte in self {
            string.append(String(format: "%02x", byte))
        }
        return string
    }
}

protocol BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

extension BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }
    
    static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8: BinaryConvertible {}
extension UInt16: BinaryConvertible {}
extension UInt32: BinaryConvertible {}
extension UInt64: BinaryConvertible {}
extension Int8: BinaryConvertible {}
extension Int16: BinaryConvertible {}
extension Int32: BinaryConvertible {}
extension Int64: BinaryConvertible {}
extension Int: BinaryConvertible {}

extension Bool: BinaryConvertible {
    static func +(lhs: Data, rhs: Bool) -> Data {
        return lhs + (rhs ? UInt8(0x01) : UInt8(0x00)).littleEndian
    }
}

extension String: BinaryConvertible {
    static func +(lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .ascii) else { return lhs }
        return lhs + data
    }
}

extension Data: BinaryConvertible {
    static func +(lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        return data
    }
}


extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    func to(type: String.Type) -> String {
        return String(bytes: self, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }
    
    
}

extension Data {
    public init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    public var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    var hexEncoded: String {
        return "0x" + self.hex
    }
    
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

//
//  BitcoinUnit.swift
//  PlanetWallet
//
//  Created by grabity on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

public enum BitcoinUnit: Int {
    case SATOSHI = 0
    case BIT = 8
}

extension BitcoinUnit {
    var name: String {
        switch self {
        case .SATOSHI: return "Satoshi"
        case .BIT: return "Bit"
        }
    }
    
    var value: Int {
        switch self {
        case .SATOSHI: return self.rawValue
        case .BIT: return self.rawValue
        }
    }
}

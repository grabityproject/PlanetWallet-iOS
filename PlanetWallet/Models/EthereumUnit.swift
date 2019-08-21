//
//  EthereumUnit.swift
//  PlanetWallet
//
//  Created by grabity on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

public enum EthereumUnit: Int {
    case WEI = 0
    case KWEI = 3
    case GWEI = 9
    case ETHER = 18
}

extension EthereumUnit {
    var name: String {
        switch self {
        case .WEI: return "Wei"
        case .KWEI: return "Kwei"
        case .GWEI: return "Gwei"
        case .ETHER: return "Ether"
        }
    }
    
    var value: Int {
        switch self {
        case .WEI: return self.rawValue
        case .KWEI: return self.rawValue
        case .GWEI: return self.rawValue
        case .ETHER: return self.rawValue
        }
    }
}

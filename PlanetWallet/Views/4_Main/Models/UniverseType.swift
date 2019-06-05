//
//  UniverseType.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

enum UniverseType {
    case ETH
    case BTC
    
    func description() -> String {
        switch self {
        case .ETH:      return "ETH Universe"
        case .BTC:      return "BTC Universe"
        }
    }
}


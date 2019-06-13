//
//  BTCTransaction.swift
//  PlanetWallet
//
//  Created by grabity on 13/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct BTCTransaction {
    enum Direction {
        case IN_COMING
        case OUT_COMING
    }
    
    let amount: Double
    let to: String
    let from: String
    let date: Date
    let direction: BTCTransaction.Direction
}

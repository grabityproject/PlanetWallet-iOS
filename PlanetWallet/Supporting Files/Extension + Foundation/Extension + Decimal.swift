//
//  Extension + Decimal.swift
//  PlanetWallet
//
//  Created by grabity on 20/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}

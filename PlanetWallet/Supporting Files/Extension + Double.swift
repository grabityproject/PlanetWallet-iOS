//
//  Extension + Double.swift
//  PlanetWallet
//
//  Created by grabity on 13/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

extension Double {
    func rounded(_ digits: Int) -> Double {
        let numOfDigits = Double(truncating: pow(10, digits) as NSNumber)
        return (self * numOfDigits).rounded() / numOfDigits
    }
}

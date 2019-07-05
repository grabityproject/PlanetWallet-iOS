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
    
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}

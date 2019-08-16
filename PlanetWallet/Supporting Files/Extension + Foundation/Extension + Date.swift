//
//  Extension + Date.swift
//  PlanetWallet
//
//  Created by grabity on 16/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(millis: Int64) {
        
        self = Date(timeIntervalSince1970: TimeInterval(millis))
    }
}

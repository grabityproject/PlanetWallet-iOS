//
//  Planet.swift
//  PlanetWallet
//
//  Created by grabity on 20/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

struct Contact {
    let name: String
    let address: String
    let type: UniverseType
    
    init(name: String, address: String, type: UniverseType) {
        self.name = name
        self.address = address
        self.type = type
    }
    
}

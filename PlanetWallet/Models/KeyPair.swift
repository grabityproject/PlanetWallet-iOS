//
//  KeyPair.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class KeyPair: Mappable {
    var keyId: String?
    var value: String?
    var master: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        keyId <- map["keyId"]
        value <- map["value"]
        master <- map ["master"]
    }
}

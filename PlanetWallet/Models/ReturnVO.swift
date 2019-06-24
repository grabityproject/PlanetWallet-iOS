
//
//  ReturnVO.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class ReturnVO: Mappable {
    var success: Bool?
    var result: Any?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        success <- map["success"] //true, false
        result <- map["result"]
    }
}

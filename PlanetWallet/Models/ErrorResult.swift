//
//  ErrorResult.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class ErrorResult: Mappable {
    var errorCode: Int?
    var errorMsg: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        errorCode <- map["errorCode"]
        errorMsg <- map["errorMsg"]
    }
}

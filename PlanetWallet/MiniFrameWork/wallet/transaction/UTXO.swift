//
//  UTXO.swift
//  PlanetWallet
//
//  Created by 박상은 on 26/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import ObjectMapper

class UTXO: Mappable {
    
    var block_height:String?
    var tx_hash:String?
    var value:String?
    var script:String?
    var tx_output_n:String?;
    
    var signedScript:String?;
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        block_height     <- map["block_height"];
        tx_hash          <- map["tx_hash"];
        value            <- map["value"];
        script           <- map["script"];
        tx_output_n      <- map["tx_output_n"];
    }
  
}

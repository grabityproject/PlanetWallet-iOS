//
//  Route.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

class Route{
    
    private static var baseURL : String = "https://api.planetwallet.io"
    
    static func URL(_ segments : String...) -> String {
        if TESTNET {
            baseURL = "https://test.planetwallet.io"
        }
        
        var result : String = ""
        for segment in segments{
            result += ( "/" + segment )
        }
        return Route.baseURL + result
    }
    
    static func URL(_ segments : String..., baseURL: String = Route.baseURL) -> String {
        var result : String = ""
        for segment in segments{
            result += ( "/" + segment )
        }
        return baseURL + result
    }
}

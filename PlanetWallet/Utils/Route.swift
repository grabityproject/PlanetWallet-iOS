//
//  Route.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

class Route{
    
    private static let baseURL : String = "https://test.planetwallet.io"
    
    static func URL(_ segments : String...) -> String {
        var result : String = ""
        for segment in segments{
            result += ( "/" + segment )
        }
        return Route.baseURL + result
    }
    
}

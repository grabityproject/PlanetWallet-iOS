//
//  PWSlider.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PWSlider: UISlider {

    @IBInspectable var trackHeight: CGFloat = 3.9
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = trackHeight
        return result
    }
    

}

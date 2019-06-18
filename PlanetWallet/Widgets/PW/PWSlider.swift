//
//  PWSlider.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PWSlider: UISlider, Themable {

    @IBInspectable var trackHeight: CGFloat = 3.9
    @IBInspectable var themeMaxTrackColor: UIColor = UIColor(red: 30, green: 30, blue: 80)
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = trackHeight
        return result
    }
    
    func setTheme(_ theme: Theme) {
        if( theme == Theme.LIGHT ){
            self.maximumTrackTintColor = themeMaxTrackColor
        }else{
            self.maximumTrackTintColor = UIColor(red: 30, green: 30, blue: 40)
        }
    }
}

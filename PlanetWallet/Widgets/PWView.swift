//
//  PWView.swift
//  PlanetViewTest
//
//  Created by 박상은 on 09/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

class PWView: UIView, Themable {
    
    private var defaultBackgroundColor: UIColor?
    private var defaultBorderColor: UIColor?
    
    @IBInspectable var themeBackgroundColor: UIColor?{
        didSet{
            self.defaultBackgroundColor = self.backgroundColor
        }
    }
    
    @IBInspectable var themeBorderColor: UIColor?{
        didSet{
            self.defaultBorderColor = borderColor
        }
    }
    
    func setTheme(_ theme: Theme) {
        if( theme == Theme.LIGHT ){
            if( defaultBackgroundColor == nil ){
                defaultBackgroundColor = self.backgroundColor;
            }
            if( defaultBorderColor == nil ){
                defaultBorderColor = borderColor;
            }
            
            self.backgroundColor = self.themeBackgroundColor
            self.layer.borderColor = themeBorderColor?.cgColor;
        }else{
            if( self.defaultBackgroundColor != nil ){
                self.backgroundColor = self.defaultBackgroundColor
            }
            if( self.defaultBorderColor != nil ){
                self.layer.borderColor = defaultBorderColor?.cgColor;
            }
        }
    }
}

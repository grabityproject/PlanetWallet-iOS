//
//  PWButton.swift
//  PlanetViewTest
//
//  Created by 박상은 on 09/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

@IBDesignable class PWButton: UIButton, Themable {
    
    private var defaultBackgroundColor: UIColor?
    private var defaultBorderColor: UIColor?
    private var defaultTextNormalColor: UIColor?
    private var defaultTextHighlightColor: UIColor?
    private var defaultTextDisableColor: UIColor?
    
    @IBInspectable var themeBackgroundColor: UIColor?{
        didSet{
            self.defaultBackgroundColor = self.backgroundColor
        }
    }
    
    @IBInspectable var themeBorderColor: UIColor?{
        didSet{
            self.defaultBorderColor = borderColor;
        }
    }
    
    @IBInspectable var themeTextNormalColor: UIColor?{
        didSet{
            self.defaultTextNormalColor = self.titleColor(for: .normal)
        }
    }
    
    @IBInspectable var themeTextHighlightColor: UIColor?{
        didSet{
            self.defaultTextHighlightColor = self.titleColor(for: .highlighted)
        }
    }
    
    @IBInspectable var themeTextDisableColor: UIColor?{
        didSet{
            self.defaultTextDisableColor = self.titleColor(for: .disabled)
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
            if( defaultTextNormalColor == nil ){
                defaultTextNormalColor = self.titleColor(for: .normal);
            }
            if( defaultTextHighlightColor == nil ){
                defaultTextHighlightColor = self.titleColor(for: .highlighted);
            }
            if( defaultTextDisableColor == nil ){
                defaultTextDisableColor = self.titleColor(for: .disabled);
            }
            
            self.backgroundColor = self.themeBackgroundColor
            self.setTitleColor(themeTextNormalColor, for: .normal);
            self.setTitleColor(themeTextHighlightColor, for: .highlighted);
            self.setTitleColor(themeTextDisableColor, for: .disabled);
            self.layer.borderColor = themeBorderColor?.cgColor;
            
        }else{
            if( self.defaultBackgroundColor != nil ){
                self.backgroundColor = self.defaultBackgroundColor
            }
            if( self.defaultTextNormalColor != nil ){
                self.setTitleColor(defaultTextNormalColor, for: .normal);
            }
            if( self.defaultTextHighlightColor != nil ){
                self.setTitleColor(defaultTextHighlightColor, for: .highlighted);
            }
            if( self.defaultTextDisableColor != nil ){
                self.setTitleColor(defaultTextDisableColor, for: .disabled);
            }
            if( self.defaultBorderColor != nil ){
                self.layer.borderColor = defaultBorderColor?.cgColor;
            }
        }
    }
}

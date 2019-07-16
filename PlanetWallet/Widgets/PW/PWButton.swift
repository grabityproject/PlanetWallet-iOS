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
    private var defaultBackgroundHighlightColor: UIColor?
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
//            self.defaultTextHighlightColor = self.titleColor(for: .highlighted)
        }
    }
    
    @IBInspectable var themeTextDisableColor: UIColor?{
        didSet{
            self.defaultTextDisableColor = self.titleColor(for: .disabled)
        }
    }
    
    @IBInspectable var highlightedCategory: Int = 0
    
    
    override open var isHighlighted: Bool {
        didSet {
            
            if highlightedCategory == 1 {
                //Type A
                if ThemeManager.currentTheme() == Theme.DARK {
                    backgroundColor = isHighlighted ? UIColor(red: 92, green: 89, blue: 100) : .white
                    self.setTitleColor(.black, for: .highlighted)
                }
                else {
                    backgroundColor = isHighlighted ? UIColor(red: 92, green: 89, blue: 100) : .black
                    self.setTitleColor(.white, for: .highlighted)
                }
            }
            else if highlightedCategory == 2 {
                //Type B
                let errColor = UIColor(red: 255, green: 0, blue: 80)
                if ThemeManager.currentTheme() == Theme.DARK {
                    self.layer.borderColor = isHighlighted ? errColor.cgColor : UIColor(red: 30, green: 30, blue: 40).cgColor
                    self.setTitleColor(errColor, for: .highlighted)
                }
                else {
                    self.layer.borderColor = isHighlighted ? errColor.cgColor : UIColor(red: 237, green: 237, blue: 237).cgColor
                    self.setTitleColor(errColor, for: .highlighted)
                }
            }
            else if highlightedCategory == 3 {
                //Type C
                if ThemeManager.currentTheme() == Theme.DARK {
                    backgroundColor = isHighlighted ? UIColor(red: 30, green: 30, blue: 40) : .clear
                }
                else {
                    backgroundColor = isHighlighted ? UIColor(red: 237, green: 237, blue: 237) : .clear
                }
            }
            else if highlightedCategory == 4 {
                //Type A reverse
                if ThemeManager.currentTheme() == Theme.DARK {
                    backgroundColor = isHighlighted ? UIColor(red: 92, green: 89, blue: 100) : .black
                    setTitleColor(.white, for: .highlighted)
                }
                else {
                    backgroundColor = isHighlighted ? UIColor(red: 92, green: 89, blue: 100) : .white
                    setTitleColor(.black, for: .highlighted)
                }
            }
            else if highlightedCategory == 5 {
                //Type B reverse
                let errColor = UIColor(red: 255, green: 0, blue: 80)
                if ThemeManager.currentTheme() == Theme.DARK {
                    self.layer.borderColor = isHighlighted ? errColor.cgColor : UIColor(red: 237, green: 237, blue: 237).cgColor
                    self.setTitleColor(errColor, for: .highlighted)
                }
                else {
                    self.layer.borderColor = isHighlighted ? errColor.cgColor : UIColor(red: 30, green: 30, blue: 40).cgColor
                    self.setTitleColor(errColor, for: .highlighted)
                }
            }
            else if highlightedCategory == 6 {
                //Type C reverse
                if ThemeManager.currentTheme() == Theme.DARK {
                    backgroundColor = isHighlighted ? UIColor(red: 237, green: 237, blue: 237) : .clear
                }
                else {
                    backgroundColor = isHighlighted ? UIColor(red: 30, green: 30, blue: 40) : .clear
                }
            }
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
//                defaultTextHighlightColor = self.titleColor(for: .highlighted);
            }
            if( defaultTextDisableColor == nil ){
                defaultTextDisableColor = self.titleColor(for: .disabled);
            }
            
            self.backgroundColor = self.themeBackgroundColor
            self.setTitleColor(themeTextNormalColor, for: .normal);
//            self.setTitleColor(themeTextHighlightColor, for: .highlighted);
            
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
//                self.setTitleColor(defaultTextHighlightColor, for: .highlighted);
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

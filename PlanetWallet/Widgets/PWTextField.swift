//
//  PWTextField.swift
//  PlanetViewTest
//
//  Created by 박상은 on 09/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

@IBDesignable class PWTextField: UITextField, Themable {
    
    private var defaultBackgroundColor: UIColor?
    private var defaultBorderColor: UIColor?
    private var defaultTextColor: UIColor?
    private var clearDarkImg: UIImage?
    private var clearLightImg: UIImage?
    
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
    
    @IBInspectable var themeTextColor: UIColor?{
        didSet{
            self.defaultTextColor = self.textColor
        }
    }
    
    @IBInspectable var clearImageDark: UIImage? {
        didSet {
            self.clearDarkImg = self.clearImageDark
        }
    }
    
    @IBInspectable var clearImageLight: UIImage? {
        didSet {
            self.clearLightImg = self.clearImageLight
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setClearBtn(img: UIImage) {
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        clearButton.setImage(img, for: [])
        clearButton.layer.cornerRadius = 12.5
        clearButton.layer.masksToBounds = true
        
        self.rightView = clearButton
        clearButton.addTarget(self, action: #selector(clearClicked), for: .touchUpInside)
        
        self.clearButtonMode = .never
        self.rightViewMode = .whileEditing
    }
    
    @objc func clearClicked(sender:UIButton)
    {
        self.text = ""
    }
    
    func setTheme(_ theme: Theme) {
        if( theme == Theme.LIGHT ){
            if( defaultBackgroundColor == nil ){
                defaultBackgroundColor = self.backgroundColor;
            }
            if( defaultTextColor == nil ){
                defaultTextColor = self.textColor;
            }
            if( defaultBorderColor == nil ){
                defaultBorderColor = borderColor;
            }
            if( clearLightImg == nil ) {
                clearLightImg = UIImage(named: "imageInputClearBlue")
            }
            
            self.backgroundColor = self.themeBackgroundColor
            self.textColor = self.themeTextColor;
            self.layer.borderColor = themeBorderColor?.cgColor;
            self.setClearBtn(img: clearLightImg!)
            
        }else{
            if( self.defaultBackgroundColor != nil ){
                self.backgroundColor = self.defaultBackgroundColor
            }
            if( self.defaultTextColor != nil ){
                self.textColor = defaultTextColor
            }
            
            if( self.defaultBorderColor != nil ){
                self.layer.borderColor = defaultBorderColor?.cgColor;
            }
            
            if( clearDarkImg == nil ) {
                clearDarkImg = UIImage(named: "imageInputClearBlack")
            }
            
            self.setClearBtn(img: clearDarkImg!)
        }
    }
}

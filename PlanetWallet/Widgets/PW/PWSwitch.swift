//
//  PWSwitch.swift
//  PlanetViewTest
//
//  Created by 박상은 on 14/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

public protocol PWSwitchDelegate{
    func didSwitch(_ sender:Any?, isOn:Bool)
}

@IBDesignable class PWSwitch: UIView, Themable {
    
    @IBInspectable var isOn: Bool = false;
    private var theme:Theme = .DARK;
    
    private var defaultColor : UIColor = UIColor.init(displayP3Red: 92.0/255.0, green: 89.0/255.0, blue: 100.0/255.0, alpha: 1.0);
    private var themeColor : UIColor = UIColor.init(displayP3Red: 17.0/255.0, green: 17.0/255.0, blue: 23.0/255.0, alpha: 1.0);
    
    private var circleView : UIView = UIView();
    private var maskCircleView : UIView = UIView();
    
    public var delegate : PWSwitchDelegate?;
    
    private func viewInit(){
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 51, height: 30)
        self.layer.cornerRadius = self.frame.height/2.0
        
        circleView.frame = CGRect(x: 5, y: 5, width: 20, height: 20);
        circleView.layer.cornerRadius = circleView.frame.height/2.0
        maskCircleView.frame = CGRect(x: 13, y: 5, width: 20, height: 20)
        maskCircleView.layer.cornerRadius = circleView.frame.height/2.0
        
        addSubview(circleView)
        addSubview(maskCircleView)
        
        
        circleView.backgroundColor = UIColor.white;
        maskCircleView.backgroundColor = self.defaultColor
        self.backgroundColor = self.defaultColor

        self.isUserInteractionEnabled = true;
        self.layer.masksToBounds = true;
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick(_:))));
    }
    
    @objc func onClick(_ sender:Any? ){
        isOn = !isOn;
        if( delegate != nil ){
            delegate?.didSwitch(self, isOn: self.isOn)
        }
        if( isOn ){
            UIView.animate(withDuration: 0.3) {
                self.circleView.frame = CGRect(x: self.frame.width - self.circleView.frame.width - 5, y: 5, width: 20, height: 20)
                self.maskCircleView.frame = CGRect(x: self.frame.width, y: 5, width: 20, height: 20)
                self.maskCircleView.backgroundColor =  UIColor.init(displayP3Red: 1, green: 0, blue: 80.0/255.0, alpha: 1)
                self.backgroundColor = UIColor.init(displayP3Red: 1, green: 0, blue: 80.0/255.0, alpha: 1)
            }
        }else{
            UIView.animate(withDuration: 0.3) {
                self.circleView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
                self.maskCircleView.frame = CGRect(x: 13, y: 5, width: 20, height: 20)
                self.maskCircleView.backgroundColor = self.theme == .LIGHT ? self.themeColor : self.defaultColor;
                self.backgroundColor = self.theme == .LIGHT ? self.themeColor : self.defaultColor;
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    override func prepareForInterfaceBuilder() {
        viewInit()
        setTheme(theme)
    }

    func setTheme(_ theme: Theme) {
        self.theme = theme;
        if( !self.isOn ){
            if( theme == .LIGHT){
                self.maskCircleView.backgroundColor = self.themeColor
                self.backgroundColor = self.themeColor
            }else{
                self.maskCircleView.backgroundColor = self.defaultColor
                self.backgroundColor = self.defaultColor
            }
        }
    }
    
}

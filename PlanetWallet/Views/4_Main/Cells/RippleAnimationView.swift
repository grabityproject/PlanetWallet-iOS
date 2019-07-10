//
//  RippleAnimationView.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RippleAnimationView: UIView {
    
    public var animationDuration = 0.4
    public var bgColor: UIColor {
        return ThemeManager.settingTheme().backgroundColor
    }
    public var startPosition: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.startPosition = frame.origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createRippleView() {
        self.alpha = 0
        self.backgroundColor = bgColor
        self.layer.cornerRadius = 0
        self.layer.masksToBounds = true
    }
    
    public func show(completion: @escaping (Bool) -> Void) {
        
        createRippleView()
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 1
            let rippleViewMaxRadius = SCREEN_HEIGHT * 2.0 * 1.4
            self.layer.cornerRadius = rippleViewMaxRadius / 2
            self.bounds = CGRect(origin: self.startPosition,
                                 size: CGSize(width: rippleViewMaxRadius, height: rippleViewMaxRadius))
        }) { (isSuccess) in
            completion(isSuccess)
        }
    }
    
    public func show() {
        
        createRippleView()
        
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 1
            let rippleViewMaxRadius = self.bounds.height * 2.0 * 1.4
            self.layer.cornerRadius = rippleViewMaxRadius / 2
            self.bounds = CGRect(origin: self.startPosition,
                                 size: CGSize(width: rippleViewMaxRadius, height: rippleViewMaxRadius))
        }
    }
    
    public func dismiss(completion: @escaping (Bool) -> Void) {
        self.backgroundColor = self.bgColor
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0
            self.layer.cornerRadius = 0
            self.bounds = CGRect(origin: self.startPosition,
                                 size: CGSize(width: 0, height: 0))
        }) { (isSuccess) in
            completion(isSuccess)
        }
    }
    
    public func dismiss() {
        self.backgroundColor = self.bgColor
        
        UIView.animate(withDuration: animationDuration) {
            self.backgroundColor = self.bgColor
            self.alpha = 0
            self.layer.cornerRadius = 0
            self.bounds = CGRect(origin: self.startPosition,
                                 size: CGSize(width: 0, height: 0))
        }
    }

}

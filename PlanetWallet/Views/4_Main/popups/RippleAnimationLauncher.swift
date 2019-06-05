//
//  RippleAnimationLauncher.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RippleAnimationLauncher: NSObject {
    private var rippleView: UIView!
    private var startPosition: CGPoint!
    
    convenience init(position: CGPoint) {
        self.init()
        
        self.rippleView = UIView()
        rippleView.frame.origin = position
    }
    
    private func createRippleView() {
        
//        rippleView.alpha = 0
//        rippleView.backgroundColor = settingTheme.backgroundColor
//        rippleView.layer.cornerRadius = 0
//        rippleView.layer.masksToBounds = true
//        self.view.addSubview(rippleView)
    }
    
    public func show() {
        
    }
}

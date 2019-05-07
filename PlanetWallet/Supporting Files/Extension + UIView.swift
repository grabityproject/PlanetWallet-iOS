//
//  Extension + UIView.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension UIView {
    
    var X: CGFloat { return self.frame.origin.x }
    var Y: CGFloat { return self.frame.origin.y }
    var WIDTH: CGFloat { return self.frame.size.width }
    var HEIGHT: CGFloat { return self.frame.size.height }
    
    func dropShadow(radius: CGFloat, cornerRadius: CGFloat = 5.0) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             cornerRadius: cornerRadius).cgPath
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.masksToBounds = true
    }
    
    func setGradientLinear(startColor: UIColor, lastColor: UIColor) {
        let colorTop =  startColor.cgColor
        let colorBottom = lastColor.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom, colorTop]
        gradientLayer.frame = self.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

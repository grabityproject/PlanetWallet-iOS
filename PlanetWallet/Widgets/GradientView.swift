//
//  GradientView.swift
//  PlanetViewTest
//
//  Created by 박상은 on 02/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit
@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

/*
@IBDesignable
class GradientView: UIView {
    
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
//            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
//            updateView()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.colors = [firstColor, secondColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint (x: 1, y: 0.5)
    }
 
    /*
    var firstColor: CGColor {
        switch ThemeManager.currentTheme() {
        case .DARK :    return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        case .LIGHT:    return UIColor(red: 255, green: 255, blue: 255, alpha: 0.3).cgColor
        }
    }
    
    var secondColor: CGColor {
        switch ThemeManager.currentTheme() {
        case .DARK :    return UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        case .LIGHT:    return UIColor(red: 255, green: 255, blue: 255, alpha: 1).cgColor
        }
    }
    */
    
    @IBInspectable var isHorizontal: Bool = false {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updateView() {
        gradientLayer.colors = [firstColor, secondColor]
        
        print(firstColor)
        print(secondColor)
        
        if (isHorizontal) {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint (x: 0.5, y: 1)
        }
        
        setNeedsDisplay()
    }
    
    /*
    func setTheme(theme: Theme) {
        switch theme {
        case .DARK:
            self.firstColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            self.secondColor = UIColor(red: 0, green: 0, blue: 0)
        case .LIGHT:
            self.firstColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
            self.secondColor = UIColor(red: 255, green: 255, blue: 255)
        }
    }
    */
}
*/

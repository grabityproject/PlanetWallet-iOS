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
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
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
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        if (isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
        
        setNeedsDisplay()
    }
    
    func setTheme(theme: Theme) {
        switch theme {
        case .DARK:
            self.firstColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            self.secondColor = UIColor(red: 0, green: 0, blue: 0)
        case .LIGHT:
            self.firstColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.45)
            self.secondColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
            self.alpha = 0.8
        }
        
        updateView()
    }
    
}

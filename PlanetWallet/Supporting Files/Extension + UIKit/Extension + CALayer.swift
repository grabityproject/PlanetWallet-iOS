//
//  Extension + CALayer.swift
//  PlanetWallet
//
//  Created by grabity on 27/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
    func addBorder(edges: [UIRectEdge], color: UIColor, thickness: CGFloat) {
        
        edges.forEach { (edge) in
            switch edge {
            case .top:
                self.addBorder(edge: .top, color: color, thickness: thickness)
            case .bottom:
                self.addBorder(edge: .bottom, color: color, thickness: thickness)
            case .left:
                self.addBorder(edge: .left, color: color, thickness: thickness)
            case .right:
                self.addBorder(edge: .right, color: color, thickness: thickness)
            default:
                break
            }
        }
    }
}

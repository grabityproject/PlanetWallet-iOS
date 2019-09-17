//
//  QROverlay.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class QROverlay: UIView {
    
    var path: UIBezierPath!
    let padding: CGFloat = 5
    let lineWidth: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let w = rect.width;
        let h = rect.height;
        
        let transparentRect = CGRect(x: padding + lineWidth,
                                     y: padding + lineWidth,
                                     width: w - (padding * 2) - (lineWidth * 2),
                                     height: h - (padding * 2) - (lineWidth * 2))

        self.createRoundedRect(corner: .topLeft)
        self.createRoundedRect(corner: .topRight)
        self.createRoundedRect(corner: .bottomLeft)
        self.createRoundedRect(corner: .bottomRight)

        createOverlayLayer(rect: rect, portionRect: transparentRect)
    }
    
    private func createOverlayLayer(rect: CGRect, portionRect: CGRect) {
        //-----Cover layer
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor(red: 255, green: 0, blue: 80).cgColor
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
        
        //-----Mask Layer
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.frame = rect
        maskLayer.fillColor = UIColor.green.cgColor
        
        let maskLayerPath = UIBezierPath()
        maskLayerPath.append(UIBezierPath(rect: rect))
        maskLayerPath.append(UIBezierPath(rect: portionRect))
        
        maskLayer.path = maskLayerPath.cgPath
        
        layer.mask = maskLayer
    }
    
    
    func createRoundedRect(corner: UIRectCorner) {
        let roundRectWidth: CGFloat = 28
        
        let size = CGSize(width: roundRectWidth, height: roundRectWidth)
        var origin: CGPoint!
        
        switch corner {
        case .topLeft:
            origin = CGPoint(x: padding - lineWidth,
                             y: padding - lineWidth)
        case .topRight:
            origin = CGPoint(x: self.frame.size.width - padding - roundRectWidth + lineWidth,
                             y: padding - lineWidth)
        case .bottomLeft:
            origin = CGPoint(x: padding - lineWidth,
                             y: self.frame.size.height - padding - roundRectWidth + lineWidth)
        case .bottomRight:
            origin = CGPoint(x: self.frame.size.width - padding - roundRectWidth + lineWidth,
                             y: self.frame.size.height - padding - roundRectWidth + lineWidth)
            
        default:
            break
        }
        
        let cornerRadSize = CGSize(width: 8.0, height: 0)
        let rect = CGRect(origin: origin, size: size)
        if path == nil {
            path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [corner],
                                cornerRadii: cornerRadSize)
        }
        else {
            path.append(UIBezierPath(roundedRect: rect,
                                     byRoundingCorners: [corner],
                                     cornerRadii: cornerRadSize))
        }
        
    }
}

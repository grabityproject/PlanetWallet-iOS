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
    let padding: CGFloat = 50
    let lineWidth: CGFloat = 3
    
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
        
        //-----꼭지점의 사각형
        self.createRoundedRect(corner: .topLeft)
        self.createRoundedRect(corner: .topRight)
        self.createRoundedRect(corner: .bottomLeft)
        self.createRoundedRect(corner: .bottomRight)
        
        //-----큰 사각형
        self.createRectangle()
        
        //-----Dim Layer
        createDimLayer(rect: rect, portionRect: transparentRect)
        
        //-----
        createOverlayLayer(rect: rect, portionRect: transparentRect)
        
    }
    
    private func createDimLayer(rect: CGRect, portionRect: CGRect) {
        let dimLayer = CAShapeLayer()
        dimLayer.frame = rect
        dimLayer.fillColor = UIColor(white: 0, alpha: 0.55).cgColor
        dimLayer.fillRule = CAShapeLayerFillRule.evenOdd
        dimLayer.cornerRadius = 15
        dimLayer.masksToBounds = true
        let dimLayerPath = UIBezierPath(rect: rect)
        dimLayerPath.append(UIBezierPath(rect: portionRect))
        
        dimLayer.path = dimLayerPath.cgPath
        
        self.layer.addSublayer(dimLayer)
    }
    
    private func createOverlayLayer(rect: CGRect, portionRect: CGRect) {
        //-----Cover layer
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.red.cgColor
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
        /*
         CGRect(x: w*(1/6.0),
         y: h*(1/6.0),
         width: w*(2/3.0),
         height: h*(2/3.0))
         */
        maskLayer.path = maskLayerPath.cgPath
        
        layer.mask = maskLayer
    }
    
    func createRectangle() {
        let width = frame.size.width - (padding * 2)
        if path == nil {
            path = UIBezierPath(rect: CGRect(x: padding,
                                             y: padding,
                                             width: width,
                                             height: width))
        }
        else {
            path.append(UIBezierPath(rect: CGRect(x: padding,
                                                  y: padding,
                                                  width: width,
                                                  height: width)))
        }
    }
    
    func createRoundedRect(corner: UIRectCorner) {
        
        
        let roundRectWidth: CGFloat = 20
        
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
        
        let cornerRadSize = CGSize(width: 5.0, height: 0)
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

//
//  RoundBorderView.swift
//  PlanetWallet
//
//  Created by grabity on 07/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

@IBDesignable
class RoundBorderView: UIView, Borderable, Roundable {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //        toRound(cornerRadius: cornerRadius)
        //        toBorder(width: borderWidth, color: borderColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //        toRound(cornerRadius: cornerRadius)
        //        toBorder(width: borderWidth, color: borderColor)
    }
}

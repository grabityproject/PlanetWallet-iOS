//
//  RoundBtn.swift
//  PlanetWallet
//
//  Created by grabity on 03/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

@IBDesignable
class RoundBtn: UIButton, Roundable {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        toRound(cornerRadius: cornerRadius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        toRound(cornerRadius: cornerRadius)
    }

}

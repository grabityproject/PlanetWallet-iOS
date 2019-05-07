//
//  RoundView.swift
//  PlanetWallet
//
//  Created by grabity on 03/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

@IBDesignable
class RoundView: UIView, Roundable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = self.frame.width/2.0
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.width/2.0
        self.layer.masksToBounds = true
    }

}

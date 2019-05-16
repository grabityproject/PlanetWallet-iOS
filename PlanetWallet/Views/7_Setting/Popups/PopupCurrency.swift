//
//  TestPopup.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PopupCurrency: AbsSlideUpView {
    
    @IBOutlet var containerView: UIView!
    
    public var handler: ((String) -> Void)?
    
    override func setXib() {
        super.setXib()
        
        Bundle.main.loadNibNamed("PopupCurrency", owner: self, options: nil)
        contentView = containerView
    }
    
    @IBAction func didTouchedCurrency(_ sender: UIButton) {
        
        if let title = sender.titleLabel?.text {
            handler?(title)
        }
    }
    
}

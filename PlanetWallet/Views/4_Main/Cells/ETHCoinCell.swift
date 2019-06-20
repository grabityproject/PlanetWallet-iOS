//
//  ETHCoinCell.swift
//  PlanetWallet
//
//  Created by grabity on 20/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ETHCoinCell: PWTableCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var coinIconImg: UIImageView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var amountLb: PWLabel!
    @IBOutlet var currencyLb: PWLabel!
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("ETHCoinCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }
    
}

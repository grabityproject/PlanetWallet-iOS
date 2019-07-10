//
//  PlanetCell.swift
//  PlanetWallet
//
//  Created by grabity on 09/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetCell: PWTableCell {
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var addressLb: PWLabel!
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("PlanetCell", owner: self, options: nil)
        self.backgroundColor = .clear
        
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }
    
}

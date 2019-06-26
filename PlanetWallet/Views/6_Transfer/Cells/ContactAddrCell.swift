//
//  ContactAddrCell.swift
//  PlanetWallet
//
//  Created by grabity on 17/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ContactAddrCell: PWTableCell {

    @IBOutlet var containerView: PWView!
    @IBOutlet var addressLb: PWLabel!
    @IBOutlet var iconImgView: UIImageView!
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("ContactAddrCell", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        
        self.addSubview(containerView)
    }
    
    
}

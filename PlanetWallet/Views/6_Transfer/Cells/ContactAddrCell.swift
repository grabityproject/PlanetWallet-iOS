//
//  ContactAddrCell.swift
//  PlanetWallet
//
//  Created by grabity on 17/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ContactAddrCell: UITableViewCell {

    @IBOutlet var containerView: PWView!
    @IBOutlet var addressLb: PWLabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ContactAddrCell", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        
        self.addSubview(containerView)
        
        addressLb.setColoredAddress()
    }
}

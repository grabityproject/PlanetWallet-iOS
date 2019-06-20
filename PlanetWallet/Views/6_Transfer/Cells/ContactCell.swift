//
//  ContactCell.swift
//  PlanetWallet
//
//  Created by grabity on 17/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ContactCell: PWTableCell {
    
    @IBOutlet private var containerView: PWView!
    @IBOutlet private var planetView: PlanetView!
    @IBOutlet private var planetName: PWLabel!
    @IBOutlet private var addressLb: PWLabel!
    
    public var contact: Contact? {
        didSet {
            guard let contact = contact else { return }
            self.planetName.text = contact.name
            self.planetView.data = contact.name
            self.addressLb.text = contact.address
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("ContactCell", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
    }
}

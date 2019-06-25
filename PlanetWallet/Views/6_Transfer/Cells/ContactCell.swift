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
    @IBOutlet public var planetView: PlanetView!
    @IBOutlet public var planetName: PWLabel!
    @IBOutlet public var addressLb: PWLabel!
    
    override func commonInit() {
        super.commonInit()

        Bundle.main.loadNibNamed("ContactCell", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
    }
}

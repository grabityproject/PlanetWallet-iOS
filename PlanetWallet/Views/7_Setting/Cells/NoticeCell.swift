//
//  NoticeCell.swift
//  PlanetWallet
//
//  Created by grabity on 15/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class NoticeCell: PWTableCell {

    @IBOutlet var containerView: PWView!
    @IBOutlet var titleLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("NoticeCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }

    @IBAction func didTouched(_ sender: UIButton) {
    }
}

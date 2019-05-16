//
//  CountryCodeCell.swift
//  PlanetWallet
//
//  Created by grabity on 14/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class CountryCodeCell: UITableViewCell {
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var nameLb: PWLabel!
    @IBOutlet var codeLb: PWLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CountryCodeCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
        
        
    }
}

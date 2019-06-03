//
//  ETHCoinCell.swift
//  PlanetWallet
//
//  Created by grabity on 20/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ETHCoinCell: UITableViewCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var coinIconImg: UIImageView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var amountLb: PWLabel!
    @IBOutlet var currencyLb: PWLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func prepareForReuse() {
        self.selectedBackgroundView = nil
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ETHCoinCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(containerView)
        
        
    }
    
}

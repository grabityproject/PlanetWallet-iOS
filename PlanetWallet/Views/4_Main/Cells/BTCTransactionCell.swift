//
//  BTCHistoryCell.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BTCTransactionCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    @IBOutlet var amountLb: UILabel!
    
    @IBOutlet var upDownImgView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("BTCTransactionCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        addSubview(containerView)
    }


}

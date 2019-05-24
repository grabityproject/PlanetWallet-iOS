//
//  PlanetCell.swift
//  PlanetWallet
//
//  Created by grabity on 09/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetCell: UITableViewCell {
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var addressLb: PWLabel!
    
    
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
        Bundle.main.loadNibNamed("PlanetCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }
    
}

//
//  ConfirmOpponentView.swift
//  PlanetWallet
//
//  Created by grabity on 06/09/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ConfirmOpponentView: UIView {

    private let xibName = "ConfirmOpponentView"

    @IBOutlet var addressContainer: UIView!
    @IBOutlet var coinImageView: PWImageView!
    @IBOutlet var addressLb: UILabel!
    
    @IBOutlet var planetContainer: UIView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var planetAddressLb: PWLabel!
    
    @IBOutlet var amountLb: PWLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(view)
    }
    
    public func setTx() {
        
    }
}

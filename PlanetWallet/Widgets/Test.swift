//
//  Test.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

@IBDesignable
class Test: UIView {

    @IBInspectable var hiddenLabel: Bool = false {
        didSet {
            label.isHidden = hiddenLabel
        }
    }
    
    let label: UILabel = {
       let lb = UILabel()
        lb.text = "test"
        lb.textColor = .red
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    private func commonInit() {
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
    }
    
}

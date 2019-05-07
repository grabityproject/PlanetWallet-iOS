//
//  PinView.swift
//  PlanetWallet
//
//  Created by grabity on 22/02/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PinView: UIView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var pinList: [UIView]!
    
    private let selectedColor = 0xEB3E54
    private let unSelectedColor = 0x585F6F
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PinView", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
        
        setCircularPin()
    }

    private func setCircularPin() {
        pinList.forEach { (pin) in
            pin.layer.cornerRadius = pin.frame.size.width/2
            pin.layer.masksToBounds = true
        }
    }
    
    public func setSelectedColor(_ position: Int) {
        
        if position == 0 {
            pinList[0].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[1].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[2].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[3].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[4].backgroundColor = UIColor(rgb: unSelectedColor)
        }
        else if position == 1 {
            pinList[0].backgroundColor = UIColor(rgb: selectedColor)
            pinList[1].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[2].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[3].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[4].backgroundColor = UIColor(rgb: unSelectedColor)
        }
        else if position == 2 {
            pinList[0].backgroundColor = UIColor(rgb: selectedColor)
            pinList[1].backgroundColor = UIColor(rgb: selectedColor)
            pinList[2].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[3].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[4].backgroundColor = UIColor(rgb: unSelectedColor)
        }
        else if position == 3 {
            pinList[0].backgroundColor = UIColor(rgb: selectedColor)
            pinList[1].backgroundColor = UIColor(rgb: selectedColor)
            pinList[2].backgroundColor = UIColor(rgb: selectedColor)
            pinList[3].backgroundColor = UIColor(rgb: unSelectedColor)
            pinList[4].backgroundColor = UIColor(rgb: unSelectedColor)
        }
        else if position == 4 {
            pinList[0].backgroundColor = UIColor(rgb: selectedColor)
            pinList[1].backgroundColor = UIColor(rgb: selectedColor)
            pinList[2].backgroundColor = UIColor(rgb: selectedColor)
            pinList[3].backgroundColor = UIColor(rgb: selectedColor)
            pinList[4].backgroundColor = UIColor(rgb: unSelectedColor)
        }
        else if position == 5 {
            pinList[0].backgroundColor = UIColor(rgb: selectedColor)
            pinList[1].backgroundColor = UIColor(rgb: selectedColor)
            pinList[2].backgroundColor = UIColor(rgb: selectedColor)
            pinList[3].backgroundColor = UIColor(rgb: selectedColor)
            pinList[4].backgroundColor = UIColor(rgb: selectedColor)
        }
    }
}

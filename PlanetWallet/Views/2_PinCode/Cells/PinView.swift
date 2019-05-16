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
    
    @IBOutlet var roundViewList: [PWView]!
    @IBOutlet var pinViewList: [UIView]!
    
    //selected round view color
    private var selectedColor: UIColor!
    //unselected round view color
    private let unSelectedColor = UIColor.clear
    //pin view color
    private let pinColor = ThemeManager.currentTheme().pinCode
    
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
        
        selectedColor = ThemeManager.currentTheme().mainText

        
        roundViewList.forEach({ $0.backgroundColor = unSelectedColor })
        pinViewList.forEach( { $0.backgroundColor = ThemeManager.currentTheme().pinCode })
    }
    
    public func setSelectedColor(_ position: Int) {
        
        let pinWidth = roundViewList[0].frame.size.width
        
        for i in 0..<pinViewList.count {
            if i < position {
                roundViewList[i].backgroundColor = selectedColor
                roundViewList[i].cornerRadius = pinWidth/2
                
                pinViewList[i].backgroundColor = unSelectedColor
            }
            else {
                roundViewList[i].backgroundColor = unSelectedColor
                
                pinViewList[i].backgroundColor = pinColor
            }
        }
    }
}

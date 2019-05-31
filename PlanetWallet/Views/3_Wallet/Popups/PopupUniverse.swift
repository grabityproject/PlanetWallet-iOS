//
//  PopupUniverse.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PopupUniverse: AbsSlideUpView {

    @IBOutlet var containerView: PWView!
    
    public var handler: ((UniverseType) -> Void)?
    
    override func setXib() {
        super.setXib()

        Bundle.main.loadNibNamed("PopupUniverse", owner: self, options: nil)
        contentView = containerView
        
        findAllViews(view: contentView!, theme: ThemeManager.currentTheme())
    }
    
    func findAllViews(view:UIView, theme:Theme){
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in
                
                findAllViews(view: v, theme: theme)
            }
        }
    }
    
    @IBAction func didTouched(_ sender: UIButton) {
        if sender.tag == 0 {
            //BTC
            handler?(UniverseType.BTC)
        }
        else {
            //ETH
            handler?(UniverseType.ETH)
        }
    }
    
}

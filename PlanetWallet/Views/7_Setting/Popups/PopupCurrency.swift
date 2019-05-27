//
//  TestPopup.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PopupCurrency: AbsSlideUpView {
    
    @IBOutlet var containerView: PWView!
    
    public var handler: ((String) -> Void)?
    
    override func setXib() {
        super.setXib()
        
        Bundle.main.loadNibNamed("PopupCurrency", owner: self, options: nil)
        contentView = containerView
        
        findAllViews(view: contentView!, theme: ThemeManager.currentTheme())
    }
    
    func findAllViews( view:UIView, theme:Theme ){
        
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in
                
                findAllViews(view: v, theme: theme)
            }
        }
    }
    
    @IBAction func didTouchedCurrency(_ sender: UIButton) {
        
        if let title = sender.titleLabel?.text {
            handler?(title)
        }
    }
    
}

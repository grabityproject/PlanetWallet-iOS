//
//  TestPopup.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension PopupCurrency {
    enum Currency: String {
        case KRW = "KRW"
        case USD = "USD"
        case CNY = "CNY"
    }
}

class PopupCurrency: AbsSlideUpView {
    
    @IBOutlet var containerView: PWView!
    
    public var handler: ((Currency) -> Void)?
    
    override func setXib() {
        super.setXib()
        Bundle.main.loadNibNamed("PopupCurrency", owner: self, options: nil)
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        
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
            handler?(Currency(rawValue: title) ?? Currency.KRW)
        }
    }
    
}

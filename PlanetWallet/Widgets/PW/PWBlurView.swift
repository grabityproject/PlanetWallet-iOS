//
//  PWBlurView.swift
//  PlanetWallet
//
//  Created by 박상은 on 03/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PWBlurView: UIView, Themable {
    
    private var blur:IntensityBlurVIew!
    private var blurView: UIVisualEffectView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    override var frame: CGRect{
        didSet{
            self.blurView?.frame = self.bounds
        }
    }
    
    override func layoutSubviews() {
        viewInit()
    }
    
    func viewInit(){
        if( blurView == nil ){
            blurView = UIVisualEffectView()
            
            if ThemeManager.currentTheme() == .DARK {
                self.blurView.effect = UIBlurEffect(style: .dark)
            }
            else {
                self.blurView.effect = UIBlurEffect(style: .light)
            }
            addSubview(self.blurView)
        }
        self.blurView.frame = self.bounds
    }

    func setTheme(_ theme: Theme) {
        
        if theme == .DARK {
            blurView.effect = UIBlurEffect(style: .dark)
        }
        else {
            blurView.effect = UIBlurEffect(style: .light)
        }
        
    }

}

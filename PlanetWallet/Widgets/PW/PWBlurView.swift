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
            self.blur?.frame = self.bounds
        }
    }
    
    override func layoutSubviews() {
        viewInit()
    }
    
    func viewInit(){
        if( blur == nil ){
            if ThemeManager.currentTheme() == .DARK {
                self.blur = IntensityBlurVIew(effect: UIBlurEffect(style: .dark), intensity: 0.5)
            }
            else {
                self.blur = IntensityBlurVIew(effect: UIBlurEffect(style: .light), intensity: 0.5)
            }
            addSubview(self.blur)
        }
        self.blur.frame = self.bounds
    }

    func setTheme(_ theme: Theme) {
        
        if theme == .DARK {
            self.blur = IntensityBlurVIew(effect: UIBlurEffect(style: .dark), intensity: 0.5)
        }
        else {
            self.blur = IntensityBlurVIew(effect: UIBlurEffect(style: .light), intensity: 0.5)
        }
    }

}

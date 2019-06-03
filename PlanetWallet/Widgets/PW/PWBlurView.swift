//
//  PWBlurView.swift
//  PlanetWallet
//
//  Created by 박상은 on 03/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PWBlurView: UIVisualEffectView, Themable {

    func setTheme(_ theme: Theme) {
        if( theme == .DARK ){
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.effect = blurEffect
        }else{
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            self.effect = blurEffect
        }
    }

}

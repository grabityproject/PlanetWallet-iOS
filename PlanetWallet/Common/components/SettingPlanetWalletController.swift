//
//  SettingPlanetWalletController.swift
//  PlanetWallet
//
//  Created by grabity on 20/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class SettingPlanetWalletController: PlanetWalletViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch currentTheme {
        case .DARK:     return .default
        case .LIGHT:    return .lightContent
        }
    }
}

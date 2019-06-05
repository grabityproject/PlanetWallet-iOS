//
//  Extension + UIButton.swift
//  PlanetWallet
//
//  Created by grabity on 07/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension UIButton {
    func setEnabled(_ isEnabled: Bool, theme: Theme) {
        self.isEnabled = isEnabled
        
        if isEnabled {
            self.backgroundColor = theme.mainText
            self.setTitleColor(theme.backgroundColor, for: .normal)
        }
        else {
            self.backgroundColor = theme.disableViewBg
            self.setTitleColor(theme.disableText, for: .normal)
        }
    }
    
    func setMenuItemSelected(_ isSelected: Bool, theme: Theme) {
        if isSelected {
            self.backgroundColor = theme.backgroundColor
            self.setTitleColor(theme.mainText, for: .normal)
            self.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
        }
        else {
            self.backgroundColor = theme.backgroundColor
            self.setTitleColor(theme.detailText, for: .normal)
            self.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
        }
    }
}
